import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme_base.dart';

/// Thème minimaliste : épuré, beaucoup de blanc, lignes fines.
class MinimalistePdfTheme extends PdfThemeBase {
  @override
  String get name => 'minimaliste';

  @override
  PdfColor get primaryColor => const PdfColor.fromInt(0xFF555555);
  @override
  PdfColor get accentColor => const PdfColor.fromInt(0xFF888888);
  @override
  PdfColor get lightGrey => const PdfColor.fromInt(0xFFFAFAFA);
  @override
  PdfColor get darkGrey => const PdfColor.fromInt(0xFF444444);
  @override
  PdfColor get tableHeaderBg => const PdfColor.fromInt(0xFF555555);

  @override
  pw.Widget buildHeader(String? nomEntreprise, String docType, String ref,
      DateTime date, pw.MemoryImage? logo) {
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          if (logo != null)
            pw.Image(logo, width: 60)
          else
            pw.Text(nomEntreprise ?? "",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(docType,
              style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor)),
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Divider(color: primaryColor, thickness: 0.5),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Text("$ref  •  ${_formatDate(date)}",
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ]),
    ]);
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
          pw.Text(nomEntreprise ?? "",
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(nomGerant ?? "",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(adresse ?? "", style: const pw.TextStyle(fontSize: 9)),
          pw.Text(cpVille ?? "", style: const pw.TextStyle(fontSize: 9)),
          pw.Text(email ?? "",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(clientNom ?? "",
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          if (clientContact != null)
            pw.Text(clientContact,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(clientAdresse ?? "", style: const pw.TextStyle(fontSize: 9)),
          pw.Text(clientCpVille ?? "", style: const pw.TextStyle(fontSize: 9)),
        ]),
      ],
    );
  }

  @override
  pw.Widget buildTitle(String objet) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(objet,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: primaryColor)),
    );
  }

  @override
  pw.Widget buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 3),
      child: pw.Text(title.toUpperCase(),
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
              letterSpacing: 1.5)),
    );
  }

  @override
  pw.Widget buildTotalRow(String label, PdfColor? amountColor) {
    return pw.Container();
  }

  @override
  pw.Widget buildFooterMentions(String? nomEntreprise, String? siret,
      String? iban, String? bic, String? mentions, bool isTvaApplicable,
      {String? numeroTvaIntra}) {
    return pw.Column(children: [
      pw.Divider(color: primaryColor, thickness: 0.3),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text(
          [
            nomEntreprise ?? '',
            if (siret != null && siret.isNotEmpty) 'SIRET $siret',
            if (iban != null) 'IBAN $iban',
          ].join('  •  '),
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
        ),
      ]),
      if (mentions != null)
        pw.Text(mentions,
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey),
            textAlign: pw.TextAlign.center),
      if (isTvaApplicable && numeroTvaIntra != null)
        pw.Text("TVA Intra : $numeroTvaIntra",
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
    ]);
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
