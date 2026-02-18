import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Classe abstraite définissant le contrat pour tous les thèmes PDF.
/// Chaque thème fournit ses propres couleurs, mise en page et styles.
abstract class PdfThemeBase {
  /// Identifiant du thème
  String get name;

  // === COULEURS ===
  PdfColor get primaryColor;
  PdfColor get accentColor;
  PdfColor get lightGrey;
  PdfColor get darkGrey;
  PdfColor get tableHeaderBg;
  PdfColor get tableHeaderText => PdfColors.white;
  PdfColor get sectionTitleBg => lightGrey;
  PdfColor get sectionTitleColor => primaryColor;

  // === HEADER ===
  pw.Widget buildHeader(String? nomEntreprise, String docType, String ref,
      DateTime date, pw.MemoryImage? logo);

  // === ADRESSES ===
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
  );

  // === TITRE ===
  pw.Widget buildTitle(String objet);

  // === TABLE DES LIGNES ===
  pw.Widget buildHeaderCell(String text,
      {pw.Alignment alignment = pw.Alignment.centerRight}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: tableHeaderText),
          textAlign: alignment == pw.Alignment.centerRight
              ? pw.TextAlign.right
              : pw.TextAlign.left),
    );
  }

  pw.Widget buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      color: sectionTitleBg,
      padding: const pw.EdgeInsets.all(5),
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(title.toUpperCase(),
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: sectionTitleColor,
              fontSize: 10)),
    );
  }

  pw.BoxDecoration get tableHeaderDecoration =>
      pw.BoxDecoration(color: tableHeaderBg);

  // === TOTAUX ===
  pw.Widget buildTotalRow(String label, PdfColor? amountColor);

  // === FOOTER ===
  pw.Widget buildFooterMentions(String? nomEntreprise, String? siret,
      String? iban, String? bic, String? mentions, bool isTvaApplicable,
      {String? numeroTvaIntra});
}
