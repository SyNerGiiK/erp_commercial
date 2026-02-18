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
import 'pdf_themes/pdf_themes.dart';

class PdfGenerationRequest {
  final Map<String, dynamic>? document;
  final String documentType; // 'devis' or 'facture'
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? profil;
  final String docTypeLabel;
  final bool isTvaApplicable;
  // Font bytes passed from main isolate
  final Uint8List? fontRegular;
  final Uint8List? fontBold;
  final Uint8List? fontItalic;

  PdfGenerationRequest({
    required this.document,
    required this.documentType,
    required this.client,
    required this.profil,
    required this.docTypeLabel,
    required this.isTvaApplicable,
    this.fontRegular,
    this.fontBold,
    this.fontItalic,
  });
}

class PdfService {
  // Couleurs par défaut (fallback quand pas de profil)
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF1E5572);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF8F8F8);

  /// Résout le thème PDF à utiliser depuis le profil entreprise
  static PdfThemeBase _resolveTheme(ProfilEntreprise? entreprise) {
    final pdfTheme = entreprise?.pdfTheme ?? PdfTheme.moderne;
    return PdfThemeFactory.resolve(pdfTheme);
  }

  // Preload fonts in main isolate
  static Future<Map<String, Uint8List>> prepareFonts() async {
    // PdfGoogleFonts returns Future<Font>, but implementation is TtfFont
    // We cast to dynamic to access .data safely without importing explicit TtfFont if obscured
    final regular = await PdfGoogleFonts.openSansRegular();
    final bold = await PdfGoogleFonts.openSansBold();
    final italic = await PdfGoogleFonts.openSansItalic();

    return {
      'regular': (regular as dynamic).data.buffer.asUint8List(),
      'bold': (bold as dynamic).data.buffer.asUint8List(),
      'italic': (italic as dynamic).data.buffer.asUint8List(),
    };
  }

  static Future<pw.ThemeData> _loadTheme(
      {Uint8List? regularBytes,
      Uint8List? boldBytes,
      Uint8List? italicBytes}) async {
    final pw.Font fontRegular = regularBytes != null
        ? pw.Font.ttf(regularBytes.buffer
            .asByteData(regularBytes.offsetInBytes, regularBytes.lengthInBytes))
        : await PdfGoogleFonts.openSansRegular();

    final pw.Font fontBold = boldBytes != null
        ? pw.Font.ttf(boldBytes.buffer
            .asByteData(boldBytes.offsetInBytes, boldBytes.lengthInBytes))
        : await PdfGoogleFonts.openSansBold();

    final pw.Font fontItalic = italicBytes != null
        ? pw.Font.ttf(italicBytes.buffer
            .asByteData(italicBytes.offsetInBytes, italicBytes.lengthInBytes))
        : await PdfGoogleFonts.openSansItalic();

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
    // Client
    final client =
        request.client != null ? Client.fromMap(request.client!) : null;

    // Entreprise
    final profil = request.profil != null
        ? ProfilEntreprise.fromMap(request.profil!)
        : null;

    // Document (Devis or Facture)
    dynamic document;
    if (request.documentType == 'facture') {
      document = Facture.fromMap(request.document!);
    } else {
      document = Devis.fromMap(request.document!);
    }

    return await generateDocument(document, client, profil,
        docType: request.docTypeLabel,
        isTvaApplicable: request.isTvaApplicable,
        // Pass fonts
        fontRegular: request.fontRegular,
        fontBold: request.fontBold,
        fontItalic: request.fontItalic);
  }

  // --- GÉNÉRATION DOCUMENTS (Devis, Facture, Avoir, Situation) ---
  static Future<Uint8List> generateDocument(
      dynamic document, Client? client, ProfilEntreprise? entreprise,
      {String docType = "DOCUMENT",
      bool isTvaApplicable = true,
      Uint8List? fontRegular,
      Uint8List? fontBold,
      Uint8List? fontItalic}) async {
    // Let's add them at the top of PdfService class.
    return _generateDocumentInternal(document, client, entreprise,
        docType: docType,
        isTvaApplicable: isTvaApplicable,
        fontRegular: fontRegular,
        fontBold: fontBold,
        fontItalic: fontItalic);
  }

  // Wrapper/Alias to keep compatibility if needed, but I'll likely just move the logic.
  static Future<Uint8List> _generateDocumentInternal(
      dynamic document, Client? client, ProfilEntreprise? entreprise,
      {String docType = "DOCUMENT",
      bool isTvaApplicable = true,
      Uint8List? fontRegular,
      Uint8List? fontBold,
      Uint8List? fontItalic}) async {
    final theme = await _loadTheme(
        regularBytes: fontRegular,
        boldBytes: fontBold,
        italicBytes: fontItalic);

    final logoBytes = await _downloadImage(entreprise?.logoUrl);
    final signatureEntBytes = await _downloadImage(entreprise?.signatureUrl);

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
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final theme = _resolveTheme(entreprise);
          return [
            theme.buildHeader(entreprise?.nomEntreprise, docType, numero, date,
                logoBytes != null ? pw.MemoryImage(logoBytes) : null),
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
                isSituation: isSituation, showTva: isTvaApplicable),
            pw.SizedBox(height: 20),
            _buildTotals(totalHt, remiseTaux, acompte, totalTva, netAPayer,
                isDevis: isDevis, showTva: isTvaApplicable),
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
              factureSourceNumero: null, // Resolved by caller if needed
            ),
          ];
        },
        footer: (context) {
          final theme = _resolveTheme(entreprise);
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
      {bool isSituation = false, bool isBL = false, bool showTva = true}) {
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
          isSituation: isSituation, isBL: isBL, showTva: showTva);

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

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
        width: double.infinity,
        color: _lightGrey,
        padding: const pw.EdgeInsets.all(5),
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(title.toUpperCase(),
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
                fontSize: 10)));
  }

  static pw.Widget _buildChunkTable(List<dynamic> chunk,
      {bool isSituation = false, bool isBL = false, bool showTva = true}) {
    return pw.Table(
        border: const pw.TableBorder(
            bottom: pw.BorderSide(color: _lightGrey, width: 0.5)),
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1),
          if (showTva && !isBL && !isSituation) 4: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
              decoration: const pw.BoxDecoration(color: _primaryColor),
              children: [
                _buildHeaderCell("Désignation",
                    alignment: pw.Alignment.centerLeft),
                _buildHeaderCell(isSituation ? "Marché" : "Qté"),
                if (!isBL)
                  _buildHeaderCell(isSituation
                      ? "Avct %"
                      : (showTva ? "P.U. HT" : "Prix Unit.")),
                if (showTva && !isBL && !isSituation) _buildHeaderCell("TVA"),
                if (!isBL) _buildHeaderCell(showTva ? "Total HT" : "Total Net"),
              ]),
          ...chunk.map((l) => _buildRow(l,
              isSituation: isSituation, isBL: isBL, showTva: showTva)),
        ]);
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
      {bool isSituation = false, bool isBL = false, bool showTva = true}) {
    final bool isSpecial = ['titre', 'sous-titre', 'texte'].contains(l.type);

    pw.TextStyle? style;
    pw.BoxDecoration? decoration;

    if (l.type == 'titre') {
      style = pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: _primaryColor, fontSize: 12);
      decoration = const pw.BoxDecoration(color: _lightGrey);
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
      return pw.TableRow(decoration: decoration, children: [
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

    return pw.TableRow(children: [
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
      {bool isDevis = false, bool showTva = true}) {
    final remiseRational = (totalHt * remise) / Decimal.fromInt(100);
    final remiseMontant = remiseRational.toDecimal();

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(children: [
          if (showTva) _buildTotalRow("Total HT", totalHt),
          if (remise > Decimal.zero)
            _buildTotalRow("Remise ($remise%)", remiseMontant,
                isNegative: true),

          if (showTva) ...[
            pw.Divider(),
            _buildTotalRow("Total TVA", totalTva),
          ],

          pw.Divider(),
          _buildTotalRow(showTva ? "Total TTC" : "NET À PAYER", netAPayer,
              isBold: true),

          // Pour DEVIS uniquement : Acompte demandé
          if (isDevis && acompte > Decimal.zero) ...[
            pw.SizedBox(height: 5),
            _buildTotalRow("Acompte demandé", acompte),
          ]
        ]),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, Decimal? amount,
      {bool isBold = false, bool isNegative = false}) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontWeight:
                      isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          if (amount != null)
            pw.Text("${isNegative ? "- " : ""}${FormatUtils.currency(amount)}",
                style: pw.TextStyle(
                    fontWeight:
                        isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ]);
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
              headers: ["Date", "Mode", "Montant"],
              data: data,
              headerStyle:
                  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 8),
              border: null,
              headerDecoration: const pw.BoxDecoration(color: _lightGrey),
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
  }) {
    final _legalStyle =
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
                      style: _legalStyle,
                    ),

                  // Dispense d'immatriculation : SEULEMENT si non immatriculé
                  if (ent.typeEntreprise.isMicroEntrepreneur &&
                      !ent.estImmatricule &&
                      !(ent.mentionsLegales?.contains("Dispensé") ?? false))
                    pw.Text(
                      "Dispensé d'immatriculation au registre du commerce et des sociétés (RCS) et au répertoire des métiers (RM).",
                      style: _legalStyle,
                    ),

                  // Pénalités de retard (obligatoire CGI art. 289 / Code Commerce L441-10)
                  pw.Text(
                    "En cas de retard de paiement, une pénalité de ${ent.tauxPenalitesRetard.toStringAsFixed(2)}% par an sera appliquée (3 fois le taux d'intérêt légal minimum).",
                    style: _legalStyle,
                  ),

                  // Indemnité forfaitaire de recouvrement (obligatoire depuis 01/01/2013)
                  pw.Text(
                    "Indemnité forfaitaire pour frais de recouvrement en cas de retard de paiement : 40,00 €.",
                    style: _legalStyle,
                  ),

                  // Escompte
                  pw.Text(
                    ent.escompteApplicable
                        ? "Escompte pour paiement anticipé : selon conditions convenues."
                        : "Pas d'escompte pour paiement anticipé.",
                    style: _legalStyle,
                  ),
                ],
              ]),
        ),
        pw.SizedBox(width: 20),
        pw.Column(children: [
          if (signatureClient != null)
            pw.Column(children: [
              pw.Text("Bon pour accord",
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Image(pw.MemoryImage(signatureClient), width: 80, height: 40),
              pw.Text("Signé électroniquement",
                  style:
                      const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
            ])
          else
            _buildEmptySignatureZone(),
          pw.SizedBox(height: 20),
          if (signatureEnt != null)
            pw.Image(pw.MemoryImage(signatureEnt), width: 60)
        ])
      ],
    );
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
