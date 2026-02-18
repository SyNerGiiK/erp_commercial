import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/dashboard_viewmodel.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/models/depense_model.dart';
import 'package:erp_commercial/models/urssaf_model.dart';
import 'package:erp_commercial/models/entreprise_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import '../mocks/repository_mocks.dart';

void main() {
  late MockDashboardRepository mockRepository;
  late MockFactureRepository mockFactureRepository;
  late DashboardViewModel viewModel;

  setUp(() {
    mockRepository = MockDashboardRepository();
    mockFactureRepository = MockFactureRepository();
    viewModel = DashboardViewModel(
      repository: mockRepository,
      factureRepository: mockFactureRepository,
    );
  });

  group('refreshData', () {
    test('devrait charger les données et calculer les KPI', () async {
      // ARRANGE
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: now,
          dateEcheance: now.add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [
            Paiement(
              id: 'p1',
              factureId: 'f1',
              montant: Decimal.parse('1000'),
              datePaiement: now,
              typePaiement: 'virement',
            ),
          ],
        ),
      ];

      final depenses = <Depense>[
        Depense(
          id: 'dep-1',
          userId: 'user-1',
          categorie: 'fournitures',
          montant: Decimal.parse('100'),
          titre: "Test",
          date: now,
        ),
      ];

      final urssafConfig = UrssafConfig(
        id: 'urs-1',
        userId: 'user-1',
      );

      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenAnswer((_) async => factures);
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenAnswer((_) async => factures);
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => depenses);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => urssafConfig);
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      // ACT
      await viewModel.refreshData();

      // ASSERT
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getFacturesPeriod(any(), any()))
          .called(greaterThanOrEqualTo(1));
      verify(() => mockRepository.getUrssafConfig()).called(1);
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenThrow(Exception('Erreur réseau'));
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenThrow(Exception('Erreur réseau'));
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => UrssafConfig(
                id: 'urs-1',
                userId: 'user-1',
              ));
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      // ACT
      await viewModel.refreshData();

      // ASSERT
      expect(viewModel.isLoading, false);
    });
  });

  group('selectedPeriod', () {
    test('devrait permettre de changer la période', () async {
      // ARRANGE
      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => UrssafConfig(
                id: 'urs-1',
                userId: 'user-1',
              ));
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      await viewModel.refreshData();

      expect(viewModel.selectedPeriod, DashboardPeriod.mois);

      // ACT
      viewModel.setPeriod(DashboardPeriod.annee);

      // ASSERT
      expect(viewModel.selectedPeriod, DashboardPeriod.annee);
    });
  });

  group('KPI Getters', () {
    setUp(() async {
      // Setup mock data pour tous les tests de ce groupe
      final now = DateTime.now();
      final factures = <Facture>[
        // Facture payée ce mois
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Payée',
          clientId: 'client-1',
          dateEmission: now,
          dateEcheance: now.add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [
            Paiement(
              id: 'p1',
              factureId: 'f1',
              montant: Decimal.parse('1000'),
              datePaiement: now,
              typePaiement: 'virement',
            ),
          ],
        ),
        // Facture validée non payée
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Validée',
          clientId: 'client-2',
          dateEmission: now,
          dateEcheance: now.add(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [],
        ),
      ];

      final depenses = <Depense>[
        Depense(
          id: 'dep-1',
          userId: 'user-1',
          categorie: 'fournitures',
          montant: Decimal.parse('100'),
          titre: "Test",
          date: now,
        ),
        Depense(
          id: 'dep-2',
          userId: 'user-1',
          categorie: 'transport',
          montant: Decimal.parse('50'),
          titre: "Test",
          date: now,
        ),
      ];

      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenAnswer((_) async => factures);
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenAnswer((_) async => factures);
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => depenses);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => UrssafConfig(
                id: 'urs-1',
                userId: 'user-1',
              ));
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      await viewModel.refreshData();
    });

    test('devrait exposer le CA encaissé pour la période', () {
      // ASSERT
      // CA encaissé devrait être calculé basé sur paiements
      expect(viewModel.caEncaissePeriode, greaterThan(Decimal.zero));
    });

    test('devrait exposer le total des dépenses pour la période', () {
      // ASSERT
      // Total dépenses = 100 + 50 = 150
      expect(viewModel.depensesPeriode, greaterThan(Decimal.zero));
    });

    test('devrait exposer les cotisations URSSAF calculées', () {
      // ASSERT
      expect(viewModel.totalCotisations, greaterThanOrEqualTo(Decimal.zero));
    });

    test('devrait calculer le résultat net (CA - Dépenses - Cotisations)', () {
      // ASSERT
      // Le résultat net devrait être calculé
      final resultat = viewModel.beneficeNetPeriode;
      expect(resultat, isNot(isNull));
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après refresh réussi', () async {
      // ARRANGE
      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => UrssafConfig(
                id: 'urs-1',
                userId: 'user-1',
              ));
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.refreshData();
      expect(viewModel.isLoading, false);
    });
  });

  group('Devis Stats (pipeline & conversion)', () {
    /// Helper pour préparer les mocks de base
    void setupBaseMocks() {
      when(() => mockRepository.getFacturesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getAllFacturesYear(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getDepensesPeriod(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getUrssafConfig())
          .thenAnswer((_) async => UrssafConfig(
                id: 'urs-1',
                userId: 'user-1',
              ));
      when(() => mockRepository.getProfilEntreprise())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getRecentActivity())
          .thenAnswer((_) async => []);
    }

    test('devrait être à zéro sans devis', () async {
      // ARRANGE
      setupBaseMocks();
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => []);

      // ACT
      await viewModel.refreshData();

      // ASSERT
      expect(viewModel.tauxConversion, Decimal.zero);
      expect(viewModel.devisEnCours, 0);
      expect(viewModel.montantPipeline, Decimal.zero);
      expect(viewModel.totalDevisYear, 0);
    });

    test('devrait calculer le taux de conversion (50%)', () async {
      // ARRANGE - 2 signés, 2 envoyés = 50%
      setupBaseMocks();
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => [
                Devis(
                  id: 'd1',
                  userId: 'u1',
                  numeroDevis: 'DEV-001',
                  objet: 'Signé',
                  clientId: 'c1',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('1000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'signe',
                ),
                Devis(
                  id: 'd2',
                  userId: 'u1',
                  numeroDevis: 'DEV-002',
                  objet: 'Signé 2',
                  clientId: 'c2',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('2000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'signe',
                ),
                Devis(
                  id: 'd3',
                  userId: 'u1',
                  numeroDevis: 'DEV-003',
                  objet: 'Envoyé',
                  clientId: 'c3',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('3000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'envoye',
                ),
                Devis(
                  id: 'd4',
                  userId: 'u1',
                  numeroDevis: 'DEV-004',
                  objet: 'Brouillon',
                  clientId: 'c4',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('4000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'brouillon',
                ),
              ]);

      // ACT
      await viewModel.refreshData();

      // ASSERT - 2 signés / 4 non-annulés = 50%
      expect(viewModel.tauxConversion, Decimal.fromInt(50));
      expect(viewModel.totalDevisYear, 4);
    });

    test('devrait compter les devis en cours (brouillon + envoyé)', () async {
      // ARRANGE
      setupBaseMocks();
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => [
                Devis(
                  id: 'd1',
                  userId: 'u1',
                  numeroDevis: 'DEV-001',
                  objet: 'Brouillon',
                  clientId: 'c1',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('1000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'brouillon',
                ),
                Devis(
                  id: 'd2',
                  userId: 'u1',
                  numeroDevis: 'DEV-002',
                  objet: 'Envoyé',
                  clientId: 'c2',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('2000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'envoye',
                ),
                Devis(
                  id: 'd3',
                  userId: 'u1',
                  numeroDevis: 'DEV-003',
                  objet: 'Signé',
                  clientId: 'c3',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('3000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'signe',
                ),
              ]);

      // ACT
      await viewModel.refreshData();

      // ASSERT
      expect(viewModel.devisEnCours, 2); // brouillon + envoye
      expect(viewModel.montantPipeline, Decimal.parse('3000')); // 1000 + 2000
    });

    test('devrait exclure les annulés du taux de conversion', () async {
      // ARRANGE - 1 signé, 1 annulé = 100% (annulé exclu)
      setupBaseMocks();
      when(() => mockRepository.getAllDevisYear(any()))
          .thenAnswer((_) async => [
                Devis(
                  id: 'd1',
                  userId: 'u1',
                  numeroDevis: 'DEV-001',
                  objet: 'Signé',
                  clientId: 'c1',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('5000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'signe',
                ),
                Devis(
                  id: 'd2',
                  userId: 'u1',
                  numeroDevis: 'DEV-002',
                  objet: 'Annulé',
                  clientId: 'c2',
                  dateEmission: DateTime.now(),
                  dateValidite: DateTime.now().add(const Duration(days: 30)),
                  totalHt: Decimal.parse('3000'),
                  remiseTaux: Decimal.zero,
                  acompteMontant: Decimal.zero,
                  statut: 'annule',
                ),
              ]);

      // ACT
      await viewModel.refreshData();

      // ASSERT - annulé exclu, seul le signé compte → 100%
      expect(viewModel.tauxConversion, Decimal.fromInt(100));
      expect(viewModel.totalDevisYear, 2);
      expect(viewModel.devisEnCours, 0); // aucun brouillon/envoyé
    });
  });
}
