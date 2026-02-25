export 'pdf_theme_base.dart';
export 'moderne_theme.dart';
export 'classique_theme.dart';
export 'minimaliste_theme.dart';

import '../../models/pdf_design_config.dart';
import '../../models/enums/entreprise_enums.dart';
import 'pdf_theme_base.dart';
import 'moderne_theme.dart';
import 'classique_theme.dart';
import 'minimaliste_theme.dart';

/// Factory pour résoudre le thème PDF à partir de l'enum PdfTheme du profil.
class PdfThemeFactory {
  static PdfThemeBase resolve(PdfDesignConfig config, PdfTheme themeFallback) {
    switch (themeFallback) {
      case PdfTheme.moderne:
        return ModernePdfTheme(config);
      case PdfTheme.classique:
        return ClassiquePdfTheme(config);
      case PdfTheme.minimaliste:
        return MinimalistePdfTheme(config);
    }
  }
}
