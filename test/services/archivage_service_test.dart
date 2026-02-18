import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/services/archivage_service.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';

/// Helper pour créer rapidement une facture de test
Facture _makeFacture({
  required String id,
  required String statut,
  required Decimal totalHt,
  List<Paiement> paiements = const [],
  bool estArchive = false,
}) {
  final now = DateTime.now();
  return Facture(
    id: id,
    userId: 'user-1',
    numeroFacture: 'FAC-$id',
    objet: 'Test $id',
    clientId: 'client-1',
    dateEmission: now.subtract(const Duration(days: 500)),
    dateEcheance: now.subtract(const Duration(days: 470)),
    totalHt: totalHt,
    remiseTaux: Decimal.zero,
    acompteDejaRegle: Decimal.zero,
    statut: statut,
    paiements: paiements,
    estArchive: estArchive,
  );
}

Paiement _makePaiement(String factureId, Decimal montant, DateTime date) {
  return Paiement(
    id: 'p-$factureId',
    factureId: factureId,
    montant: montant,
    datePaiement: date,
  );
}

void main() {
  group('ArchivageService.detecterArchivables', () {
    final now = DateTime(2026, 6, 15);

    test('détecte une facture soldée payée il y a plus d\'un an', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            _makePaiement('f1', Decimal.parse('1000'),
                DateTime(2025, 3, 1)), // 15+ mois avant
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, hasLength(1));
      expect(result.first.id, 'f1');
    });

    test('ignore factures déjà archivées', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          estArchive: true,
          paiements: [
            _makePaiement('f1', Decimal.parse('1000'), DateTime(2024, 1, 1)),
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, isEmpty);
    });

    test('ignore factures non soldées', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'validee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            // Paiement partiel — pas soldée
            _makePaiement('f1', Decimal.parse('500'), DateTime(2024, 1, 1)),
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, isEmpty);
    });

    test('ignore factures sans paiement', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'validee',
          totalHt: Decimal.parse('0'),
          paiements: [],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, isEmpty);
    });

    test('ignore factures payées récemment (< 12 mois)', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            // Paiement il y a 6 mois (< seuil 12 mois)
            _makePaiement('f1', Decimal.parse('1000'), DateTime(2026, 1, 15)),
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, isEmpty);
    });

    test('utilise la date du dernier paiement (pas le premier)', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            // Premier paiement il y a 2 ans
            _makePaiement('f1', Decimal.parse('500'), DateTime(2024, 1, 1)),
            // Dernier paiement récent (< 12 mois)
            _makePaiement('f1', Decimal.parse('500'), DateTime(2026, 2, 1)),
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      // Le dernier paiement est à 4.5 mois → pas archivable
      expect(result, isEmpty);
    });

    test('filtre correctement un mix de factures', () {
      final factures = [
        // Archivable : soldée, dernier paiement > 12 mois
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            _makePaiement('f1', Decimal.parse('1000'), DateTime(2024, 12, 1)),
          ],
        ),
        // Non archivable : déjà archivée
        _makeFacture(
          id: 'f2',
          statut: 'payee',
          totalHt: Decimal.parse('500'),
          estArchive: true,
          paiements: [
            _makePaiement('f2', Decimal.parse('500'), DateTime(2024, 1, 1)),
          ],
        ),
        // Non archivable : pas soldée
        _makeFacture(
          id: 'f3',
          statut: 'validee',
          totalHt: Decimal.parse('2000'),
          paiements: [
            _makePaiement('f3', Decimal.parse('800'), DateTime(2024, 1, 1)),
          ],
        ),
        // Archivable : soldée via 2 paiements, dernier > 12 mois
        _makeFacture(
          id: 'f4',
          statut: 'payee',
          totalHt: Decimal.parse('3000'),
          paiements: [
            _makePaiement('f4', Decimal.parse('1500'), DateTime(2024, 6, 1)),
            _makePaiement('f4', Decimal.parse('1500'), DateTime(2025, 1, 1)),
          ],
        ),
        // Non archivable : payée récemment
        _makeFacture(
          id: 'f5',
          statut: 'payee',
          totalHt: Decimal.parse('750'),
          paiements: [
            _makePaiement('f5', Decimal.parse('750'), DateTime(2026, 5, 1)),
          ],
        ),
      ];

      final result =
          ArchivageService.detecterArchivables(factures, maintenant: now);

      expect(result, hasLength(2));
      expect(result.map((f) => f.id), containsAll(['f1', 'f4']));
    });

    test('seuil personnalisable (6 mois)', () {
      final factures = [
        _makeFacture(
          id: 'f1',
          statut: 'payee',
          totalHt: Decimal.parse('1000'),
          paiements: [
            // 8 mois avant "now" → archivable avec seuil 6 mais pas avec 12
            _makePaiement('f1', Decimal.parse('1000'), DateTime(2025, 10, 1)),
          ],
        ),
      ];

      final defaultResult =
          ArchivageService.detecterArchivables(factures, maintenant: now);
      final customResult = ArchivageService.detecterArchivables(factures,
          maintenant: now, seuilMois: 6);

      expect(defaultResult, isEmpty, reason: 'seuil 12 mois → pas archivable');
      expect(customResult, hasLength(1), reason: 'seuil 6 mois → archivable');
    });

    test('liste vide retourne vide', () {
      final result = ArchivageService.detecterArchivables([], maintenant: now);
      expect(result, isEmpty);
    });
  });
}
