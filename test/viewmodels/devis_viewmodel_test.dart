import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/viewmodels/devis_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// Fake pour mocktail
class FakeDevis extends Fake implements Devis {}

void main() {
  group('DevisViewModel', () {
    late MockDevisRepository mockRepository;
    late DevisViewModel viewModel;

    setUpAll(() {
      registerFallbackValue(FakeDevis());
    });

    setUp(() {
      mockRepository = MockDevisRepository();
      viewModel = DevisViewModel(repository: mockRepository);
    });

    group('fetchDevis', () {
      test('devrait récupérer et exposer la liste des devis actifs', () async {
        // ARRANGE
        final testDevis = <Devis>[
          Devis(
            id: 'devis-1',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-001',
            objet: 'Test Devis 1',
            clientId: 'client-1',
            dateEmission: DateTime(2024, 1, 15),
            dateValidite: DateTime(2024, 2, 15),
            totalHt: Decimal.parse('1000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'brouillon',
          ),
          Devis(
            id: 'devis-2',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-002',
            objet: 'Test Devis 2',
            clientId: 'client-2',
            dateEmission: DateTime(2024, 1, 20),
            dateValidite: DateTime(2024, 2, 20),
            totalHt: Decimal.parse('2000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'envoye',
          ),
        ];

        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => testDevis);

        // ACT
        await viewModel.fetchDevis();

        // ASSERT
        expect(viewModel.devis, testDevis);
        expect(viewModel.devis.length, 2);
        expect(viewModel.devis[0].numeroDevis, 'DEV-2024-001');
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.getDevis(archives: false)).called(1);
      });

      test('devrait gérer les erreurs sans crash', () async {
        // ARRANGE
        when(() => mockRepository.getDevis(archives: false))
            .thenThrow(Exception('Network error'));

        // ACT
        await viewModel.fetchDevis();

        // ASSERT
        expect(viewModel.devis, isEmpty);
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.getDevis(archives: false)).called(1);
      });
    });

    group('fetchArchives', () {
      test('devrait récupérer les devis archivés', () async {
        // ARRANGE
        final testArchives = <Devis>[
          Devis(
            id: 'devis-3',
            userId: 'user-1',
            numeroDevis: 'DEV-2023-999',
            objet: 'Old Devis',
            clientId: 'client-1',
            dateEmission: DateTime(2023, 12, 1),
            dateValidite: DateTime(2024, 1, 1),
            totalHt: Decimal.parse('500'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'archive',
          ),
        ];

        when(() => mockRepository.getDevis(archives: true))
            .thenAnswer((_) async => testArchives);

        // ACT
        await viewModel.fetchArchives();

        // ASSERT
        expect(viewModel.archives, testArchives);
        expect(viewModel.archives.length, 1);
        verify(() => mockRepository.getDevis(archives: true)).called(1);
      });
    });

    group('addDevis', () {
      test('devrait ajouter un devis et rafraîchir la liste', () async {
        // ARRANGE
        final newDevis = Devis(
          userId: 'user-1',
          numeroDevis: 'DEV-2024-003',
          objet: 'New Devis',
          clientId: 'client-3',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('3000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'brouillon',
        );

        final updatedDevis = <Devis>[
          Devis(
            id: 'devis-3',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-003',
            objet: 'New Devis',
            clientId: 'client-3',
            dateEmission: DateTime.now(),
            dateValidite: DateTime.now().add(const Duration(days: 30)),
            totalHt: Decimal.parse('3000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'brouillon',
          ),
        ];

        when(() => mockRepository.createDevis(any()))
            .thenAnswer((_) async => updatedDevis[0]);
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => updatedDevis);

        // ACT
        final success = await viewModel.addDevis(newDevis);

        // ASSERT
        expect(success, true);
        expect(viewModel.devis.length, 1);
        expect(viewModel.devis.first.objet, 'New Devis');
        verify(() => mockRepository.createDevis(newDevis)).called(1);
        verify(() => mockRepository.getDevis(archives: false)).called(1);
      });

      test('devrait retourner false en cas d\'erreur', () async {
        // ARRANGE
        final newDevis = Devis(
          userId: 'user-1',
          numeroDevis: 'DEV-ERROR',
          objet: 'Error Devis',
          clientId: 'client-x',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('100'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'brouillon',
        );

        when(() => mockRepository.createDevis(any()))
            .thenThrow(Exception('Creation failed'));

        // ACT
        final success = await viewModel.addDevis(newDevis);

        // ASSERT
        expect(success, false);
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.createDevis(newDevis)).called(1);
        verifyNever(
            () => mockRepository.getDevis(archives: any(named: 'archives')));
      });
    });

    group('updateDevis', () {
      test('devrait mettre à jour un devis et rafraîchir', () async {
        // ARRANGE
        final updatedDevis = Devis(
          id: 'devis-1',
          userId: 'user-1',
          numeroDevis: 'DEV-2024-001',
          objet: 'Updated Devis',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1500'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'brouillon',
        );

        final resultDevis = <Devis>[updatedDevis];

        when(() => mockRepository.updateDevis(any())).thenAnswer((_) async {});
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => resultDevis);

        // ACT
        final success = await viewModel.updateDevis(updatedDevis);

        // ASSERT
        expect(success, true);
        expect(viewModel.devis.first.objet, 'Updated Devis');
        verify(() => mockRepository.updateDevis(updatedDevis)).called(1);
        verify(() => mockRepository.getDevis(archives: false)).called(1);
      });
    });

    group('deleteDevis', () {
      test('devrait supprimer un devis et rafraîchir', () async {
        // ARRANGE
        const devisIdToDelete = 'devis-1';
        final initialDevis = <Devis>[
          Devis(
            id: 'devis-1',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-001',
            objet: 'To Delete',
            clientId: 'client-1',
            dateEmission: DateTime.now(),
            dateValidite: DateTime.now().add(const Duration(days: 30)),
            totalHt: Decimal.parse('1000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'brouillon', // MUST be brouillon to delete
          ),
          Devis(
            id: 'devis-2',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-002',
            objet: 'Remaining',
            clientId: 'client-2',
            dateEmission: DateTime.now(),
            dateValidite: DateTime.now().add(const Duration(days: 30)),
            totalHt: Decimal.parse('2000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'brouillon',
          ),
        ];

        final remainingDevis = <Devis>[initialDevis[1]];

        // First fetch to populate viewModel
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => initialDevis);
        await viewModel.fetchDevis();

        // Then setup delete
        when(() => mockRepository.deleteDevis(devisIdToDelete))
            .thenAnswer((_) async {});
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => remainingDevis);

        // ACT
        await viewModel.deleteDevis(devisIdToDelete);

        // ASSERT
        expect(viewModel.devis.length, 1);
        expect(viewModel.devis.first.id, 'devis-2');
        verify(() => mockRepository.deleteDevis(devisIdToDelete)).called(1);
        verify(() => mockRepository.getDevis(archives: false))
            .called(2); // 1 fetch + 1 after delete
      });
    });

    group('prepareFacture', () {
      late Devis testDevis;

      setUp(() {
        testDevis = Devis(
          id: 'devis-1',
          userId: 'user-1',
          numeroDevis: 'DEV-2024-001',
          objet: 'Devis Test',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 15),
          dateValidite: DateTime(2024, 2, 15),
          totalHt: Decimal.parse('10000'),
          remiseTaux: Decimal.parse('10'),
          acompteMontant: Decimal.parse('3000'),
          statut: 'signe',
          lignes: [
            LigneDevis(
              description: 'Ligne 1',
              quantite: Decimal.fromInt(2),
              prixUnitaire: Decimal.parse('2500'),
              totalLigne: Decimal.parse('5000'),
              type: 'article',
            ),
            LigneDevis(
              description: 'Ligne 2',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('5000'),
              totalLigne: Decimal.parse('5000'),
              type: 'article',
            ),
          ],
        );
      });

      test('TYPE STANDARD: devrait créer une facture standard complète', () {
        // ACT
        final facture = viewModel.prepareFacture(
          testDevis,
          'standard',
          Decimal.zero,
          false,
        );

        // ASSERT
        expect(facture.type, 'standard');
        expect(facture.devisSourceId, 'devis-1');
        expect(facture.totalHt, Decimal.parse('10000'));
        expect(facture.lignes.length, 2);
        expect(facture.lignes[0].description, 'Ligne 1');
        expect(facture.lignes[0].avancement, Decimal.fromInt(100));
        expect(facture.lignes[1].avancement, Decimal.fromInt(100));
        expect(
            facture.acompteDejaRegle, Decimal.parse('3000')); //  acompte devis
      });

      test('TYPE ACOMPTE (pourcentage): devrait créer facture acompte 30%', () {
        // ACT
        final facture = viewModel.prepareFacture(
          testDevis,
          'acompte',
          Decimal.parse('30'),
          true, // isPercent
        );

        // ASSERT
        expect(facture.type, 'acompte');
        expect(facture.objet, 'Acompte - Devis Test');
        expect(facture.totalHt, Decimal.parse('3000')); // 30% de 10000
        expect(facture.lignes.length, 1);
        expect(facture.lignes[0].description, contains('Acompte de 30%'));
        expect(facture.lignes[0].prixUnitaire, Decimal.parse('3000'));
        expect(facture.remiseTaux, Decimal.zero); // Pas de remise sur acompte
      });

      test('TYPE ACOMPTE (montant fixe): devrait créer facture acompte 2500€',
          () {
        // ACT
        final facture = viewModel.prepareFacture(
          testDevis,
          'acompte',
          Decimal.parse('2500'),
          false, // Not percent
        );

        // ASSERT
        expect(facture.type, 'acompte');
        expect(facture.totalHt, Decimal.parse('2500'));
        expect(facture.lignes.length, 1);
        expect(facture.lignes[0].prixUnitaire, Decimal.parse('2500'));
      });

      test(
          'TYPE SITUATION: devrait créer facture situation avec avancement 50%',
          () {
        // ACT - Situation à 50%
        final facture = viewModel.prepareFacture(
          testDevis,
          'situation',
          Decimal.parse('50'),
          true, // isPercent (utilisé comme avancement)
        );

        // ASSERT
        expect(facture.type, 'situation');
        expect(facture.objet, 'Situation - Devis Test');
        expect(facture.lignes.length, 2);

        // Vérifier que l'avancement est appliqué
        expect(facture.lignes[0].avancement, Decimal.parse('50'));
        expect(facture.lignes[1].avancement, Decimal.parse('50'));

        // Le prix unitaire est ajusté en fonction de l'acompte déjà versé
        // Base = 10000 - 3000 = 7000
        // Ratio = 7000/10000 = 0.7
        final expectedPU1 = Decimal.parse('2500') * Decimal.parse('0.7');
        final expectedPU2 = Decimal.parse('5000') * Decimal.parse('0.7');

        expect(facture.lignes[0].prixUnitaire, expectedPU1);
        expect(facture.lignes[1].prixUnitaire, expectedPU2);
      });

      test('TYPE SOLDE: devrait créer facture solde avec acompte déduit', () {
        // ACT
        final facture = viewModel.prepareFacture(
          testDevis,
          'solde',
          Decimal.zero,
          false,
          dejaRegle:
              Decimal.parse('5000'), // Total déjà réglé via acomptes/situations
        );

        // ASSERT
        expect(facture.type, 'solde');
        expect(facture.objet, 'Solde - Devis Test');
        expect(facture.totalHt, Decimal.parse('10000'));
        expect(facture.acompteDejaRegle, Decimal.parse('5000'));
        expect(facture.lignes.length, 2);
        expect(facture.lignes[0].avancement, Decimal.fromInt(100));
        expect(facture.lignes[1].avancement, Decimal.fromInt(100));
      });

      test('devrait lancer une exception si devis sans ID', () {
        // ARRANGE
        final devisSansId = Devis(
          userId: 'user-1',
          numeroDevis: 'TEST',
          objet: 'Sans ID',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'brouillon',
        );

        // ACT & ASSERT
        expect(
          () => viewModel.prepareFacture(
              devisSansId, 'standard', Decimal.zero, false),
          throwsException,
        );
      });
    });

    group('duplicateDevis', () {
      test('devrait créer une copie brouillon du devis source', () {
        // ARRANGE
        final source = Devis(
          id: 'devis-original',
          userId: 'user-1',
          numeroDevis: 'DEV-2024-010',
          objet: 'Projet Original',
          clientId: 'client-1',
          dateEmission: DateTime(2024, 1, 15),
          dateValidite: DateTime(2024, 2, 15),
          totalHt: Decimal.parse('8000'),
          remiseTaux: Decimal.parse('5'),
          acompteMontant: Decimal.parse('2000'),
          statut: 'signe',
          estTransforme: true,
          lignes: [
            LigneDevis(
              id: 'ligne-d1',
              description: 'Démo ligne',
              quantite: Decimal.fromInt(4),
              prixUnitaire: Decimal.parse('2000'),
              totalLigne: Decimal.parse('8000'),
              type: 'article',
            ),
          ],
        );

        // ACT
        final duplicate = viewModel.duplicateDevis(source);

        // ASSERT
        expect(duplicate.id, isNull);
        expect(duplicate.numeroDevis, '');
        expect(duplicate.statut, 'brouillon');
        expect(duplicate.estTransforme, false);
        expect(duplicate.objet, 'Projet Original');
        expect(duplicate.clientId, 'client-1');
        expect(duplicate.totalHt, Decimal.parse('8000'));
        expect(duplicate.lignes.length, 1);
        expect(duplicate.lignes[0].id, isNull);
        expect(duplicate.lignes[0].description, 'Démo ligne');
      });
    });

    group('annulerDevis', () {
      test('devrait annuler un devis non signé', () async {
        // ARRANGE
        final testDevis = <Devis>[
          Devis(
            id: 'devis-to-cancel',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-020',
            objet: 'A annuler',
            clientId: 'client-1',
            dateEmission: DateTime.now(),
            dateValidite: DateTime.now().add(const Duration(days: 30)),
            totalHt: Decimal.parse('5000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'envoye',
          ),
        ];

        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => testDevis);
        await viewModel.fetchDevis();

        when(() => mockRepository.changeStatut(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => [
                  testDevis[0].copyWith(statut: 'annule'),
                ]);

        // ACT
        final result = await viewModel.annulerDevis('devis-to-cancel');

        // ASSERT
        expect(result, true);
        verify(() => mockRepository.changeStatut('devis-to-cancel', 'annule'))
            .called(1);
      });

      test('devrait retourner false si devis signé', () async {
        // ARRANGE
        final testDevis = <Devis>[
          Devis(
            id: 'devis-signe',
            userId: 'user-1',
            numeroDevis: 'DEV-2024-030',
            objet: 'Déjà signé',
            clientId: 'client-1',
            dateEmission: DateTime.now(),
            dateValidite: DateTime.now().add(const Duration(days: 30)),
            totalHt: Decimal.parse('5000'),
            remiseTaux: Decimal.zero,
            acompteMontant: Decimal.zero,
            statut: 'signe',
          ),
        ];

        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => testDevis);
        await viewModel.fetchDevis();

        // ACT
        final result = await viewModel.annulerDevis('devis-signe');

        // ASSERT
        expect(result, false);
        verifyNever(() => mockRepository.changeStatut(any(), any()));
      });
    });

    group('isLoading state', () {
      test('devrait être false initialement et après un fetch réussi',
          () async {
        // ARRANGE
        when(() => mockRepository.getDevis(archives: false))
            .thenAnswer((_) async => <Devis>[]);

        // ACT & ASSERT
        expect(viewModel.isLoading, false);
        await viewModel.fetchDevis();
        expect(viewModel.isLoading, false);
      });
    });
  });
}
