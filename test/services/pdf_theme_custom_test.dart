import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:erp_commercial/services/pdf_themes/moderne_theme.dart';
import 'package:erp_commercial/services/pdf_themes/classique_theme.dart';
import 'package:erp_commercial/services/pdf_themes/minimaliste_theme.dart';
import 'package:erp_commercial/services/pdf_themes/pdf_theme_base.dart';

void main() {
  group('PdfThemeBase — setCustomPrimaryColor (Sprint 9.3)', () {
    late PdfThemeBase theme;

    setUp(() {
      theme = ModernePdfTheme();
    });

    test('primaryColor retourne defaultPrimaryColor si pas de custom', () {
      expect(theme.primaryColor, theme.defaultPrimaryColor);
    });

    test('setCustomPrimaryColor applique une couleur hex valide', () {
      theme.setCustomPrimaryColor('FF5733');

      // Le primaryColor ne doit plus être le default
      expect(theme.primaryColor, isNot(theme.defaultPrimaryColor));
      // Vérifier la couleur parsée (FFFF5733)
      expect(theme.primaryColor, const PdfColor.fromInt(0xFFFF5733));
    });

    test('setCustomPrimaryColor gère le préfixe #', () {
      theme.setCustomPrimaryColor('#2E86C1');
      expect(theme.primaryColor, const PdfColor.fromInt(0xFF2E86C1));
    });

    test('setCustomPrimaryColor null → garde le default', () {
      theme.setCustomPrimaryColor(null);
      expect(theme.primaryColor, theme.defaultPrimaryColor);
    });

    test('setCustomPrimaryColor chaîne vide → garde le default', () {
      theme.setCustomPrimaryColor('');
      expect(theme.primaryColor, theme.defaultPrimaryColor);
    });

    test('setCustomPrimaryColor hex invalide → garde le default', () {
      theme.setCustomPrimaryColor('ZZZZZZ');
      expect(theme.primaryColor, theme.defaultPrimaryColor);
    });

    test('tableHeaderBg utilise primaryColor (custom ou default)', () {
      // Par défaut
      expect(theme.tableHeaderBg, theme.defaultPrimaryColor);

      // Après custom
      theme.setCustomPrimaryColor('E74C3C');
      expect(theme.tableHeaderBg, const PdfColor.fromInt(0xFFE74C3C));
    });
  });

  group('Chaque thème concret fournit un nom et des couleurs', () {
    test('ModernePdfTheme', () {
      final theme = ModernePdfTheme();
      expect(theme.name, 'moderne');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
      expect(theme.accentColor, isA<PdfColor>());
    });

    test('ClassiquePdfTheme', () {
      final theme = ClassiquePdfTheme();
      expect(theme.name, 'classique');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
    });

    test('MinimalistePdfTheme', () {
      final theme = MinimalistePdfTheme();
      expect(theme.name, 'minimaliste');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
    });
  });

  group('Custom color fonctionne identiquement sur chaque thème', () {
    for (final entry in {
      'moderne': ModernePdfTheme(),
      'classique': ClassiquePdfTheme(),
      'minimaliste': MinimalistePdfTheme(),
    }.entries) {
      test('${entry.key} — custom override puis reset', () {
        final theme = entry.value;

        theme.setCustomPrimaryColor('27AE60');
        expect(theme.primaryColor, const PdfColor.fromInt(0xFF27AE60));

        // On ne peut pas "reset" → on peut renvoyer null
        // mais vu l'implémentation, un setCustomPrimaryColor(null) ne remet pas
        // car le code ne set pas _customPrimaryColor = null si hexColor est null.
        // Vérifions que c'est cohérent
        theme.setCustomPrimaryColor(null);
        // Le custom précédent reste en place (design actuel)
        expect(theme.primaryColor, const PdfColor.fromInt(0xFF27AE60));
      });
    }
  });
}
