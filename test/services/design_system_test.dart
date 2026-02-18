import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/config/theme.dart';

void main() {
  group('AppTheme — Design System Sprint 9', () {
    group('statusColor', () {
      test('brouillon → textLight', () {
        expect(AppTheme.statusColor('brouillon'), AppTheme.textLight);
      });

      test('payee → accent (vert)', () {
        expect(AppTheme.statusColor('payee'), AppTheme.accent);
      });

      test('validee → secondary', () {
        expect(AppTheme.statusColor('validee'), AppTheme.secondary);
      });

      test('partielle → warning', () {
        expect(AppTheme.statusColor('partielle'), AppTheme.warning);
      });

      test('annulee → error', () {
        expect(AppTheme.statusColor('annulee'), AppTheme.error);
      });

      test('envoye → info', () {
        expect(AppTheme.statusColor('envoye'), AppTheme.info);
      });

      test('envoyee → info', () {
        expect(AppTheme.statusColor('envoyee'), AppTheme.info);
      });

      test('inconnu → textLight par défaut', () {
        expect(AppTheme.statusColor('xyz'), AppTheme.textLight);
      });
    });

    group('statusBackgroundColor', () {
      test('payee → accentSoft', () {
        expect(AppTheme.statusBackgroundColor('payee'), AppTheme.accentSoft);
      });

      test('partielle → warningSoft', () {
        expect(
            AppTheme.statusBackgroundColor('partielle'), AppTheme.warningSoft);
      });

      test('envoyee → infoSoft', () {
        expect(AppTheme.statusBackgroundColor('envoyee'), AppTheme.infoSoft);
      });

      test('validee → primarySoft', () {
        expect(AppTheme.statusBackgroundColor('validee'), AppTheme.primarySoft);
      });

      test('annulee → errorSoft', () {
        expect(AppTheme.statusBackgroundColor('annulee'), AppTheme.errorSoft);
      });
    });

    group('spacing constants', () {
      test('les constantes de spacing suivent la grille de 4px', () {
        expect(AppTheme.spacing4, 4);
        expect(AppTheme.spacing8, 8);
        expect(AppTheme.spacing12, 12);
        expect(AppTheme.spacing16, 16);
        expect(AppTheme.spacing24, 24);
        expect(AppTheme.spacing32, 32);
        expect(AppTheme.spacing48, 48);
      });
    });

    group('border radius', () {
      test('les constantes de rayon sont bien définies', () {
        expect(AppTheme.radiusSmall, 8);
        expect(AppTheme.radiusMedium, 12);
        expect(AppTheme.radiusLarge, 16);
        expect(AppTheme.radiusXLarge, 20);
        expect(AppTheme.radiusCircular, 50);
      });

      test('borderRadiusSmall retourne un BorderRadius', () {
        final br = AppTheme.borderRadiusSmall;
        expect(br, isA<BorderRadius>());
        expect(br.topLeft.x, AppTheme.radiusSmall);
      });
    });

    group('shadows', () {
      test('shadowSmall est une liste de BoxShadow', () {
        expect(AppTheme.shadowSmall, isA<List<BoxShadow>>());
        expect(AppTheme.shadowSmall, isNotEmpty);
      });

      test('shadowMedium a un blur > shadowSmall', () {
        expect(AppTheme.shadowMedium.first.blurRadius,
            greaterThan(AppTheme.shadowSmall.first.blurRadius));
      });

      test('shadowLarge a un blur > shadowMedium', () {
        expect(AppTheme.shadowLarge.first.blurRadius,
            greaterThan(AppTheme.shadowMedium.first.blurRadius));
      });
    });
  });

  group('AppBadge.fromStatus', () {
    test('crée un badge pour "payee"', () {
      final badge = AppBadge.fromStatus('payee');
      expect(badge.label, 'Payée');
      expect(badge.color, AppTheme.accent);
      expect(badge.backgroundColor, AppTheme.accentSoft);
    });

    test('crée un badge pour "brouillon"', () {
      final badge = AppBadge.fromStatus('brouillon');
      expect(badge.label, 'Brouillon');
      expect(badge.color, AppTheme.textLight);
    });

    test('crée un badge pour "validee"', () {
      final badge = AppBadge.fromStatus('validee');
      expect(badge.label, 'Validée');
      expect(badge.color, AppTheme.secondary);
    });

    test('permet un label personnalisé', () {
      final badge = AppBadge.fromStatus('payee', label: 'Soldée');
      expect(badge.label, 'Soldée');
      expect(badge.color, AppTheme.accent);
    });

    test('gère un statut inconnu gracieusement', () {
      final badge = AppBadge.fromStatus('custom_status');
      expect(badge.label, 'custom_status');
      expect(badge.color, AppTheme.textLight);
    });
  });
}
