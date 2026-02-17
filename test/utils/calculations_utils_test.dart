import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/utils/calculations_utils.dart';

void main() {
  group('CalculationsUtils - calculateCharges', () {
    test('calcule des charges URSSAF correctement', () {
      final base = Decimal.parse('10000');
      final taux = Decimal.parse('22');
      final result = CalculationsUtils.calculateCharges(base, taux);
      expect(result, Decimal.parse('2200'));
    });

    test('calcule des charges avec taux décimal', () {
      final base = Decimal.parse('5000');
      final taux = Decimal.parse('12.5');
      final result = CalculationsUtils.calculateCharges(base, taux);
      expect(result, Decimal.parse('625'));
    });

    test('retourne zéro si base est zéro', () {
      final result = CalculationsUtils.calculateCharges(
        Decimal.zero,
        Decimal.parse('22'),
      );
      expect(result, Decimal.zero);
    });

    test('retourne zéro si taux est zéro', () {
      final result = CalculationsUtils.calculateCharges(
        Decimal.parse('10000'),
        Decimal.zero,
      );
      expect(result, Decimal.zero);
    });

    test('calcule des charges avec montants précis (pas d\'arrondi double)',
        () {
      final base = Decimal.parse('1234.56');
      final taux = Decimal.parse('15.75');
      final result = CalculationsUtils.calculateCharges(base, taux);
      // 1234.56 * 15.75 / 100 = 194.4432
      expect(result, Decimal.parse('194.4432'));
    });
  });

  group('CalculationsUtils - calculateMargeNette', () {
    test('calcule une marge nette positive', () {
      final vente = Decimal.parse('1000');
      final achat = Decimal.parse('600');
      final charges = Decimal.parse('100');
      final result =
          CalculationsUtils.calculateMargeNette(vente, achat, charges);
      expect(result, Decimal.parse('300'));
    });

    test('calcule une marge nette négative (perte)', () {
      final vente = Decimal.parse('500');
      final achat = Decimal.parse('600');
      final charges = Decimal.parse('100');
      final result =
          CalculationsUtils.calculateMargeNette(vente, achat, charges);
      expect(result, Decimal.parse('-200'));
    });

    test('calcule une marge nulle', () {
      final vente = Decimal.parse('1000');
      final achat = Decimal.parse('800');
      final charges = Decimal.parse('200');
      final result =
          CalculationsUtils.calculateMargeNette(vente, achat, charges);
      expect(result, Decimal.zero);
    });

    test('gère les montants avec décimales', () {
      final vente = Decimal.parse('1234.56');
      final achat = Decimal.parse('789.12');
      final charges = Decimal.parse('123.45');
      final result =
          CalculationsUtils.calculateMargeNette(vente, achat, charges);
      expect(result, Decimal.parse('321.99'));
    });
  });

  group('CalculationsUtils - calculateTotalLigne', () {
    test('calcule un total ligne simple', () {
      final qte = Decimal.parse('10');
      final pu = Decimal.parse('50');
      final result = CalculationsUtils.calculateTotalLigne(qte, pu);
      expect(result, Decimal.parse('500'));
    });

    test('calcule un total avec quantité décimale', () {
      final qte = Decimal.parse('2.5');
      final pu = Decimal.parse('100');
      final result = CalculationsUtils.calculateTotalLigne(qte, pu);
      expect(result, Decimal.parse('250'));
    });

    test('calcule un total en situation avec avancement 50%', () {
      final qte = Decimal.parse('10');
      final pu = Decimal.parse('100');
      final avancement = Decimal.parse('50');
      final result = CalculationsUtils.calculateTotalLigne(
        qte,
        pu,
        isSituation: true,
        avancement: avancement,
      );
      expect(result, Decimal.parse('500'));
    });

    test('calcule un total en situation avec avancement 100%', () {
      final qte = Decimal.parse('10');
      final pu = Decimal.parse('100');
      final avancement = Decimal.parse('100');
      final result = CalculationsUtils.calculateTotalLigne(
        qte,
        pu,
        isSituation: true,
        avancement: avancement,
      );
      expect(result, Decimal.parse('1000'));
    });

    test('calcule un total en situation sans avancement (défaut 100%)', () {
      final qte = Decimal.parse('5');
      final pu = Decimal.parse('200');
      final result = CalculationsUtils.calculateTotalLigne(
        qte,
        pu,
        isSituation: true,
      );
      expect(result, Decimal.parse('1000'));
    });

    test('calcule un total en situation avec avancement partiel', () {
      final qte = Decimal.parse('8');
      final pu = Decimal.parse('75.50');
      final avancement = Decimal.parse('25');
      final result = CalculationsUtils.calculateTotalLigne(
        qte,
        pu,
        isSituation: true,
        avancement: avancement,
      );
      // 8 * 75.50 * 25 / 100 = 151
      expect(result, Decimal.parse('151'));
    });
  });

  group('CalculationsUtils - calculateAcompteFromTaux', () {
    test('calcule un acompte de 30%', () {
      final totalTTC = Decimal.parse('1000');
      final taux = Decimal.parse('30');
      final result = CalculationsUtils.calculateAcompteFromTaux(totalTTC, taux);
      expect(result, Decimal.parse('300'));
    });

    test('calcule un acompte avec taux décimal', () {
      final totalTTC = Decimal.parse('2000');
      final taux = Decimal.parse('12.5');
      final result = CalculationsUtils.calculateAcompteFromTaux(totalTTC, taux);
      expect(result, Decimal.parse('250'));
    });

    test('retourne zéro si totalTTC est zéro', () {
      final result = CalculationsUtils.calculateAcompteFromTaux(
        Decimal.zero,
        Decimal.parse('30'),
      );
      expect(result, Decimal.zero);
    });

    test('retourne zéro si taux est zéro', () {
      final result = CalculationsUtils.calculateAcompteFromTaux(
        Decimal.parse('1000'),
        Decimal.zero,
      );
      expect(result, Decimal.zero);
    });

    test('calcule un acompte de 100%', () {
      final totalTTC = Decimal.parse('500');
      final taux = Decimal.parse('100');
      final result = CalculationsUtils.calculateAcompteFromTaux(totalTTC, taux);
      expect(result, Decimal.parse('500'));
    });
  });

  group('CalculationsUtils - calculateTauxFromMontant', () {
    test('calcule un taux à partir d\'un montant (30%)', () {
      final totalTTC = Decimal.parse('1000');
      final montant = Decimal.parse('300');
      final result =
          CalculationsUtils.calculateTauxFromMontant(totalTTC, montant);
      expect(result, Decimal.parse('30'));
    });

    test('calcule un taux décimal', () {
      final totalTTC = Decimal.parse('2000');
      final montant = Decimal.parse('250');
      final result =
          CalculationsUtils.calculateTauxFromMontant(totalTTC, montant);
      expect(result, Decimal.parse('12.5'));
    });

    test('retourne zéro si totalTTC est zéro', () {
      final result = CalculationsUtils.calculateTauxFromMontant(
        Decimal.zero,
        Decimal.parse('100'),
      );
      expect(result, Decimal.zero);
    });

    test('calcule 100% pour un acompte total', () {
      final totalTTC = Decimal.parse('500');
      final montant = Decimal.parse('500');
      final result =
          CalculationsUtils.calculateTauxFromMontant(totalTTC, montant);
      expect(result, Decimal.parse('100'));
    });

    test('calcule un taux pour un montant partiel avec décimales', () {
      final totalTTC = Decimal.parse('1234.56');
      final montant = Decimal.parse('123.456');
      final result =
          CalculationsUtils.calculateTauxFromMontant(totalTTC, montant);
      // 123.456 / 1234.56 * 100 ≈ 10
      expect(result.toDouble(), closeTo(10, 0.01));
    });
  });

  group('CalculationsUtils - Intégration (calculs combinés)', () {
    test('calcule acompte puis retrouve le taux', () {
      final totalTTC = Decimal.parse('1500');
      final tauxInitial = Decimal.parse('25');

      final acompte =
          CalculationsUtils.calculateAcompteFromTaux(totalTTC, tauxInitial);
      final tauxRecalcule =
          CalculationsUtils.calculateTauxFromMontant(totalTTC, acompte);

      expect(tauxRecalcule, tauxInitial);
    });

    test('scénario complet: vente avec marge et charges', () {
      final prixVente = Decimal.parse('1000');
      final coutAchat = Decimal.parse('600');
      final tauxCharges = Decimal.parse('22');

      final charges =
          CalculationsUtils.calculateCharges(prixVente, tauxCharges);
      final margeNette = CalculationsUtils.calculateMargeNette(
        prixVente,
        coutAchat,
        charges,
      );

      // Vente: 1000, Achat: 600, Charges: 220 → Marge: 180
      expect(charges, Decimal.parse('220'));
      expect(margeNette, Decimal.parse('180'));
    });
  });
}
