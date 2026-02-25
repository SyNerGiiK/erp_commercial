// ignore_for_file: prefer_const_constructors
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../models/entreprise_model.dart';
import '../models/paiement_model.dart';
import '../models/enums/entreprise_enums.dart'; // IMPORT ADDED
import '../utils/format_utils.dart';
import '../models/pdf_design_config.dart';
import 'pdf_themes/pdf_themes.dart';

class PdfGenerationRequest {
  final Map<String, dynamic>? document;
  final String documentType; // 'devis' or 'facture'
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? profil;
  final String docTypeLabel;
  final bool isTvaApplicable;
  final String? fontPairing; // added to propagate the choice
  /// La configuration de design PDF sérialisée (JSON) — transmise à l'isolate
  final Map<String, dynamic>? configJson;
  // Font bytes passed from main isolate
  final Uint8List? fontRegular;
  final Uint8List? fontBold;
  final Uint8List? fontItalic;
  final String? factureSourceNumero;

  /// Factures précédentes liées au même devis (pour déductions situation)
  final List<Map<String, dynamic>>? facturesPrecedentes;

  PdfGenerationRequest({
    required this.document,
    required this.documentType,
    required this.client,
    required this.profil,
    required this.docTypeLabel,
    required this.isTvaApplicable,
    this.fontPairing,
    this.configJson,
    this.fontRegular,
    this.fontBold,
    this.fontItalic,
    this.factureSourceNumero,
    this.facturesPrecedentes,
  });
}

