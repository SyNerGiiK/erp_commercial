import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme_base.dart';

/// Thème par défaut : moderne avec bordure gauche bleue et header coloré.
class ModernePdfTheme extends PdfThemeBase {
  @override
  String get name => 'moderne';

  @override
  PdfColor get primaryColor => const PdfColor.fromInt(0xFF1E5572);
  @override
  PdfColor get accentColor => const PdfColor.fromInt(0xFF2A769E);
  @override
  PdfColor get lightGrey => const PdfColor.fromInt(0xFFF8F8F8);
  @override
  PdfColor get darkGrey => const PdfColor.fromInt(0xFF333333);
  @override
  PdfColor get tableHeaderBg => primaryColor;

  @override
  pw.Widget buildHeader(String? nomEntreprise, String docType, String ref,
      DateTime date, pw.MemoryImage? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo != null)
          pw.Image(logo, width: 80)
        else
          pw.Text(nomEntreprise ?? "ENTREPRISE",
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor)),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(docType,
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text("N° $ref", style: const pw.TextStyle(fontSize: 14)),
          pw.Text("Date : ${_formatDate(date)}"),
        ]),
      ],
    );
  }

  @override
  pw.Widget buildAddresses(
    String? nomEntreprise,
    String? nomGerant,
    String? adresse,
    String? cpVille,
    String? email,
    String? telephone,
    String? clientNom,
    String? clientContact,
    String? clientAdresse,
    String? clientCpVille,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("Émetteur",
              style: const pw.TextStyle(
                  fontSize: 10, color: PdfColor.fromInt(0xFF2A769E))),
          pw.Text(nomEntreprise ?? "",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(nomGerant ?? ""),
          pw.Text(adresse ?? ""),
          pw.Text(cpVille ?? ""),
          pw.Text(email ?? ""),
          pw.Text(telephone ?? ""),
        ]),
        pw.Container(
          width: 200,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
              color: lightGrey, borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Adressé à",
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColor.fromInt(0xFF2A769E))),
                pw.Text(clientNom ?? "",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (clientContact != null) pw.Text("Attn: $clientContact"),
                pw.Text(clientAdresse ?? ""),
                pw.Text(clientCpVille ?? ""),
              ]),
        ),
      ],
    );
  }

  @override
  pw.Widget buildTitle(String objet) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: pw.BoxDecoration(
          border:
              pw.Border(left: pw.BorderSide(color: primaryColor, width: 3))),
      child: pw.Text("Objet : $objet",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  @override
  pw.Widget buildTotalRow(String label, PdfColor? amountColor) {
    // Unused in current refactoring - totals are built declaratively in PdfService
    return pw.Container();
  }

  @override
  pw.Widget buildFooterMentions(String? nomEntreprise, String? siret,
      String? iban, String? bic, String? mentions, bool isTvaApplicable,
      {String? numeroTvaIntra}) {
    return pw.Column(children: [
      pw.Divider(color: lightGrey),
      pw.Text(
        "${nomEntreprise ?? ''} - SIRET: ${siret ?? ''}",
        style: const pw.TextStyle(
            fontSize: 8, color: PdfColor.fromInt(0xFF333333)),
      ),
      if (iban != null)
        pw.Text("IBAN: $iban - BIC: $bic",
            style: const pw.TextStyle(
                fontSize: 8, color: PdfColor.fromInt(0xFF333333)),
            textAlign: pw.TextAlign.center),
      if (mentions != null)
        pw.Text(mentions,
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),
      if (isTvaApplicable && numeroTvaIntra != null)
        pw.Text("TVA Intracommunautaire : $numeroTvaIntra",
            style: const pw.TextStyle(
                fontSize: 8, color: PdfColor.fromInt(0xFF333333))),
      pw.Text("Document généré par Artisan 3.0",
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
    ]);
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
