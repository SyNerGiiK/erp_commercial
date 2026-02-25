import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:erp_commercial/models/pdf_design_config.dart';
import 'package:erp_commercial/services/pdf_themes/moderne_theme.dart';
import 'package:erp_commercial/services/pdf_themes/classique_theme.dart';
import 'package:erp_commercial/services/pdf_themes/minimaliste_theme.dart';
import 'package:erp_commercial/services/pdf_themes/pdf_theme_base.dart';

void main() {
  group('PdfThemeBase — custom colors via PdfDesignConfig', () {
    late PdfThemeBase theme;

    setUp(() {
      final config = PdfDesignConfig.defaultConfig('test_id')
          .copyWith(primaryColor: '#FF5733');
      theme = ModernePdfTheme(config);
    });

    test('primaryColor utilise la configuration fournie', () {
      // Vérifier la couleur parsée (FFFF5733)
      expect(theme.primaryColor, const PdfColor.fromInt(0xFFFF5733));
    });

    test('primaryColor gère le préfixe #', () {
      final config = PdfDesignConfig.defaultConfig('test_id')
          .copyWith(primaryColor: '#2E86C1');
      theme = ModernePdfTheme(config);
      expect(theme.primaryColor, const PdfColor.fromInt(0xFF2E86C1));
    });

    test('primaryColor hex invalide → fallback vers default', () {
      final config = PdfDesignConfig.defaultConfig('test_id')
          .copyWith(primaryColor: 'ZZZZZZ');
      theme = ModernePdfTheme(config);
      expect(theme.primaryColor, theme.defaultPrimaryColor);
    });

    test('tableHeaderBg utilise primaryColor', () {
      expect(theme.tableHeaderBg, const PdfColor.fromInt(0xFFFF5733));
    });
  });

  group('Chaque thème concret nécessite une config locale', () {
    final defaultConfig = PdfDesignConfig.defaultConfig('test_id');
    test('ModernePdfTheme', () {
      final theme = ModernePdfTheme(defaultConfig);
      expect(theme.name, 'moderne');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
      expect(theme.accentColor, isA<PdfColor>());
    });

    test('ClassiquePdfTheme', () {
      final theme = ClassiquePdfTheme(defaultConfig);
      expect(theme.name, 'classique');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
    });

    test('MinimalistePdfTheme', () {
      final theme = MinimalistePdfTheme(defaultConfig);
      expect(theme.name, 'minimaliste');
      expect(theme.defaultPrimaryColor, isA<PdfColor>());
    });
  });

  group('Custom color fonctionne identiquement sur chaque thème', () {
    final config = PdfDesignConfig.defaultConfig('test_id')
        .copyWith(primaryColor: '#27AE60');
    for (final entry in {
      'moderne': ModernePdfTheme(config),
      'classique': ClassiquePdfTheme(config),
      'minimaliste': MinimalistePdfTheme(config),
    }.entries) {
      test('${entry.key} — custom override', () {
        final theme = entry.value;
        expect(theme.primaryColor, const PdfColor.fromInt(0xFF27AE60));
      });
    }
  });
}