class PdfService {
  // Couleurs par défaut (fallback quand pas de config)
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFF1E5572);
  static final PdfColor _lightGrey = PdfColor.fromInt(0xFFF8F8F8);

  /// Retourne la couleur primaire depuis la config ou le fallback
  static PdfColor _configPrimaryColor(PdfDesignConfig? config) {
    if (config == null) return _primaryColor;
    try {
      final hex = config.primaryColor.replaceFirst('#', '');
      return PdfColor.fromInt(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return _primaryColor;
    }
  }

  /// Retourne une version très claire de la couleur primaire pour les fonds (10% opacité)
  static PdfColor _configAccentLight(PdfDesignConfig? config) {
    if (config == null) return _lightGrey;
    try {
      final hex = config.primaryColor.replaceFirst('#', '');
      final base = PdfColor.fromInt(int.parse('FF$hex', radix: 16));
      // Mélange avec blanc : 90% blanc + 10% couleur
      return PdfColor(
        base.red * 0.15 + 0.85,
        base.green * 0.15 + 0.85,
        base.blue * 0.15 + 0.85,
      );
    } catch (_) {
      return _lightGrey;
    }
  }

  /// Résout le thème PDF à utiliser depuis le profil entreprise et la configuration
  static PdfThemeBase _resolveTheme(ProfilEntreprise? entreprise,
      {PdfDesignConfig? config}) {
    final pdfTheme = entreprise?.pdfTheme ?? PdfTheme.moderne;

    // Si aucune config n'est fournie, on crée une default pour éviter les crashs
    final activeConfig =
        config ?? PdfDesignConfig.defaultConfig(entreprise?.id ?? 'default');

    return PdfThemeFactory.resolve(activeConfig, pdfTheme);
  }

  // Preload fonts in main isolate
  static Future<Map<String, Uint8List>> prepareFonts(
      PdfFontPairing pairing) async {
    pw.Font regular;
    pw.Font bold;
    pw.Font italic;

    switch (pairing) {
      case PdfFontPairing.luxury:
        regular = await PdfGoogleFonts.playfairDisplayRegular();
        bold = await PdfGoogleFonts.playfairDisplayBold();
        italic = await PdfGoogleFonts.playfairDisplayItalic();
        break;
      case PdfFontPairing.classic:
        regular = await PdfGoogleFonts.merriweatherRegular();
        bold = await PdfGoogleFonts.merriweatherBold();
        italic = await PdfGoogleFonts.merriweatherItalic();
        break;
      case PdfFontPairing.tech:
        regular = await PdfGoogleFonts.robotoMonoRegular();
        bold = await PdfGoogleFonts.robotoMonoBold();
        italic = await PdfGoogleFonts.robotoMonoItalic();
        break;
      case PdfFontPairing.modern:
        regular = await PdfGoogleFonts.interRegular();
        bold = await PdfGoogleFonts.interBold();
        // Inter italic not always available in standard bundle, fallback to OpenSans if needed, but let's try
        italic = await PdfGoogleFonts
            .openSansItalic(); // Using OpenSans Italic as safe fallback for Modern
        break;
    }

    return {
      'regular': (regular as dynamic).data.buffer.asUint8List(),
      'bold': (bold as dynamic).data.buffer.asUint8List(),
      'italic': (italic as dynamic).data.buffer.asUint8List(),
    };
  }

  static Future<pw.ThemeData> _loadTheme(PdfDesignConfig? config,
      {Uint8List? regularBytes,
      Uint8List? boldBytes,
      Uint8List? italicBytes}) async {
    final pairing = config?.fontPairing ?? PdfFontPairing.modern;

    pw.Font? fallbackRegular, fallbackBold, fallbackItalic;

    if (regularBytes == null || boldBytes == null || italicBytes == null) {
      switch (pairing) {
        case PdfFontPairing.luxury:
          fallbackRegular = await PdfGoogleFonts.playfairDisplayRegular();
          fallbackBold = await PdfGoogleFonts.playfairDisplayBold();
          fallbackItalic = await PdfGoogleFonts.playfairDisplayItalic();
          break;
        case PdfFontPairing.classic:
          fallbackRegular = await PdfGoogleFonts.merriweatherRegular();
          fallbackBold = await PdfGoogleFonts.merriweatherBold();
          fallbackItalic = await PdfGoogleFonts.merriweatherItalic();
          break;
        case PdfFontPairing.tech:
          fallbackRegular = await PdfGoogleFonts.robotoMonoRegular();
          fallbackBold = await PdfGoogleFonts.robotoMonoBold();
          fallbackItalic = await PdfGoogleFonts.robotoMonoItalic();
          break;
        case PdfFontPairing.modern:
          fallbackRegular = await PdfGoogleFonts.interRegular();
          fallbackBold = await PdfGoogleFonts.interBold();
          fallbackItalic = await PdfGoogleFonts.openSansItalic();
          break;
      }
    }

    final pw.Font fontRegular = regularBytes != null
        ? pw.Font.ttf(regularBytes.buffer
            .asByteData(regularBytes.offsetInBytes, regularBytes.lengthInBytes))
        : fallbackRegular!;

    final pw.Font fontBold = boldBytes != null
        ? pw.Font.ttf(boldBytes.buffer
            .asByteData(boldBytes.offsetInBytes, boldBytes.lengthInBytes))
        : fallbackBold!;

    final pw.Font fontItalic = italicBytes != null
        ? pw.Font.ttf(italicBytes.buffer
            .asByteData(italicBytes.offsetInBytes, italicBytes.lengthInBytes))
        : fallbackItalic!;

    return pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );
  }

  static Future<Uint8List?> _downloadImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      // debugPrint not available here, ignore
    }
    return null;
  }

  // --- ISOLATE GENERATION ---
  static Future<Uint8List> generatePdfIsolate(
      PdfGenerationRequest request) async {
    // Reconstruct objects from Maps
    final client =
        request.client != null ? Client.fromMap(request.client!) : null;
    final profil = request.profil != null
        ? ProfilEntreprise.fromMap(request.profil!)
        : null;
    dynamic document;
    if (request.documentType == 'facture') {
      document = Facture.fromMap(request.document!);
    } else {
      document = Devis.fromMap(request.document!);
    }

    // Reconstruire la PdfDesignConfig depuis le JSON transmis
    PdfDesignConfig config;
    if (request.configJson != null) {
      try {
        config = PdfDesignConfig.fromJson(request.configJson!);
      } catch (_) {
        config = PdfDesignConfig.defaultConfig(profil?.id ?? 'default');
      }
    } else {
      // Fallback : construire une config minimale avec le fontPairing
      final fontPairingEnum = request.fontPairing != null
          ? PdfFontPairing.values.firstWhere(
              (e) => e.name == request.fontPairing,
              orElse: () => PdfFontPairing.modern)
          : PdfFontPairing.modern;
      config = PdfDesignConfig.defaultConfig(profil?.id ?? 'default')
          .copyWith(fontPairing: fontPairingEnum);
    }

    return await generateDocument(document, client, profil,
        docType: request.docTypeLabel,
        isTvaApplicable: request.isTvaApplicable,
        factureSourceNumero: request.factureSourceNumero,
        facturesPrecedentes: request.facturesPrecedentes,
        config: config,
        fontRegular: request.fontRegular,
        fontBold: request.fontBold,
        fontItalic: request.fontItalic);
  }

  // --- GÉNÉRATION DOCUMENTS (Devis, Facture, Avoir, Situation) ---
  static Future<Uint8List> generateDocument(
      dynamic document, Client? client, ProfilEntreprise? entreprise,
      {String docType = "DOCUMENT",
      bool isTvaApplicable = true,
      String? factureSourceNumero,
      List<Map<String, dynamic>>? facturesPrecedentes,
      PdfDesignConfig? config,
      Uint8List? fontRegular,
      Uint8List? fontBold,
      Uint8List? fontItalic}) async {
    return _generateDocumentInternal(document, client, entreprise,
        docType: docType,
        isTvaApplicable: isTvaApplicable,
        factureSourceNumero: factureSourceNumero,
        facturesPrecedentes: facturesPrecedentes,
        config: config,
        fontRegular: fontRegular,
        fontBold: fontBold,
        fontItalic: fontItalic);
  }

  // Wrapper/Alias to keep compatibility if needed, but I'll likely just move the logic.
  static Future<Uint8List> _generateDocumentInternal(
      dynamic document, Client? client, ProfilEntreprise? entreprise,
      {String docType = "DOCUMENT",
      bool isTvaApplicable = true,
      String? factureSourceNumero,
      List<Map<String, dynamic>>? facturesPrecedentes,
      PdfDesignConfig? config,
      Uint8List? fontRegular,
      Uint8List? fontBold,
      Uint8List? fontItalic}) async {
    final theme = await _loadTheme(config,
        regularBytes: fontRegular,
        boldBytes: fontBold,
        italicBytes: fontItalic);

    final logoBytes = await _downloadImage(entreprise?.logoUrl);
    final signatureEntBytes = await _downloadImage(entreprise?.signatureUrl);
    final logoFooterBytes = await _downloadImage(entreprise?.logoFooterUrl);
    final bannerImageBytes = await _downloadImage(config?.headerBannerUrl);
    final watermarkImageBytes = await _downloadImage(config?.watermarkImageUrl);

    final pdf = pw.Document(theme: theme);

    // Common Fields extraction
    String numero = "";
    DateTime date = DateTime.now();
    String objet = "";
    List<dynamic> lignes = [];
    Decimal totalHt = Decimal.zero;
    Decimal remiseTaux = Decimal.zero;
    Decimal acompte =
        Decimal.zero; // Acompte montant (Devis) or Deja Reglé (Facture)
    String? notes;
    String? signatureUrl;
    List<Paiement> paiements = [];
    bool isDevis = false;
    bool isFacture = false;
    bool isSituation = false;

    if (document is Facture) {
      isFacture = true;
      numero = document.numeroFacture;
      date = document.dateEmission;
      objet = document.objet;
      lignes = document.lignes;
      totalHt = document.totalHt;
      remiseTaux = document.remiseTaux;
      acompte = document.acompteDejaRegle;
      notes = document.notesPubliques;
      signatureUrl = document.signatureUrl;
      paiements = document.paiements;
      if (document.type == 'situation') isSituation = true;
      if (document.type == 'avoir') docType = "AVOIR"; // Override docType
    } else if (document is Devis) {
      isDevis = true;
      numero = document.numeroDevis;
      date = document.dateEmission;
      objet = document.objet;
      lignes = document.lignes;
      totalHt = document.totalHt;
      remiseTaux = document.remiseTaux;
      acompte = document.acompteMontant;
      notes = document.notesPubliques;
      signatureUrl = document.signatureUrl;
    }

    final signatureClientBytes = await _downloadImage(signatureUrl);

    // Calculation logic for display
    final montantRemiseRational = (totalHt * remiseTaux) / Decimal.fromInt(100);
    // ignore: unused_local_variable
    final montantRemise = montantRemiseRational.toDecimal();

    // Net Commercial
    final netCommercial = totalHt - montantRemise;

    // TVA
    Decimal totalTva = Decimal.zero;
    if (isTvaApplicable) {
      if (document is Facture) totalTva = document.totalTva;
      if (document is Devis) totalTva = document.totalTva;
    }

    // Net A Payer (TTC)
    final netAPayer = netCommercial + totalTva;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (context) {
            if (config != null) {
              if (watermarkImageBytes != null) {
                return pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Center(
                    child: pw.Opacity(
                      opacity: config.watermarkOpacity.toDouble(),
                      child: pw.Image(
                        pw.MemoryImage(watermarkImageBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                );
              } else if (config.watermarkText?.isNotEmpty ?? false) {
                return pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Center(
                    child: pw.Transform.rotateBox(
                      angle: 0.785398, // 45 degrees
                      child: pw.Opacity(
                        opacity: config.watermarkOpacity.toDouble(),
                        child: pw.Text(
                          config.watermarkText!,
                          style: pw.TextStyle(
                            fontSize: 100,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey300,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
            return pw.Container();
          },
        ),
        build: (context) {
          final theme = _resolveTheme(entreprise, config: config);
          return [
            theme.buildHeader(
              entreprise?.nomEntreprise,
              docType,
              numero,
              date,
              logoBytes != null ? pw.MemoryImage(logoBytes) : null,
              bannerImageBytes != null
                  ? pw.MemoryImage(bannerImageBytes)
                  : null,
            ),
            pw.SizedBox(height: 30),
            theme.buildAddresses(
              entreprise?.nomEntreprise,
              entreprise?.nomGerant,
              entreprise?.adresse,
              "${entreprise?.codePostal} ${entreprise?.ville}",
              entreprise?.email,
              entreprise?.telephone,
              client?.nomComplet,
              client?.nomContact,
              client?.adresse,
              "${client?.codePostal ?? ""} ${client?.ville ?? ""}",
            ),
            pw.SizedBox(height: 30),
            theme.buildTitle(objet),
            pw.SizedBox(height: 20),
            _buildLignesTable(lignes,
                isSituation: isSituation,
                showTva: isTvaApplicable,
                config: config),
            pw.SizedBox(height: 20),
            _buildTotals(totalHt, remiseTaux, acompte, totalTva, netAPayer,
                isDevis: isDevis,
                showTva: isTvaApplicable,
                isSituation: isSituation,
                totalMarche: isSituation
                    ? lignes.where((l) => l.type == 'article').fold<Decimal>(
                        Decimal.zero,
                        (Decimal sum, l) => sum + (l.quantite * l.prixUnitaire))
                    : null,
                deductions: isSituation
                    ? _buildDeductionsFromMaps(facturesPrecedentes)
                    : null,
                config: config),
            pw.SizedBox(height: 30),
            if (isFacture) _buildPaiementsTable(paiements, netAPayer, acompte),
            pw.SizedBox(height: 20),
            _buildFooterSignatures(
              notes,
              entreprise,
              signatureEntBytes,
              signatureClientBytes,
              dateEcheance: document is Facture ? document.dateEcheance : null,
              conditionsReglement:
                  document is Facture ? document.conditionsReglement : null,
              numeroBonCommande:
                  document is Facture ? document.numeroBonCommande : null,
              motifAvoir: document is Facture ? document.motifAvoir : null,
              isAvoir: document is Facture && document.type == 'avoir',
              factureSourceNumero: factureSourceNumero,
              netAPayer: netAPayer,
              numeroDocument: numero,
              logoFooterBytes: logoFooterBytes,
            ),
          ];
        },
        footer: (context) {
          final theme = _resolveTheme(entreprise, config: config);
          return theme.buildFooterMentions(
            entreprise?.nomEntreprise,
            entreprise?.siret,
            entreprise?.iban,
            entreprise?.bic,
            entreprise?.mentionsLegales,
            isTvaApplicable,
            numeroTvaIntra: entreprise?.numeroTvaIntra,
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- COMPOSANTS PDF ---

  static pw.Widget _buildLignesTable(List<dynamic> lignes,
      {bool isSituation = false,
      bool isBL = false,
      bool showTva = true,
      PdfDesignConfig? config}) {
    final chunks = <List<dynamic>>[];
    var currentChunk = <dynamic>[];

    for (var l in lignes) {
      // BREAK on 'saut_page' OR 'titre' (starting a new section)
      if (l.type == 'saut_page') {
        if (currentChunk.isNotEmpty) chunks.add(currentChunk);
        chunks.add([l]); // Keep saut_page as a chunk marker
        currentChunk = [];
      } else if (l.type == 'titre') {
        if (currentChunk.isNotEmpty) chunks.add(currentChunk);
        currentChunk = [l]; // Start new chunk WITH title
      } else {
        currentChunk.add(l);
      }
    }
    if (currentChunk.isNotEmpty) chunks.add(currentChunk);

    if (chunks.isEmpty) return pw.Container();

    return pw.Column(
        children: List.generate(chunks.length, (index) {
      final chunk = chunks[index];
      if (chunk.isEmpty) return pw.Container();

      // Handle Saut de Page chunk
      if (chunk.first.type == 'saut_page') {
        if (index < chunks.length - 1) return pw.NewPage();
        return pw.Container();
      }

      // Handle Title chunk
      pw.Widget? headerWidget;
      List<dynamic> tableRows = chunk;

      if (chunk.first.type == 'titre') {
        headerWidget = _buildSectionTitle(chunk.first.description);
        if (chunk.length > 1) {
          tableRows = chunk.sublist(1);
        } else {
          // Only a title, no table
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: headerWidget);
        }
      }

      final table = _buildChunkTable(tableRows,
          isSituation: isSituation,
          isBL: isBL,
          showTva: showTva,
          config: config);

      return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (headerWidget != null) ...[
                  headerWidget,
                  pw.SizedBox(height: 5)
                ],
                table
              ]));
    }));
  }

  static pw.Widget _buildSectionTitle(String title, {PdfDesignConfig? config}) {
    final primary = _configPrimaryColor(config);
    final bg = _configAccentLight(config);
    return pw.Container(
        width: double.infinity,
        color: bg,
        padding: const pw.EdgeInsets.all(5),
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(title.toUpperCase(),
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: primary, fontSize: 10)));
  }

  static pw.Widget _buildChunkTable(List<dynamic> chunk,
      {bool isSituation = false,
      bool isBL = false,
      bool showTva = true,
      PdfDesignConfig? config}) {
    final tableStyle = config?.tableStyle ?? PdfTableStyle.minimal;
    final primary = _configPrimaryColor(config);
    final accentLight = _configAccentLight(config);

    pw.TableBorder? tableBorder;
    bool hasOuterBorder = false;

    switch (tableStyle) {
      case PdfTableStyle.minimal:
        tableBorder = pw.TableBorder(
            bottom: pw.BorderSide(color: primary.shade(0.2), width: 0.5));
        break;
      case PdfTableStyle.zebra:
        tableBorder = pw.TableBorder(
            bottom: pw.BorderSide(color: primary.shade(0.2), width: 0.5),
            horizontalInside: pw.BorderSide(color: accentLight, width: 0.3));
        break;
      case PdfTableStyle.solid:
        tableBorder = pw.TableBorder.all(color: primary.shade(0.3), width: 0.5);
        hasOuterBorder = true;
        break;
      case PdfTableStyle.rounded:
        tableBorder = pw.TableBorder.all(color: primary.shade(0.3), width: 0.5);
        break;
      case PdfTableStyle.filledHeader:
        tableBorder = pw.TableBorder(
            bottom: pw.BorderSide(color: primary.shade(0.2), width: 0.5),
            horizontalInside: pw.BorderSide(color: accentLight, width: 0.3));
        break;
    }

    final table = pw.Table(border: tableBorder, columnWidths: {
      0: const pw.FlexColumnWidth(4),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      if (showTva && !isBL && !isSituation) 4: const pw.FlexColumnWidth(1),
    }, children: [
      pw.TableRow(decoration: pw.BoxDecoration(color: primary), children: [
        _buildHeaderCell("Désignation", alignment: pw.Alignment.centerLeft),
        _buildHeaderCell(isSituation ? "Marché" : "Qté"),
        if (!isBL)
          _buildHeaderCell(
              isSituation ? "Avct %" : (showTva ? "P.U. HT" : "Prix Unit.")),
        if (showTva && !isBL && !isSituation) _buildHeaderCell("TVA"),
        if (!isBL) _buildHeaderCell(showTva ? "Total HT" : "Total Net"),
      ]),
      ...chunk.asMap().entries.map((entry) => _buildRow(
            entry.value,
            isSituation: isSituation,
            isBL: isBL,
            showTva: showTva,
            rowIndex: entry.key,
            tableStyle: tableStyle,
            config: config,
          )),
    ]);

    if (hasOuterBorder) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primary.shade(0.3), width: 0.5),
        ),
        child: table,
      );
    }
    return table;
  }

  static pw.Widget _buildHeaderCell(String text,
      {pw.Alignment alignment = pw.Alignment.centerRight}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          textAlign: alignment == pw.Alignment.centerRight
              ? pw.TextAlign.right
              : pw.TextAlign.left),
    );
  }

  static pw.TableRow _buildRow(dynamic l,
      {bool isSituation = false,
      bool isBL = false,
      bool showTva = true,
      int rowIndex = 0,
      PdfTableStyle tableStyle = PdfTableStyle.minimal,
      PdfDesignConfig? config}) {
    final bool isSpecial = ['titre', 'sous-titre', 'texte'].contains(l.type);
    final primary = _configPrimaryColor(config);
    final accentLight = _configAccentLight(config);

    // Zebra striping avec la couleur accent
    pw.BoxDecoration? zebraDecoration;
    if (!isSpecial && tableStyle == PdfTableStyle.zebra && rowIndex.isOdd) {
      zebraDecoration = pw.BoxDecoration(color: accentLight);
    }
    // FilledHeader : alterner sur rows paires (exclusion row 0 = header)
    if (!isSpecial &&
        tableStyle == PdfTableStyle.filledHeader &&
        rowIndex.isEven &&
        rowIndex > 0) {
      zebraDecoration = pw.BoxDecoration(color: accentLight);
    }

    pw.TextStyle? style;
    pw.BoxDecoration? decoration;

    if (l.type == 'titre') {
      style = pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: primary, fontSize: 12);
      decoration = pw.BoxDecoration(color: accentLight);
    }
    if (l.type == 'sous-titre') {
      style = pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline);
    }
    if (l.type == 'texte') {
      style = pw.TextStyle(
          fontStyle: pw.FontStyle.italic, color: PdfColors.grey700);
    }

    final label = l.description ?? "";

    if (isSpecial) {
      return pw.TableRow(decoration: decoration ?? zebraDecoration, children: [
        pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(label, style: style)),
        pw.Container(),
        if (!isBL) pw.Container(),
        if (showTva && !isBL && !isSituation) pw.Container(),
        if (!isBL) pw.Container(),
      ]);
    }

    String col1;
    String col2;

    if (isSituation) {
      final marche = l.quantite * l.prixUnitaire;
      col1 = FormatUtils.currency(marche);
      col2 = "${l.avancement}%";
    } else {
      col1 = "${FormatUtils.quantity(l.quantite)} ${l.unite}";
      col2 = FormatUtils.currency(l.prixUnitaire);
    }

    return pw.TableRow(decoration: zebraDecoration, children: [
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(label)),
      pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(col1, textAlign: pw.TextAlign.right)),
      if (!isBL)
        pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(col2, textAlign: pw.TextAlign.right)),
      if (showTva && !isBL && !isSituation)
        pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text("${l.tauxTva}%", textAlign: pw.TextAlign.right)),
      if (!isBL)
        pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(FormatUtils.currency(l.totalLigne),
                textAlign: pw.TextAlign.right)),
    ]);
  }

  static pw.Widget _buildTotals(Decimal totalHt, Decimal remise,
      Decimal acompte, Decimal totalTva, Decimal netAPayer,
      {bool isDevis = false,
      bool showTva = true,
      bool isSituation = false,
      Decimal? totalMarche,
      List<Map<String, dynamic>>? deductions,
      PdfDesignConfig? config}) {
    final remiseRational = (totalHt * remise) / Decimal.fromInt(100);
    final remiseMontant = remiseRational.toDecimal();
    final primary = _configPrimaryColor(config);
    final accentLight = _configAccentLight(config);

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 280,
        child: pw.Column(children: [
          // === BLOC 1 : Contexte marché pour factures d'avancement ===
          if (isSituation &&
              totalMarche != null &&
              totalMarche > Decimal.zero) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: accentLight),
              child: pw.Column(children: [
                pw.Text("ÉTAT D'AVANCEMENT",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                        fontSize: 9)),
                pw.SizedBox(height: 4),
                _buildTotalRow("Total Marché HT", totalMarche),
                _buildTotalRow("Avancement", null,
                    label2:
                        "${((totalHt * Decimal.fromInt(100)) / totalMarche).toDecimal(scaleOnInfinitePrecision: 10).toDouble().toStringAsFixed(1)}%"),
                _buildTotalRow("Travaux réalisés HT", totalHt),
              ]),
            ),
            pw.SizedBox(height: 8),
          ],

          // === BLOC 2 : Récapitulatif financier & Déductions ===
          if (isSituation) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primary, width: 0.5),
              ),
              child: pw.Column(children: [
                pw.Text("RÉCAPITULATIF FINANCIER",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                        fontSize: 9)),
                pw.SizedBox(height: 4),
                _buildTotalRow(
                    showTva ? "Total brut HT" : "Total brut", totalHt),
                if (remise > Decimal.zero)
                  _buildTotalRow("Remise ($remise%)", remiseMontant,
                      isNegative: true),
                if (showTva) ...[
                  _buildTotalRow("TVA", totalTva),
                  pw.Divider(color: primary.shade(0.3)),
                  _buildTotalRow("Total brut TTC", netAPayer),
                ],
                if (deductions != null && deductions.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text("Déductions :",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  pw.SizedBox(height: 2),
                  ...deductions.map((d) => _buildTotalRow(
                        d['description'] as String,
                        d['montant'] as Decimal,
                        isNegative: true,
                      )),
                  pw.Divider(color: primary.shade(0.3)),
                ] else if (acompte > Decimal.zero) ...[
                  pw.SizedBox(height: 4),
                  _buildTotalRow("Déjà réglé", acompte, isNegative: true),
                  pw.Divider(color: primary.shade(0.3)),
                ],
                _buildTotalRow(
                  "NET À PAYER",
                  _calculateNetSituation(netAPayer, acompte, deductions),
                  isBold: true,
                ),
              ]),
            ),
          ] else ...[
            // === Mode classique (non-situation) ===
            if (showTva) _buildTotalRow("Total HT", totalHt),
            if (remise > Decimal.zero)
              _buildTotalRow("Remise ($remise%)", remiseMontant,
                  isNegative: true),
            if (showTva) ...[
              pw.Divider(color: primary.shade(0.2)),
              _buildTotalRow("Total TVA", totalTva),
            ],
            pw.Divider(color: primary.shade(0.2)),
            _buildTotalRow(showTva ? "Total TTC" : "NET À PAYER", netAPayer,
                isBold: acompte <= Decimal.zero),
            if (!isDevis && acompte > Decimal.zero) ...[
              _buildTotalRow("Déjà réglé", acompte, isNegative: true),
              pw.Divider(color: primary.shade(0.2)),
              _buildTotalRow("NET À PAYER", netAPayer - acompte, isBold: true),
            ],
            if (isDevis && acompte > Decimal.zero) ...[
              pw.SizedBox(height: 5),
              _buildTotalRow("Acompte demandé", acompte),
            ],
          ],
        ]),
      ),
    );
  }

  /// Calcule le net à payer situation en priorisant les déductions détaillées
  static Decimal _calculateNetSituation(Decimal netAPayer, Decimal acompte,
      List<Map<String, dynamic>>? deductions) {
    if (deductions != null && deductions.isNotEmpty) {
      final totalDeductions = deductions.fold<Decimal>(
        Decimal.zero,
        (sum, d) => sum + (d['montant'] as Decimal),
      );
      return netAPayer - totalDeductions;
    }
    return netAPayer - acompte;
  }

  static pw.Widget _buildTotalRow(String label, Decimal? amount,
      {bool isBold = false, bool isNegative = false, String? label2}) {
    return pw
        .Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label,
          style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      if (label2 != null)
        pw.Text(label2,
            style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal))
      else if (amount != null)
        pw.Text("${isNegative ? "- " : ""}${FormatUtils.currency(amount)}",
            style: pw.TextStyle(
                fontWeight:
                    isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    ]);
  }

  /// Construit la liste de déductions détaillées à partir des factures
  /// précédentes fournies en tant que Maps (pour PDF situation).
  static List<Map<String, dynamic>>? _buildDeductionsFromMaps(
      List<Map<String, dynamic>>? facturesPrecedentes) {
    if (facturesPrecedentes == null || facturesPrecedentes.isEmpty) {
      return null;
    }

    return facturesPrecedentes.map((fMap) {
      final type = fMap['type'] as String? ?? '';
      final numero = fMap['numero_facture'] as String? ?? '';
      final montant = Decimal.parse((fMap['total_ttc'] ?? '0').toString());

      String label;
      if (type == 'acompte') {
        label = "Fact. Acompte $numero";
      } else if (type == 'situation') {
        label = "Situation préc. $numero";
      } else {
        label = "Déduction $numero";
      }

      return <String, dynamic>{
        'description': label,
        'montant': montant,
      };
    }).toList();
  }

  static pw.Widget _buildPaiementsTable(
      List<Paiement> paiements, Decimal netAPayer, Decimal acompteDejaRegle) {
    if (paiements.isEmpty && acompteDejaRegle <= Decimal.zero) {
      return pw.Container();
    }

    final totalReglePaiements =
        paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

    final totalRegle = totalReglePaiements + acompteDejaRegle;
    final reste = netAPayer - totalRegle;

    final data = paiements
        .map((p) => [
              DateFormat('dd/MM/yyyy').format(p.datePaiement),
              p.typePaiement.toUpperCase(),
              p.isAcompte ? 'Acompte' : 'Solde',
              FormatUtils.currency(p.montant),
            ])
        .toList();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (paiements.isNotEmpty) ...[
            pw.Text("Règlements reçus",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.TableHelper.fromTextArray(
              headers: ["Date", "Mode", "Type", "Montant"],
              data: data,
              headerStyle:
                  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 8),
              border: null,
              headerDecoration: pw.BoxDecoration(color: _lightGrey),
            ),
            pw.SizedBox(height: 10),
          ],

          // RECAP à droite
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
            pw.Container(
              width: 200,
              child: pw.Column(children: [
                if (acompteDejaRegle > Decimal.zero)
                  _buildTotalRow("Acompte déjà réglé", acompteDejaRegle),
                if (paiements.isNotEmpty)
                  _buildTotalRow("Règlements reçus", totalReglePaiements),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Reste à payer",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text(FormatUtils.currency(reste),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: reste > Decimal.zero
                                  ? PdfColors.red
                                  : PdfColors.green)),
                    ]),
              ]),
            )
          ])
        ]);
  }

  static pw.Widget _buildFooterSignatures(
    String? notes,
    ProfilEntreprise? ent,
    Uint8List? signatureEnt,
    Uint8List? signatureClient, {
    // Informations facture pour mentions légales
    DateTime? dateEcheance,
    String? conditionsReglement,
    String? numeroBonCommande,
    String? motifAvoir,
    bool isAvoir = false,
    String? factureSourceNumero, // Numéro de la facture d'origine (pour avoir)
    Decimal? netAPayer,
    String? numeroDocument,
    Uint8List? logoFooterBytes,
  }) {
    final legalStyle =
        pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // === NOTES PUBLIQUES ===
                if (notes != null && notes.isNotEmpty) ...[
                  pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: _lightGrey),
                          borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Notes :",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                            pw.Text(notes,
                                style: const pw.TextStyle(fontSize: 8)),
                          ])),
                ],

                pw.SizedBox(height: 8),

                // === INFORMATIONS PAIEMENT (factures uniquement) ===
                if (dateEcheance != null) ...[
                  pw.Text(
                    "Date d'échéance : ${DateFormat('dd/MM/yyyy').format(dateEcheance)}",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                ],
                if (conditionsReglement != null &&
                    conditionsReglement.isNotEmpty)
                  pw.Text("Conditions de règlement : $conditionsReglement",
                      style: const pw.TextStyle(fontSize: 8)),

                if (numeroBonCommande != null && numeroBonCommande.isNotEmpty)
                  pw.Text("N° Bon de Commande : $numeroBonCommande",
                      style: const pw.TextStyle(fontSize: 8)),

                // === RÉFÉRENCE AVOIR → FACTURE SOURCE ===
                if (isAvoir && factureSourceNumero != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Avoir sur facture n° $factureSourceNumero",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                ],
                if (isAvoir && motifAvoir != null && motifAvoir.isNotEmpty) ...[
                  pw.Text("Motif : $motifAvoir",
                      style: const pw.TextStyle(fontSize: 8)),
                ],

                pw.SizedBox(height: 8),

                // === MENTIONS LÉGALES OBLIGATOIRES ===
                if (ent != null) ...[
                  // TVA non applicable (micro-entrepreneur sans TVA)
                  // Ne pas dupliquer si déjà dans mentionsLegales
                  if (ent.typeEntreprise.isMicroEntrepreneur &&
                      !ent.tvaApplicable &&
                      !(ent.mentionsLegales?.contains("TVA non applicable") ??
                          false))
                    pw.Text(
                      "TVA non applicable, art. 293 B du CGI.",
                      style: legalStyle,
                    ),

                  // Dispense d'immatriculation : SEULEMENT si non immatriculé
                  if (ent.typeEntreprise.isMicroEntrepreneur &&
                      !ent.estImmatricule &&
                      !(ent.mentionsLegales?.contains("Dispensé") ?? false))
                    pw.Text(
                      "Dispensé d'immatriculation au registre du commerce et des sociétés (RCS) et au répertoire des métiers (RM).",
                      style: legalStyle,
                    ),

                  // Pénalités de retard (obligatoire CGI art. 289 / Code Commerce L441-10)
                  pw.Text(
                    "En cas de retard de paiement, une pénalité de ${ent.tauxPenalitesRetard.toDouble().toStringAsFixed(2)}% par an sera appliquée (3 fois le taux d'intérêt légal minimum).",
                    style: legalStyle,
                  ),

                  // Indemnité forfaitaire de recouvrement (obligatoire depuis 01/01/2013)
                  pw.Text(
                    "Indemnité forfaitaire pour frais de recouvrement en cas de retard de paiement : 40,00 €.",
                    style: legalStyle,
                  ),

                  // Escompte
                  pw.Text(
                    ent.escompteApplicable
                        ? "Escompte pour paiement anticipé : selon conditions convenues."
                        : "Pas d'escompte pour paiement anticipé.",
                    style: legalStyle,
                  ),
                ],
              ]),
        ),
        pw.SizedBox(width: 10),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          // 1. QR Code SEPA (si facture non avoir avec IBAN)
          if (!isAvoir &&
              ent?.iban != null &&
              ent!.iban!.isNotEmpty &&
              netAPayer != null &&
              numeroDocument != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: _generateSepaString(ent, netAPayer, numeroDocument),
                  width: 50,
                  height: 50,
                ),
                pw.SizedBox(height: 2),
                pw.Text("Scan pour payer",
                    style: const pw.TextStyle(
                        fontSize: 6, color: PdfColors.grey700)),
              ]),
            ),
            pw.SizedBox(height: 10),
          ],

          // 2. Signatures
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (signatureClient != null)
              pw.Column(children: [
                pw.Text("Bon pour accord",
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Image(pw.MemoryImage(signatureClient),
                    width: 80, height: 40),
                pw.Text("Signé électroniquement",
                    style:
                        const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
              ])
            else
              _buildEmptySignatureZone(),
            if (signatureEnt != null) ...[
              pw.SizedBox(width: 10),
              pw.Image(pw.MemoryImage(signatureEnt), width: 60)
            ]
          ]),

          // 3. Badges (RGE, Qualibat, etc.)
          if (logoFooterBytes != null) ...[
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(logoFooterBytes), height: 35),
          ]
        ])
      ],
    );
  }

  static String _generateSepaString(
      ProfilEntreprise ent, Decimal amount, String ref) {
    // Norme EPC069-12 (SCT)
    final bic = ent.bic ?? '';
    final name = ent.nomEntreprise.replaceAll('\n', ' ').trim();
    final iban = ent.iban!.replaceAll(' ', '');
    final amountStr = amount.toDouble().toStringAsFixed(2);
    // BCD\n002\n1\nSCT\nBIC\nName\nIBAN\nEURAmount\n\nRef\n
    return "BCD\n002\n1\nSCT\n$bic\n$name\n$iban\nEUR$amountStr\n\n$ref\n";
  }

  static pw.Widget _buildEmptySignatureZone() {
    return pw.Container(
      width: 150,
      height: 50,
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
      alignment: pw.Alignment.center,
      child: pw.Text("Date et Signature",
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
    );
  }
}
