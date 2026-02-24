// ignore_for_file: prefer_const_constructors
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme_base.dart';

/// Thème classique : look traditionnel, couleur sobre, encadrements nets.
class ClassiquePdfTheme extends PdfThemeBase {
  @override
  String get name => 'classique';

  @override
  PdfColor get defaultPrimaryColor => PdfColor.fromInt(0xFF2C3E50);
  @override
  PdfColor get accentColor => PdfColor.fromInt(0xFF34495E);
  @override
  PdfColor get lightGrey => PdfColor.fromInt(0xFFF5F5F5);
  @override
  PdfColor get darkGrey => PdfColor.fromInt(0xFF2C3E50);

  @override
  pw.Widget buildHeader(String? nomEntreprise, String docType, String ref,
      DateTime date, pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (logo != null)
              pw.Image(logo, width: 70)
            else
              pw.Text(nomEntreprise ?? "ENTREPRISE",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
                color: primaryColor, borderRadius: pw.BorderRadius.circular(2)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(docType,
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.Text("Réf: $ref",
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.white)),
                  pw.Text(_formatDate(date),
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.white)),
                ]),
          ),
        ],
      ),
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
        pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: primaryColor, width: 2))),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("DE :",
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor)),
                pw.Text(nomEntreprise ?? "",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(nomGerant ?? ""),
                pw.Text(adresse ?? ""),
                pw.Text(cpVille ?? ""),
                pw.Text(email ?? ""),
              ]),
        ),
        pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: primaryColor, width: 2))),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("À :",
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor)),
                pw.Text(clientNom ?? "",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (clientContact != null) pw.Text(clientContact),
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
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: lightGrey,
        border: pw.Border.all(color: primaryColor, width: 0.5),
      ),
      child: pw.Text("Objet : $objet",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  pw.Widget buildTotalRow(String label, PdfColor? amountColor) {
    return pw.Container();
  }

  @override
  pw.Widget buildFooterMentions(String? nomEntreprise, String? siret,
      String? iban, String? bic, String? mentions, bool isTvaApplicable,
      {String? numeroTvaIntra, pw.MemoryImage? logoFooter}) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(
                  color: PdfColor.fromInt(0xFF2C3E50), width: 1))),
      child: pw.Column(children: [
        if (logoFooter != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Image(logoFooter, width: 60, height: 30),
          ),
        pw.Text(
          "${nomEntreprise ?? ''} | SIRET: ${siret ?? ''}",
          style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF2C3E50)),
        ),
        if (iban != null)
          pw.Text("IBAN: $iban | BIC: $bic",
              style: pw.TextStyle(
                  fontSize: 8, color: PdfColor.fromInt(0xFF2C3E50))),
        if (mentions != null)
          pw.Text(mentions,
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey),
              textAlign: pw.TextAlign.center),
        if (isTvaApplicable && numeroTvaIntra != null)
          pw.Text("TVA Intracommunautaire : $numeroTvaIntra",
              style: pw.TextStyle(
                  fontSize: 8, color: PdfColor.fromInt(0xFF2C3E50))),
        pw.Text("Document généré par Artisan 3.0",
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
      ]),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
