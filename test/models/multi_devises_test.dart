import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';

/// Tests des champs multi-devises et notes privées ajoutés aux modèles existants
void main() {
  group('Facture - champs multi-devises', () {
    test('devrait avoir EUR comme devise par défaut', () {
      final facture = Facture(
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.fromInt(100),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );
      expect(facture.devise, 'EUR');
      expect(facture.tauxChange, isNull);
      expect(facture.notesPrivees, isNull);
    });

    test('devrait sérialiser/désérialiser la devise', () {
      final original = Facture(
        objet: 'Export US',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.fromInt(1000),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        devise: 'USD',
        tauxChange: Decimal.parse('1.08'),
        notesPrivees: 'Client stratégique, attention au taux',
      );

      final map = original.toMap();
      expect(map['devise'], 'USD');
      expect(map['taux_change'], '1.08');
      expect(map['notes_privees'], 'Client stratégique, attention au taux');

      final restored = Facture.fromMap(map);
      expect(restored.devise, 'USD');
      expect(restored.tauxChange, Decimal.parse('1.08'));
      expect(restored.notesPrivees, 'Client stratégique, attention au taux');
    });

    test('devrait supporter copyWith pour les nouveaux champs', () {
      final original = Facture(
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.fromInt(100),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final modified = original.copyWith(
        devise: 'GBP',
        tauxChange: Decimal.parse('0.86'),
        notesPrivees: 'Paiement en livres sterling',
      );

      expect(modified.devise, 'GBP');
      expect(modified.tauxChange, Decimal.parse('0.86'));
      expect(modified.notesPrivees, 'Paiement en livres sterling');
      expect(modified.objet, 'Test'); // Inchangé
    });

    test('devrait gérer fromMap sans les nouveaux champs (rétrocompatibilité)',
        () {
      final map = {
        'objet': 'Ancienne facture',
        'client_id': 'c1',
        'date_emission': DateTime.now().toIso8601String(),
        'date_echeance': DateTime.now().toIso8601String(),
        'total_ht': '100',
        'remise_taux': '0',
        'acompte_deja_regle': '0',
      };

      final facture = Facture.fromMap(map);
      expect(facture.devise, 'EUR'); // fallback
      expect(facture.tauxChange, isNull);
      expect(facture.notesPrivees, isNull);
    });
  });

  group('Devis - champs multi-devises', () {
    test('devrait avoir EUR comme devise par défaut', () {
      final devis = Devis(
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.fromInt(100),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );
      expect(devis.devise, 'EUR');
      expect(devis.tauxChange, isNull);
      expect(devis.notesPrivees, isNull);
    });

    test('devrait sérialiser/désérialiser la devise', () {
      final original = Devis(
        objet: 'Projet international',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.fromInt(5000),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        devise: 'CHF',
        tauxChange: Decimal.parse('0.94'),
        notesPrivees: 'Client suisse, facturer en CHF',
      );

      final map = original.toMap();
      expect(map['devise'], 'CHF');
      expect(map['taux_change'], '0.94');
      expect(map['notes_privees'], 'Client suisse, facturer en CHF');

      final restored = Devis.fromMap(map);
      expect(restored.devise, 'CHF');
      expect(restored.tauxChange, Decimal.parse('0.94'));
      expect(restored.notesPrivees, 'Client suisse, facturer en CHF');
    });

    test('devrait supporter copyWith pour les nouveaux champs', () {
      final original = Devis(
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.fromInt(100),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      final modified = original.copyWith(
        devise: 'USD',
        tauxChange: Decimal.parse('1.08'),
        notesPrivees: 'Export vers les US',
      );

      expect(modified.devise, 'USD');
      expect(modified.tauxChange, Decimal.parse('1.08'));
      expect(modified.notesPrivees, 'Export vers les US');
      expect(modified.objet, 'Test'); // Inchangé
    });

    test('devrait gérer fromMap sans les nouveaux champs (rétrocompatibilité)',
        () {
      final map = {
        'objet': 'Ancien devis',
        'client_id': 'c1',
        'date_emission': DateTime.now().toIso8601String(),
        'date_validite': DateTime.now().toIso8601String(),
        'total_ht': '100',
        'remise_taux': '0',
        'acompte_montant': '0',
      };

      final devis = Devis.fromMap(map);
      expect(devis.devise, 'EUR'); // fallback
      expect(devis.tauxChange, isNull);
      expect(devis.notesPrivees, isNull);
    });
  });
}
