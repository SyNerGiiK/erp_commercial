import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/services/tva_service.dart';
import 'package:erp_commercial/models/urssaf_model.dart';
import 'package:erp_commercial/models/facture_model.dart';

void main() {
  // =====================================================================
  // SPRINT 6 — TvaService TESTS
  // =====================================================================

  late UrssafConfig config;

  setUp(() {
    // Seuils 2026 standard
    config = UrssafConfig(
      userId: 'test-user',
      seuilTvaMicroVente: Decimal.parse('91900'),
      seuilTvaMicroVenteMaj: Decimal.parse('101000'),
      seuilTvaMicroService: Decimal.parse('36800'),
      seuilTvaMicroServiceMaj: Decimal.parse('39100'),
    );
  });

  group('TvaService.analyserActivite', () {
    test('CA faible → enFranchise', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('10000'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.enFranchise);
      expect(result.requiresAlert, isFalse);
      expect(result.forceTvaImmediate, isFalse);
    });

    test('CA à 80% du seuil → approcheSeuil', () {
      // 80% de 36800 = 29440
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('30000'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.approcheSeuil);
      expect(result.requiresAlert, isTrue);
      expect(result.forceTvaImmediate, isFalse);
    });

    test('CA dépasse seuil base mais pas majoré → seuilBaseDepasse', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('37000'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.seuilBaseDepasse);
      expect(result.requiresAlert, isTrue);
      expect(result.forceTvaImmediate, isFalse);
      expect(result.message, contains('Seuil de base TVA dépassé'));
    });

    test('CA dépasse seuil majoré → seuilMajoreDepasse', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('40000'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.seuilMajoreDepasse);
      expect(result.requiresAlert, isTrue);
      expect(result.forceTvaImmediate, isTrue);
      expect(result.message, contains('IMMÉDIAT'));
    });

    test('Progression base et majoré calculées correctement', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('18400'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.progressionBase, closeTo(0.5, 0.01));
      expect(result.progressionMajore, closeTo(0.47, 0.01));
      expect(result.margeBase, Decimal.parse('18400'));
    });
  });

  group('TvaService.analyser (BilanTva)', () {
    test('Bilan global prend le statut le plus critique', () {
      final bilan = TvaService.analyser(
        caVenteYtd: Decimal.parse('5000'), // franchise
        caServiceYtd: Decimal.parse('40000'), // majoré dépassé
        config: config,
      );
      expect(bilan.statutGlobal, StatutTva.seuilMajoreDepasse);
      expect(bilan.requiresAlert, isTrue);
      expect(bilan.forceTvaImmediate, isTrue);
      expect(bilan.vente.statut, StatutTva.enFranchise);
      expect(bilan.service.statut, StatutTva.seuilMajoreDepasse);
    });

    test('Bilan sans dépassement → franchise', () {
      final bilan = TvaService.analyser(
        caVenteYtd: Decimal.parse('5000'),
        caServiceYtd: Decimal.parse('10000'),
        config: config,
      );
      expect(bilan.statutGlobal, StatutTva.enFranchise);
      expect(bilan.requiresAlert, isFalse);
      expect(bilan.forceTvaImmediate, isFalse);
      expect(bilan.alertMessages, isEmpty);
    });

    test('AlertMessages combine vente et service', () {
      final bilan = TvaService.analyser(
        caVenteYtd: Decimal.parse('80000'), // approcheSeuil vente
        caServiceYtd: Decimal.parse('37000'), // seuilBaseDepasse service
        config: config,
      );
      expect(bilan.alertMessages, hasLength(2));
      expect(bilan.alertMessages[0], contains('vente'));
      expect(bilan.alertMessages[1], contains('service'));
    });
  });

  group('TvaService.calculerCaYtd', () {
    test('Ventile CA par type activité des lignes', () {
      final factures = [
        _makeFacture(
          statut: 'validee',
          year: 2026,
          lignes: [
            _makeLigne(typeActivite: 'service', total: '5000'),
            _makeLigne(typeActivite: 'vente', total: '3000'),
          ],
        ),
      ];
      final result = TvaService.calculerCaYtd(factures, annee: 2026);
      expect(result.caVente, Decimal.parse('3000'));
      expect(result.caService, Decimal.parse('5000'));
    });

    test('Ignore les factures brouillon', () {
      final factures = [
        _makeFacture(
          statut: 'brouillon',
          year: 2026,
          lignes: [_makeLigne(typeActivite: 'service', total: '10000')],
        ),
      ];
      final result = TvaService.calculerCaYtd(factures, annee: 2026);
      expect(result.caVente, Decimal.zero);
      expect(result.caService, Decimal.zero);
    });

    test('Factures sans lignes → fallback service', () {
      final factures = [
        _makeFacture(
          statut: 'payee',
          year: 2026,
          totalHt: '8000',
          lignes: [],
        ),
      ];
      final result = TvaService.calculerCaYtd(factures, annee: 2026);
      expect(result.caService, Decimal.parse('8000'));
      expect(result.caVente, Decimal.zero);
    });

    test('Filtre par année', () {
      final factures = [
        _makeFacture(
          statut: 'validee',
          year: 2025,
          lignes: [_makeLigne(typeActivite: 'service', total: '20000')],
        ),
        _makeFacture(
          statut: 'validee',
          year: 2026,
          lignes: [_makeLigne(typeActivite: 'service', total: '15000')],
        ),
      ];
      final result = TvaService.calculerCaYtd(factures, annee: 2026);
      expect(result.caService, Decimal.parse('15000'));
    });

    test('Avoirs déduits du CA service', () {
      final factures = [
        _makeFacture(
          statut: 'validee',
          year: 2026,
          lignes: [_makeLigne(typeActivite: 'service', total: '20000')],
        ),
        _makeFacture(
          statut: 'validee',
          year: 2026,
          type: 'avoir',
          totalHt: '5000',
          lignes: [],
        ),
      ];
      final result = TvaService.calculerCaYtd(factures, annee: 2026);
      expect(result.caService, Decimal.parse('15000'));
    });
  });

  group('TvaService.simulerAvecMontant', () {
    test('Simule un montant supplémentaire qui déclenche dépassement', () {
      final bilan = TvaService.simulerAvecMontant(
        caVenteYtd: Decimal.zero,
        caServiceYtd: Decimal.parse('35000'),
        montantSupplementaire: Decimal.parse('5000'),
        estVente: false,
        config: config,
      );
      // 35000 + 5000 = 40000 > 39100 majoré
      expect(bilan.service.statut, StatutTva.seuilMajoreDepasse);
    });

    test('Simule montant vente sans impact sur service', () {
      final bilan = TvaService.simulerAvecMontant(
        caVenteYtd: Decimal.parse('90000'),
        caServiceYtd: Decimal.parse('10000'),
        montantSupplementaire: Decimal.parse('3000'),
        estVente: true,
        config: config,
      );
      // 90000 + 3000 = 93000 > 91900 base vente
      expect(bilan.vente.statut, StatutTva.seuilBaseDepasse);
      expect(bilan.service.statut, StatutTva.enFranchise);
    });
  });

  group('AnalyseTva edge cases', () {
    test('Seuil à zéro → progression 0', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('1000'),
        seuilBase: Decimal.zero,
        seuilMajore: Decimal.zero,
        typeActivite: 'service',
      );
      expect(result.progressionBase, 0.0);
      expect(result.progressionMajore, 0.0);
      // CA >= 0 (seuilMajore) → seuilMajoreDepasse
      expect(result.statut, StatutTva.seuilMajoreDepasse);
    });

    test('CA exactement au seuil de base → seuilBaseDepasse', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('36800'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.seuilBaseDepasse);
    });

    test('CA exactement au seuil majoré → seuilMajoreDepasse', () {
      final result = TvaService.analyserActivite(
        caYtd: Decimal.parse('39100'),
        seuilBase: Decimal.parse('36800'),
        seuilMajore: Decimal.parse('39100'),
        typeActivite: 'service',
      );
      expect(result.statut, StatutTva.seuilMajoreDepasse);
    });
  });
}

// --- TEST HELPERS ---

Facture _makeFacture({
  required String statut,
  required int year,
  String type = 'standard',
  String totalHt = '0',
  required List<LigneFacture> lignes,
}) {
  return Facture(
    objet: 'Test facture',
    clientId: 'client-1',
    dateEmission: DateTime(year, 6, 15),
    dateEcheance: DateTime(year, 7, 15),
    statut: statut,
    type: type,
    totalHt: lignes.isNotEmpty
        ? lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne)
        : Decimal.parse(totalHt),
    remiseTaux: Decimal.zero,
    acompteDejaRegle: Decimal.zero,
    lignes: lignes,
  );
}

LigneFacture _makeLigne({
  required String typeActivite,
  required String total,
}) {
  return LigneFacture(
    description: 'Test ligne',
    quantite: Decimal.one,
    prixUnitaire: Decimal.parse(total),
    totalLigne: Decimal.parse(total),
    typeActivite: typeActivite,
  );
}
