import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/facture_viewmodel.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeFacture extends Fake implements Facture {}

class FakePaiement extends Fake implements Paiement {}

void main() {
  late MockFactureRepository mockRepository;
  late FactureViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeFacture());
    registerFallbackValue(FakePaiement());
  });

  setUp(() {
    mockRepository = MockFactureRepository();
    viewModel = FactureViewModel(repository: mockRepository);
  });

  group('fetchFactures', () {
    test('devrait récupérer et exposer la liste des factures actives',
        () async {
      // ARRANGE
      final testFactures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test Facture 1',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 15),
          dateEcheance: DateTime(2024, 2, 15),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'facture-2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Test Facture 2',
          clientId: 'client-2',
          dateEmission: DateTime(2024, 1, 20),
          dateEcheance: DateTime(2024, 2, 20),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => testFactures);

      // ACT
      await viewModel.fetchFactures();

      // ASSERT
      expect(viewModel.factures.length, 2);
      expect(viewModel.factures[0].numeroFacture, 'FAC-2024-001');
      expect(viewModel.factures[1].numeroFacture, 'FAC-2024-002');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getFactures(archives: false)).called(1);
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      when(() => mockRepository.getFactures(archives: false))
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.fetchFactures();

      // ASSERT
      expect(viewModel.factures, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('fetchArchives', () {
    test('devrait récupérer les factures archivées', () async {
      // ARRANGE
      final testArchives = <Facture>[
        Facture(
          id: 'facture-3',
          userId: 'user-1',
          numeroFacture: 'FAC-2023-999',
          objet: 'Old Facture',
          clientId: 'client-1',
          dateEmission: DateTime(2023, 12, 1),
          dateEcheance: DateTime(2024, 1, 1),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
        ),
      ];

      when(() => mockRepository.getFactures(archives: true))
          .thenAnswer((_) async => testArchives);

      // ACT
      await viewModel.fetchArchives();

      // ASSERT
      expect(viewModel.archives.length, 1);
      expect(viewModel.archives[0].numeroFacture, 'FAC-2023-999');
    });
  });

  group('addFacture', () {
    test('devrait ajouter une facture et rafraîchir la liste', () async {
      // ARRANGE
      final newFacture = Facture(
        userId: 'user-1',
        numeroFacture: 'FAC-2024-003',
        objet: 'New Facture',
        clientId: 'client-3',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('3000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'brouillon',
      );

      final updatedFactures = <Facture>[
        Facture(
          id: 'facture-3',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-003',
          objet: 'New Facture',
          clientId: 'client-3',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('3000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'brouillon',
        ),
      ];

      when(() => mockRepository.createFacture(any()))
          .thenAnswer((_) async => updatedFactures[0]);
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => updatedFactures);

      // ACT
      final success = await viewModel.addFacture(newFacture);

      // ASSERT
      expect(success, true);
      expect(viewModel.factures.length, 1);
      verify(() => mockRepository.createFacture(newFacture)).called(1);
      verify(() => mockRepository.getFactures(archives: false)).called(1);
    });

    test('devrait retourner false en cas d\'erreur', () async {
      // ARRANGE
      final newFacture = Facture(
        userId: 'user-1',
        numeroFacture: 'FAC-ERROR',
        objet: 'Error Facture',
        clientId: 'client-x',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('100'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'brouillon',
      );

      when(() => mockRepository.createFacture(any()))
          .thenThrow(Exception('Creation failed'));

      // ACT
      final success = await viewModel.addFacture(newFacture);

      // ASSERT
      expect(success, false);
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.createFacture(newFacture)).called(1);
      verifyNever(
          () => mockRepository.getFactures(archives: any(named: 'archives')));
    });
  });

  group('updateFacture', () {
    test('devrait mettre à jour une facture et rafraîchir', () async {
      // ARRANGE
      final updatedFacture = Facture(
        id: 'facture-1',
        userId: 'user-1',
        numeroFacture: 'FAC-2024-001',
        objet: 'Updated Facture',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('1500'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'validee',
      );

      final resultFactures = <Facture>[updatedFacture];

      when(() => mockRepository.updateFacture(any())).thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => resultFactures);

      // ACT
      final success = await viewModel.updateFacture(updatedFacture);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.updateFacture(updatedFacture)).called(1);
      verify(() => mockRepository.getFactures(archives: false)).called(1);
    });
  });

  group('deleteFacture', () {
    test('devrait supprimer une facture et rafraîchir', () async {
      // ARRANGE
      const factureIdToDelete = 'facture-1';
      final initialFactures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'To Delete',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          statutJuridique: 'brouillon', // MUST be brouillon to delete
        ),
        Facture(
          id: 'facture-2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Remaining',
          clientId: 'client-2',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          statutJuridique: 'brouillon',
        ),
      ];

      final remainingFactures = <Facture>[initialFactures[1]];

      // First fetch to populate viewModel
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => initialFactures);
      await viewModel.fetchFactures();

      // Then setup delete
      when(() => mockRepository.deleteFacture(factureIdToDelete))
          .thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => remainingFactures);

      // ACT
      await viewModel.deleteFacture(factureIdToDelete);

      // ASSERT
      expect(viewModel.factures.length, 1);
      verify(() => mockRepository.deleteFacture(factureIdToDelete)).called(1);
      verify(() => mockRepository.getFactures(archives: false))
          .called(2); // 1 fetch + 1 after delete
    });
  });

  group('addPaiement', () {
    test('devrait ajouter un paiement et rafraîchir', () async {
      // ARRANGE
      final paiement = Paiement(
        factureId: 'facture-1',
        montant: Decimal.parse('500'),
        datePaiement: DateTime.now(),
        typePaiement: 'virement',
      );

      final factures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [paiement],
        ),
      ];

      when(() => mockRepository.addPaiement(any())).thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);

      // ACT
      final success = await viewModel.addPaiement(paiement);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.addPaiement(paiement)).called(1);
      verify(() => mockRepository.getFactures(archives: false))
          .called(greaterThanOrEqualTo(1));
    });
  });

  group('deletePaiement', () {
    test('devrait supprimer un paiement et rafraîchir', () async {
      // ARRANGE
      const paiementId = 'paiement-1';
      const factureId = 'facture-1';

      final factures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [], // Paiement supprimé
        ),
      ];

      when(() => mockRepository.deletePaiement(paiementId))
          .thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);

      // ACT
      final success = await viewModel.deletePaiement(paiementId, factureId);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.deletePaiement(paiementId)).called(1);
      verify(() => mockRepository.getFactures(archives: false))
          .called(greaterThanOrEqualTo(1));
    });
  });

  group('finaliserFacture', () {
    test('devrait finaliser une facture brouillon avec numéro généré',
        () async {
      // ARRANGE
      final brouillonFacture = Facture(
        id: 'facture-1',
        userId: 'user-1',
        numeroFacture: 'BROUILLON',
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'brouillon',
      );

      final finalizedFactures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          statutJuridique: 'validee',
        ),
      ];

      when(() => mockRepository.generateNextNumero(any()))
          .thenAnswer((_) async => 'FAC-2024-001');
      when(() => mockRepository.updateFacture(any())).thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => finalizedFactures);

      // ACT
      final success = await viewModel.finaliserFacture(brouillonFacture);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.generateNextNumero(any())).called(1);
      verify(() => mockRepository.updateFacture(any())).called(1);
      verify(() => mockRepository.getFactures(archives: false)).called(1);
    });

    test('devrait retourner false si facture sans ID', () async {
      // ARRANGE
      final factureSansId = Facture(
        userId: 'user-1',
        numeroFacture: 'TEST',
        objet: 'Sans ID',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'brouillon',
      );

      // ACT
      final success = await viewModel.finaliserFacture(factureSansId);

      // ASSERT
      expect(success, false);
      verifyNever(() => mockRepository.generateNextNumero(any()));
    });
  });

  group('toggleArchive', () {
    test('devrait archiver une facture et rafraîchir les deux listes',
        () async {
      // ARRANGE
      final factureToArchive = Facture(
        id: 'facture-1',
        userId: 'user-1',
        numeroFacture: 'FAC-2024-001',
        objet: 'To Archive',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'payee',
      );

      when(() => mockRepository.updateArchiveStatus('facture-1', true))
          .thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => <Facture>[]);
      when(() => mockRepository.getFactures(archives: true))
          .thenAnswer((_) async => [factureToArchive]);

      // ACT
      await viewModel.toggleArchive(factureToArchive, true);

      // ASSERT
      verify(() => mockRepository.updateArchiveStatus('facture-1', true))
          .called(1);
      verify(() => mockRepository.getFactures(archives: false)).called(1);
      verify(() => mockRepository.getFactures(archives: true)).called(1);
    });
  });

  group('markAsSent', () {
    test('devrait marquer une facture comme envoyée', () async {
      // ARRANGE
      final factures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final sentFactures = <Facture>[
        Facture(
          id: 'facture-1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoye',
        ),
      ];

      // Ajouter facture initiale
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);
      await viewModel.fetchFactures();

      when(() => mockRepository.updateFacture(any())).thenAnswer((_) async {});
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => sentFactures);

      // ACT
      final success = await viewModel.markAsSent('facture-1');

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.updateFacture(any())).called(1);
    });
  });

  group('getChiffreAffaires', () {
    test('devrait calculer le CA mensuel pour une année', () async {
      // ARRANGE
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Janvier',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 15),
          dateEcheance: DateTime(2024, 2, 15),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Janvier aussi',
          clientId: 'client-2',
          dateEmission: DateTime(2024, 1, 20),
          dateEcheance: DateTime(2024, 2, 20),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
        ),
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-003',
          objet: 'Mars',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 3, 10),
          dateEcheance: DateTime(2024, 4, 10),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        // Facture brouillon - ne devrait pas être comptée
        Facture(
          id: 'f4',
          userId: 'user-1',
          numeroFacture: 'BROUILLON',
          objet: 'Brouillon',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 10),
          dateEcheance: DateTime(2024, 2, 10),
          totalHt: Decimal.parse('999'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'brouillon',
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);

      // ACT
      final ca = await viewModel.getChiffreAffaires(2024);

      // ASSERT
      expect(ca.length, 12); // 12 mois
      expect(ca[0], Decimal.parse('1500')); // Janvier: 1000 + 500
      expect(ca[1], Decimal.zero); // Février: 0
      expect(ca[2], Decimal.parse('2000')); // Mars: 2000
      expect(ca[3], Decimal.zero); // Avril: 0
    });
  });

  group('getImpayes', () {
    test('devrait calculer le total des impayés (factures validées non payées)',
        () async {
      // ARRANGE
      final factures = <Facture>[
        // Facture validée partiellement payée
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Partiellement payée',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [
            Paiement(
              id: 'p1',
              factureId: 'f1',
              montant: Decimal.parse('300'),
              datePaiement: DateTime.now(),
              typePaiement: 'virement',
            ),
          ],
        ),
        // Facture complètement payée - ne devrait PAS être comptée
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Payée',
          clientId: 'client-2',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
        ),
        // Facture validée non payée
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-003',
          objet: 'Non payée',
          clientId: 'client-3',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('800'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [],
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);

      // ACT
      final impayes = await viewModel.getImpayes();

      // ASSERT
      // f1: reste = 1000 - 300 = 700
      // f2: statut payée, ignorée
      // f3: reste = 800
      // Total: 700 + 800 = 1500
      expect(impayes, Decimal.parse('1500'));
    });
  });

  group('getRecentActivity', () {
    test('devrait retourner les N dernières factures par date d\'émission',
        () async {
      // ARRANGE
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Plus ancienne',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 1),
          dateEcheance: DateTime(2024, 2, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Plus récente',
          clientId: 'client-2',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 4, 1),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-003',
          objet: 'Moyenne',
          clientId: 'client-3',
          dateEmission: DateTime(2024, 2, 1),
          dateEcheance: DateTime(2024, 3, 1),
          totalHt: Decimal.parse('1500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);
      await viewModel.fetchFactures();

      // ACT
      final recent = viewModel.getRecentActivity(2);

      // ASSERT
      expect(recent.length, 2);
      expect(recent[0].numeroFacture, 'FAC-2024-002'); // Plus récente
      expect(recent[1].numeroFacture, 'FAC-2024-003'); // Deuxième plus récente
    });
  });

  group('duplicateFacture', () {
    test('devrait créer une copie brouillon de la facture source', () {
      // ARRANGE
      final source = Facture(
        id: 'facture-original',
        userId: 'user-1',
        numeroFacture: 'FAC-2024-010',
        objet: 'Prestation originale',
        clientId: 'client-1',
        dateEmission: DateTime(2024, 1, 15),
        dateEcheance: DateTime(2024, 2, 15),
        totalHt: Decimal.parse('5000'),
        remiseTaux: Decimal.parse('10'),
        acompteDejaRegle: Decimal.parse('1000'),
        statut: 'payee',
        statutJuridique: 'validee',
        type: 'standard',
        lignes: [
          LigneFacture(
            id: 'ligne-1',
            description: 'Ligne test',
            quantite: Decimal.fromInt(2),
            prixUnitaire: Decimal.parse('2500'),
            totalLigne: Decimal.parse('5000'),
            type: 'article',
          ),
        ],
        paiements: [
          Paiement(
            id: 'p1',
            factureId: 'facture-original',
            montant: Decimal.parse('4000'),
            datePaiement: DateTime(2024, 2, 10),
            typePaiement: 'virement',
          ),
        ],
      );

      // ACT
      final duplicate = viewModel.duplicateFacture(source);

      // ASSERT
      expect(duplicate.id, isNull);
      expect(duplicate.numeroFacture, '');
      expect(duplicate.statut, 'brouillon');
      expect(duplicate.statutJuridique, 'brouillon');
      expect(duplicate.objet, 'Prestation originale');
      expect(duplicate.clientId, 'client-1');
      expect(duplicate.totalHt, Decimal.parse('5000'));
      expect(duplicate.remiseTaux, Decimal.parse('10'));
      expect(duplicate.paiements, isEmpty);
      expect(duplicate.lignes.length, 1);
      expect(duplicate.lignes[0].id, isNull);
      expect(duplicate.lignes[0].description, 'Ligne test');
    });
  });

  group('createAvoir', () {
    test('devrait créer un avoir avec montants inversés', () {
      // ARRANGE
      final source = Facture(
        id: 'facture-source',
        userId: 'user-1',
        numeroFacture: 'FAC-2024-020',
        objet: 'Prestation avoir test',
        clientId: 'client-1',
        dateEmission: DateTime(2024, 1, 15),
        dateEcheance: DateTime(2024, 2, 15),
        totalHt: Decimal.parse('3000'),
        totalTva: Decimal.parse('600'),
        totalTtc: Decimal.parse('3600'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'validee',
        statutJuridique: 'validee',
        lignes: [
          LigneFacture(
            id: 'l1',
            description: 'Service A',
            quantite: Decimal.one,
            prixUnitaire: Decimal.parse('3000'),
            totalLigne: Decimal.parse('3000'),
            type: 'article',
          ),
        ],
      );

      // ACT
      final avoir = viewModel.createAvoir(source);

      // ASSERT
      expect(avoir.type, 'avoir');
      expect(avoir.factureSourceId, 'facture-source');
      expect(avoir.totalHt, Decimal.parse('-3000'));
      expect(avoir.totalTva, Decimal.parse('-600'));
      expect(avoir.totalTtc, Decimal.parse('-3600'));
      expect(avoir.statut, 'brouillon');
      expect(avoir.objet, contains('Avoir sur FAC-2024-020'));
      expect(avoir.lignes.length, 1);
      expect(avoir.lignes[0].prixUnitaire, Decimal.parse('-3000'));
      expect(avoir.lignes[0].totalLigne, Decimal.parse('-3000'));
    });

    test('devrait lancer une exception si facture sans ID', () {
      final factureSansId = Facture(
        userId: 'user-1',
        objet: 'Sans ID',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      expect(
        () => viewModel.createAvoir(factureSansId),
        throwsException,
      );
    });

    test('devrait lancer une exception si facture brouillon', () {
      final factureBrouillon = Facture(
        id: 'f1',
        userId: 'user-1',
        objet: 'Brouillon',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statutJuridique: 'brouillon',
      );

      expect(
        () => viewModel.createAvoir(factureBrouillon),
        throwsException,
      );
    });
  });

  group('facturesEnRetard', () {
    test('devrait retourner uniquement les factures en retard', () async {
      // ARRANGE
      final now = DateTime.now();
      final factures = <Facture>[
        // En retard - validée avec échéance passée
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'En retard',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 60)),
          dateEcheance: now.subtract(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        // Pas en retard - payée
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-002',
          objet: 'Payée',
          clientId: 'c2',
          dateEmission: now.subtract(const Duration(days: 60)),
          dateEcheance: now.subtract(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
        ),
        // Pas en retard - échéance future
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-003',
          objet: 'Future',
          clientId: 'c3',
          dateEmission: now,
          dateEcheance: now.add(const Duration(days: 30)),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        // En retard - envoyée avec échéance passée
        Facture(
          id: 'f4',
          userId: 'user-1',
          numeroFacture: 'FAC-004',
          objet: 'Envoyée retard',
          clientId: 'c4',
          dateEmission: now.subtract(const Duration(days: 45)),
          dateEcheance: now.subtract(const Duration(days: 15)),
          totalHt: Decimal.parse('750'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoye',
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);
      await viewModel.fetchFactures();

      // ACT
      final retard = viewModel.facturesEnRetard;

      // ASSERT
      expect(retard.length, 2);
      expect(retard.any((f) => f.id == 'f1'), true);
      expect(retard.any((f) => f.id == 'f4'), true);
    });

    test('devrait retourner une liste vide si aucune facture en retard',
        () async {
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => <Facture>[]);
      await viewModel.fetchFactures();

      expect(viewModel.facturesEnRetard, isEmpty);
    });
  });

  group('retardMoyen', () {
    test('devrait calculer le retard moyen en jours', () async {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Retard 10j',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 40)),
          dateEcheance: now.subtract(const Duration(days: 10)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-002',
          objet: 'Retard 20j',
          clientId: 'c2',
          dateEmission: now.subtract(const Duration(days: 50)),
          dateEcheance: now.subtract(const Duration(days: 20)),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => factures);
      await viewModel.fetchFactures();

      // ACT
      final retard = viewModel.retardMoyen;

      // ASSERT - (10 + 20) / 2 = 15
      expect(retard, closeTo(15.0, 1.0));
    });

    test('devrait retourner 0 si aucune facture en retard', () async {
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => <Facture>[]);
      await viewModel.fetchFactures();

      expect(viewModel.retardMoyen, 0.0);
    });
  });

  group('calculateHistoriqueReglements', () {
    test('devrait calculer le total des paiements des factures liées',
        () async {
      // ARRANGE
      final linkedFactures = <Facture>[
        Facture(
          id: 'f-linked-1',
          userId: 'user-1',
          numeroFacture: 'FAC-ACOMPTE',
          objet: 'Acompte',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now(),
          totalHt: Decimal.parse('3000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [
            Paiement(
              factureId: 'f-linked-1',
              montant: Decimal.parse('3000'),
              datePaiement: DateTime.now(),
              typePaiement: 'virement',
            ),
          ],
        ),
        Facture(
          id: 'f-linked-2',
          userId: 'user-1',
          numeroFacture: 'FAC-SITUATION',
          objet: 'Situation',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now(),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [
            Paiement(
              factureId: 'f-linked-2',
              montant: Decimal.parse('2000'),
              datePaiement: DateTime.now(),
              typePaiement: 'cheque',
            ),
          ],
        ),
      ];

      when(() => mockRepository.getLinkedFactures(
            'devis-1',
            excludeFactureId: 'facture-current',
          )).thenAnswer((_) async => linkedFactures);

      // ACT
      final total = await viewModel.calculateHistoriqueReglements(
          'devis-1', 'facture-current');

      // ASSERT
      expect(total, Decimal.parse('5000'));
    });

    test('devrait retourner zéro en cas d\'erreur', () async {
      when(() => mockRepository.getLinkedFactures(any(),
              excludeFactureId: any(named: 'excludeFactureId')))
          .thenThrow(Exception('Erreur DB'));

      final total =
          await viewModel.calculateHistoriqueReglements('devis-1', 'f1');

      expect(total, Decimal.zero);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après un fetch réussi', () async {
      // ARRANGE
      when(() => mockRepository.getFactures(archives: false))
          .thenAnswer((_) async => <Facture>[]);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchFactures();
      expect(viewModel.isLoading, false);
    });
  });
}
