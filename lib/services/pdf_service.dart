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
import '../models/enums/entreprise_enums.dart';
import '../utils/format_utils.dart';

class PdfService {
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF1E5572);
  static const PdfColor _accentColor = PdfColor.fromInt(0xFF2A769E);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF8F8F8);
  static const PdfColor _darkGrey = PdfColor.fromInt(0xFF333333);

  static Future<pw.ThemeData> _loadTheme() async {
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontItalic = await PdfGoogleFonts.openSansItalic();

    return pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );
  }

  static Future<Uint8List?> _downloadImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      // Ignorer
    }
    return null;
  }

  // --- GÉNÉRATION DOCUMENTS (Devis, BC, BL) ---
  static Future<Uint8List> generateDocument(
      Devis devis, Client client, ProfilEntreprise? entreprise,
      {String docType = "DEVIS"}) async {
    final theme = await _loadTheme();

    final logoBytes = await _downloadImage(entreprise?.logoUrl);
    final signatureEntBytes = await _downloadImage(entreprise?.signatureUrl);
    final signatureClientBytes = await _downloadImage(devis.signatureUrl);

    final isBL = docType == "BON DE LIVRAISON";

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(entreprise, docType, devis.numeroDevis,
              devis.dateEmission, logoBytes),
          pw.SizedBox(height: 30),
          _buildAddresses(entreprise, client),
          pw.SizedBox(height: 30),
          _buildTitle(devis.objet),
          pw.SizedBox(height: 20),
          _buildLignesTable(devis.lignes, isBL: isBL), // Hide prices if BL
          pw.SizedBox(height: 20),
          if (!isBL) // Hide totals if BL
            _buildTotals(devis.totalHt, devis.remiseTaux, devis.acompteMontant,
                isDevis: true),
          pw.SizedBox(height: 30),
          _buildFooterSignatures(devis.notesPubliques, entreprise,
              signatureEntBytes, signatureClientBytes),
        ],
        footer: (context) => _buildFooterMentions(entreprise),
      ),
    );

    return pdf.save();
  }

  // Deprecated wrapper for backward compatibility
  static Future<Uint8List> generateDevis(
          Devis devis, Client client, ProfilEntreprise? ent) =>
      generateDocument(devis, client, ent, docType: "DEVIS");

  // --- GÉNÉRATION FACTURE ---
  static Future<Uint8List> generateFacture(
      Facture facture, Client client, ProfilEntreprise? entreprise) async {
    final theme = await _loadTheme();

    final logoBytes = await _downloadImage(entreprise?.logoUrl);
    final signatureEntBytes = await _downloadImage(entreprise?.signatureUrl);

    final pdf = pw.Document(theme: theme);

    final montantRemiseRational =
        (facture.totalHt * facture.remiseTaux) / Decimal.fromInt(100);
    final montantRemise = montantRemiseRational.toDecimal();
    final netAPayer = facture.totalHt - montantRemise; // Decimal - Decimal

    final signatureClientBytes = await _downloadImage(facture.signatureUrl);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(
              entreprise,
              facture.type == 'avoir' ? "AVOIR" : "FACTURE",
              facture.numeroFacture,
              facture.dateEmission,
              logoBytes),
          pw.SizedBox(height: 30),
          _buildAddresses(entreprise, client),
          pw.SizedBox(height: 30),
          _buildTitle(facture.objet),
          pw.SizedBox(height: 20),
          _buildLignesTable(facture.lignes,
              isSituation: facture.type == 'situation'),
          pw.SizedBox(height: 20),
          _buildTotals(
              facture.totalHt, facture.remiseTaux, facture.acompteDejaRegle),
          pw.SizedBox(height: 30),
          _buildPaiementsTable(facture.paiements, netAPayer),
          pw.SizedBox(height: 20),
          _buildFooterSignatures(facture.notesPubliques, entreprise,
              signatureEntBytes, signatureClientBytes),
        ],
        footer: (context) => _buildFooterMentions(entreprise),
      ),
    );

    return pdf.save();
  }

  // --- COMPOSANTS PDF ---

  static pw.Widget _buildHeader(ProfilEntreprise? ent, String type, String ref,
      DateTime date, Uint8List? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo != null)
          pw.Image(pw.MemoryImage(logo), width: 80)
        else
          pw.Text(ent?.nomEntreprise ?? "ENTREPRISE",
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor)),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(type,
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text("N° $ref", style: const pw.TextStyle(fontSize: 14)),
          pw.Text("Date : ${DateFormat('dd/MM/yyyy').format(date)}"),
        ])
      ],
    );
  }

  static pw.Widget _buildAddresses(ProfilEntreprise? ent, Client client) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("Émetteur",
              style: const pw.TextStyle(fontSize: 10, color: _accentColor)),
          pw.Text(ent?.nomEntreprise ?? "",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(ent?.nomGerant ?? ""),
          pw.Text(ent?.adresse ?? ""),
          pw.Text("${ent?.codePostal} ${ent?.ville}"),
          pw.Text(ent?.email ?? ""),
          pw.Text(ent?.telephone ?? ""),
        ]),
        pw.Container(
          width: 200,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
              color: _lightGrey, borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Adressé à",
                    style:
                        const pw.TextStyle(fontSize: 10, color: _accentColor)),
                pw.Text(client.nomComplet,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (client.nomContact != null)
                  pw.Text("Attn: ${client.nomContact}"),
                pw.Text(client.adresse),
                pw.Text("${client.codePostal} ${client.ville}"),
              ]),
        )
      ],
    );
  }

  static pw.Widget _buildTitle(String objet) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: const pw.BoxDecoration(
          border:
              pw.Border(left: pw.BorderSide(color: _primaryColor, width: 3))),
      child: pw.Text("Objet : $objet",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildLignesTable(dynamic lignes,
      {bool isSituation = false, bool isBL = false}) {
    // 1. Split by Saut de Page
    final chunks = <List<dynamic>>[];
    var currentChunk = <dynamic>[];

    for (var l in lignes) {
      if (l.type == 'saut_page') {
        chunks.add(currentChunk);
        currentChunk = [];
      } else {
        currentChunk.add(l);
      }
    }
    chunks.add(currentChunk);

    if (chunks.isEmpty) return pw.Container();

    // 2. Build Widgets
    return pw.Column(
        children: List.generate(chunks.length, (index) {
      final chunk = chunks[index];
      if (chunk.isEmpty) return pw.Container();

      final table =
          _buildChunkTable(chunk, isSituation: isSituation, isBL: isBL);

      if (index < chunks.length - 1) {
        return pw.Column(children: [table, pw.NewPage()]);
      }
      return table;
    }));
  }

  static pw.Widget _buildChunkTable(List<dynamic> chunk,
      {bool isSituation = false, bool isBL = false}) {
    return pw.Table(
        border: const pw.TableBorder(
            bottom: pw.BorderSide(color: _lightGrey, width: 0.5)),
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1),
        },
        children: [
          // Header
          pw.TableRow(
              decoration: const pw.BoxDecoration(color: _primaryColor),
              children: [
                _buildHeaderCell("Désignation",
                    alignment: pw.Alignment.centerLeft),
                _buildHeaderCell(isSituation ? "Marché" : "Qté"),
                if (!isBL) _buildHeaderCell(isSituation ? "Avct %" : "P.U."),
                if (!isBL) _buildHeaderCell("Total"),
              ]),
          // Rows
          ...chunk
              .map((l) => _buildRow(l, isSituation: isSituation, isBL: isBL)),
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
      {bool isSituation = false, bool isBL = false}) {
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
        if (!isBL) pw.Container(),
      ]);
    }

    // Normal Article
    String col1; // Qté ou Marché
    String col2; // P.U. ou Avct %

    if (isSituation) {
      // Col 1: Marché = Qte * PU
      final marche = l.quantite * l.prixUnitaire;
      col1 = FormatUtils.currency(marche);
      // Col 2: Avancement
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
      if (!isBL)
        pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(FormatUtils.currency(l.totalLigne),
                textAlign: pw.TextAlign.right)),
    ]);
  }

  static pw.Widget _buildTotals(
      Decimal totalHt, Decimal remise, Decimal acompte,
      {bool isDevis = false}) {
    // FIX DECIMAL: Ensure division converts to Decimal
    final remiseMontantRational = (totalHt * remise) / Decimal.fromInt(100);
    final remiseMontant = remiseMontantRational.toDecimal();
    final netAPayer = totalHt - remiseMontant; // Decimal - Decimal

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(children: [
          _buildTotalRow("Total HT", totalHt),
          if (remise > Decimal.zero)
            _buildTotalRow("Remise ($remise%)", remiseMontant,
                isNegative: true),
          pw.Divider(),
          _buildTotalRow("NET À PAYER", netAPayer, isBold: true),

          // Pour DEVIS uniquement : Acompte demandé
          if (isDevis && acompte > Decimal.zero)
            _buildTotalRow("Acompte demandé", acompte),
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
      List<Paiement> paiements, Decimal netAPayer) {
    if (paiements.isEmpty) return pw.Container();

    final totalRegle =
        paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);
    final reste = netAPayer - totalRegle;

    final data = paiements
        .map((p) => [
              DateFormat('dd/MM/yyyy').format(p.datePaiement),
              p.typePaiement.toUpperCase(),
              FormatUtils.currency(p.montant),
            ])
        .toList();

    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text("Règlements reçus",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      pw.SizedBox(height: 5),
      pw.TableHelper.fromTextArray(
        headers: ["Date", "Mode", "Montant"],
        data: data,
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        border: null,
        headerDecoration: const pw.BoxDecoration(color: _lightGrey),
      ),
      pw.SizedBox(height: 10),
      // RECAP à droite
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Container(
          width: 200,
          child: pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total réglé",
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(FormatUtils.currency(totalRegle),
                      style: const pw.TextStyle(fontSize: 10)),
                ]),
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

  static pw.Widget _buildFooterSignatures(String? notes, ProfilEntreprise? ent,
      Uint8List? signatureEnt, Uint8List? signatureClient) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (notes != null && notes.isNotEmpty) ...[
                  pw.Text("Notes :",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
                ],
                // MENTIONS LÉGALES OBLIGATOIRES (MICRO-ENTREPRENEUR)
                if (ent?.typeEntreprise.isMicroEntrepreneur == true) ...[
                  pw.SizedBox(height: 10),
                  if (!(ent?.mentionsLegales?.contains("TVA non applicable") ??
                      false))
                    pw.Text(
                      "TVA non applicable, art. 293 B du CGI.",
                      style: pw.TextStyle(
                          fontSize: 8, fontStyle: pw.FontStyle.italic),
                    ),
                  // Autre mention obligatoire dispenses
                  if (!(ent?.mentionsLegales?.contains("Dispensé") ?? false))
                    pw.Text(
                      "Dispensé d'immatriculation au registre du commerce et des sociétés (RCS) et au répertoire des métiers (RM).",
                      style: pw.TextStyle(
                          fontSize: 8, fontStyle: pw.FontStyle.italic),
                    ),
                ]
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

  static pw.Widget _buildFooterMentions(ProfilEntreprise? ent) {
    return pw.Column(children: [
      pw.Divider(color: _lightGrey),
      pw.Text(
        "${ent?.nomEntreprise ?? ''} - SIRET: ${ent?.siret ?? ''}",
        style: const pw.TextStyle(fontSize: 8, color: _darkGrey),
      ),
      if (ent?.iban != null)
        pw.Text("IBAN: ${ent?.iban} - BIC: ${ent?.bic}",
            style: const pw.TextStyle(fontSize: 8, color: _darkGrey)),
      if (ent?.mentionsLegales != null)
        pw.Text(ent!.mentionsLegales!,
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),

      // MENTIONS TVA
      if (ent?.tvaApplicable == true && ent?.numeroTvaIntra != null)
        pw.Text("TVA Intracommunautaire : ${ent!.numeroTvaIntra}",
            style: const pw.TextStyle(fontSize: 8, color: _darkGrey)),

      if (ent?.tvaApplicable == false)
        pw.Text("TVA non applicable, art. 293 B du CGI",
            style: const pw.TextStyle(fontSize: 8, color: _darkGrey)),

      pw.Text("Document généré par Artisan 3.0",
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
    ]);
  }
}
