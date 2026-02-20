import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/urssaf_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/chiffrage_model.dart';
import 'package:erp_commercial/models/depense_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/models/entreprise_model.dart';
import 'package:erp_commercial/models/enums/entreprise_enums.dart';
import 'package:erp_commercial/viewmodels/rentabilite_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// Fake pour mocktail registerFallbackValue
class FakeLigneChiffrage extends Fake implements LigneChiffrage {}

class FakeDevis extends Fake implements Devis {}

void main() {
  group('RentabiliteViewModel', () {
    late MockChiffrageRepository mockChiffrageRepo;
    late MockDevisRepository mockDevisRepo;
    late MockFactureRepository mockFactureRepo;
    late RentabiliteViewModel viewModel;

    setUpAll(() {
      registerFallbackValue(FakeLigneChiffrage());
      registerFallbackValue(FakeDevis());
    });

    setUp(() {
      mockChiffrageRepo = MockChiffrageRepository();
      mockDevisRepo = MockDevisRepository();
      mockFactureRepo = MockFactureRepository();
      viewModel = RentabiliteViewModel(
        chiffrageRepository: mockChiffrageRepo,
        devisRepository: mockDevisRepo,
        factureRepository: mockFactureRepo,
      );
    });

    group('selectLigneDevis — auto-initialisation (BUG 1 fix)', () {
      late Devis testDevis;
      late LigneDevis ligneArticle;
      late LigneDevis ligneMo;
      late LigneDevis ligneTitre;

      setUp(() {
        // Configurer les mocks pour retourner des listes vides par défaut
        when(() => mockFactureRepo.getLinkedFactures(any()))
            .thenAnswer((_) async => []);

        ligneArticle = LigneDevis(
          id: 'ligne-1',
          description: 'Fourniture matériel',
          quantite: Decimal.fromInt(5),
          prixUnitaire: Decimal.parse('100'),
          totalLigne: Decimal.parse('500'),
          type: 'article',
        );

        ligneMo = LigneDevis(
          id: 'ligne-mo',
          description: 'Pose et installation électrique',
          quantite: Decimal.fromInt(8),
          prixUnitaire: Decimal.parse('50'),
          totalLigne: Decimal.parse('400'),
          type: 'article',
        );

        ligneTitre = LigneDevis(
          id: 'ligne-titre',
          description: 'SECTION TITRE',
          quantite: Decimal.zero,
          prixUnitaire: Decimal.zero,
          totalLigne: Decimal.zero,
          type: 'titre',
        );

        testDevis = Devis(
          id: 'devis-1',
          userId: 'user-1',
          numeroDevis: 'DEV-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('900'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [ligneArticle, ligneMo, ligneTitre],
        );
      });

      test(
          'devrait créer un coût matériel par défaut quand la description est matière/fourniture',
          () async {
        // ARRANGE — sélectionner le devis d'abord
        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [testDevis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-1'))
            .thenAnswer((_) async => []); // Aucun chiffrage existant

        final createdChiffrage = LigneChiffrage(
          id: 'chiffrage-auto-1',
          devisId: 'devis-1',
          linkedLigneDevisId: 'ligne-1',
          designation: 'Fourniture matériel',
          quantite: Decimal.fromInt(5),
          prixAchatUnitaire: Decimal.zero, // Prix d'achat inconnu
          prixVenteInterne: Decimal.parse('500'), // qté × PU = prix de vente
          typeChiffrage: TypeChiffrage.materiel,
          estAchete: false,
        );

        when(() => mockChiffrageRepo.create(any()))
            .thenAnswer((_) async => createdChiffrage);

        await viewModel.selectDevis(testDevis);

        // ACT — sélectionner la ligne article (vide)
        await viewModel.selectLigneDevis(ligneArticle);

        // ASSERT
        expect(viewModel.selectedLigneDevis, ligneArticle);
        verify(() => mockChiffrageRepo.create(any())).called(1);
        expect(viewModel.chiffragesForSelectedLigne.length, 1);
        expect(viewModel.chiffragesForSelectedLigne.first.designation,
            'Fourniture matériel');
        expect(viewModel.chiffragesForSelectedLigne.first.typeChiffrage,
            TypeChiffrage.materiel);
        expect(viewModel.chiffragesForSelectedLigne.first.prixVenteInterne,
            Decimal.parse('500'));
      });

      test(
          'devrait créer un coût main d\'œuvre quand la description contient des termes MO',
          () async {
        // ARRANGE
        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [testDevis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-1'))
            .thenAnswer((_) async => []);

        final createdMo = LigneChiffrage(
          id: 'chiffrage-mo-1',
          devisId: 'devis-1',
          linkedLigneDevisId: 'ligne-mo',
          designation: 'Pose et installation électrique',
          quantite: Decimal.fromInt(8),
          prixAchatUnitaire: Decimal.zero,
          prixVenteInterne: Decimal.parse('400'),
          typeChiffrage: TypeChiffrage.mainDoeuvre,
          estAchete: false,
        );

        when(() => mockChiffrageRepo.create(any()))
            .thenAnswer((_) async => createdMo);

        await viewModel.selectDevis(testDevis);

        // ACT — sélectionner la ligne "Pose et installation" → détectée MO
        await viewModel.selectLigneDevis(ligneMo);

        // ASSERT
        verify(() => mockChiffrageRepo.create(any())).called(1);
        expect(viewModel.chiffragesForSelectedLigne.length, 1);
        expect(viewModel.chiffragesForSelectedLigne.first.typeChiffrage,
            TypeChiffrage.mainDoeuvre);
      });

      test(
          'ne devrait PAS créer de chiffrage pour les lignes de type titre/sous-titre/texte/saut_page',
          () async {
        // ARRANGE
        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [testDevis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-1'))
            .thenAnswer((_) async => []);

        await viewModel.selectDevis(testDevis);

        // ACT — sélectionner une ligne titre
        await viewModel.selectLigneDevis(ligneTitre);

        // ASSERT — pas d'appel create
        verifyNever(() => mockChiffrageRepo.create(any()));
      });

      test('ne devrait PAS créer de chiffrage si la ligne a déjà des coûts',
          () async {
        // ARRANGE — un chiffrage existe déjà pour ligne-1
        final existingChiffrage = LigneChiffrage(
          id: 'existing-1',
          devisId: 'devis-1',
          linkedLigneDevisId: 'ligne-1',
          designation: 'Coût existant',
          quantite: Decimal.one,
          prixAchatUnitaire: Decimal.parse('50'),
          prixVenteInterne: Decimal.parse('200'),
          typeChiffrage: TypeChiffrage.materiel,
        );

        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [testDevis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-1'))
            .thenAnswer((_) async => [existingChiffrage]);

        await viewModel.selectDevis(testDevis);

        // ACT — sélectionner la ligne qui a déjà un chiffrage
        await viewModel.selectLigneDevis(ligneArticle);

        // ASSERT — pas de nouvel appel create
        verifyNever(() => mockChiffrageRepo.create(any()));
        expect(viewModel.chiffragesForSelectedLigne.length, 1);
      });

      test('devrait ignorer les erreurs du repo sans crash (résilience)',
          () async {
        // ARRANGE
        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [testDevis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-1'))
            .thenAnswer((_) async => []);
        when(() => mockChiffrageRepo.create(any()))
            .thenThrow(Exception('Erreur réseau'));

        await viewModel.selectDevis(testDevis);

        // ACT — ne devrait pas lancer d'exception
        await viewModel.selectLigneDevis(ligneArticle);

        // ASSERT — la sélection est faite malgré l'erreur
        expect(viewModel.selectedLigneDevis, ligneArticle);
        expect(viewModel.chiffragesForSelectedLigne, isEmpty);
      });
    });

    group('getAvancementsForFactureSituation', () {
      test('devrait retourner une map des avancements par ligne', () async {
        final ligneA = LigneDevis(
          id: 'ligne-a',
          description: 'Ligne A',
          quantite: Decimal.fromInt(1),
          prixUnitaire: Decimal.parse('1000'),
          totalLigne: Decimal.parse('1000'),
          type: 'article',
        );

        final devis = Devis(
          id: 'devis-test',
          userId: 'user-1',
          numeroDevis: 'D-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [ligneA],
        );

        // Matériel acheté → 100% de prixVenteInterne
        final chiffrage = LigneChiffrage(
          id: 'c1',
          devisId: 'devis-test',
          linkedLigneDevisId: 'ligne-a',
          designation: 'Mat',
          quantite: Decimal.one,
          prixAchatUnitaire: Decimal.parse('500'),
          prixVenteInterne: Decimal.parse('1000'),
          typeChiffrage: TypeChiffrage.materiel,
          estAchete: true,
        );

        when(() => mockDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [devis]);
        when(() => mockChiffrageRepo.getByDevisId('devis-test'))
            .thenAnswer((_) async => [chiffrage]);

        await viewModel.selectDevis(devis);

        // ACT
        final avancements = viewModel.getAvancementsForFactureSituation();

        // ASSERT — matériel acheté with prixVenteInterne = total ligne → 100%
        expect(avancements['ligne-a'], Decimal.fromInt(100));
      });
    });

    group('Détection textuelle type chiffrage (MO vs Matériel)', () {
      late MockChiffrageRepository localChiffrageRepo;
      late MockDevisRepository localDevisRepo;
      late MockFactureRepository localFactureRepo;
      late RentabiliteViewModel localVm;

      setUp(() {
        localChiffrageRepo = MockChiffrageRepository();
        localDevisRepo = MockDevisRepository();
        localFactureRepo = MockFactureRepository();
        when(() => localFactureRepo.getLinkedFactures(any()))
            .thenAnswer((_) async => []);
        localVm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          factureRepository: localFactureRepo,
        );
      });

      Future<LigneChiffrage?> autoInitLigneAvecDescription(
          String description) async {
        final ligne = LigneDevis(
          id: 'test-ligne',
          description: description,
          quantite: Decimal.fromInt(1),
          prixUnitaire: Decimal.parse('100'),
          totalLigne: Decimal.parse('100'),
          type: 'article',
        );

        final devis = Devis(
          id: 'devis-detect',
          userId: 'u1',
          numeroDevis: 'D-DET',
          objet: 'Test détection',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('100'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [ligne],
        );

        LigneChiffrage? captured;
        when(() => localDevisRepo.getDevis(archives: false))
            .thenAnswer((_) async => [devis]);
        when(() => localChiffrageRepo.getByDevisId('devis-detect'))
            .thenAnswer((_) async => []);
        when(() => localChiffrageRepo.create(any())).thenAnswer((inv) async {
          captured = inv.positionalArguments.first as LigneChiffrage;
          return captured!.copyWith(id: 'auto-id');
        });

        await localVm.selectDevis(devis);
        await localVm.selectLigneDevis(ligne);
        return captured;
      }

      test('"Pose carrelage" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('Pose carrelage sol');
        expect(c, isNotNull);
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
        expect(c.prixAchatUnitaire, Decimal.zero);
      });

      test('"Main d\'oeuvre électricité" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription("Main d'oeuvre électricité");
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('"Installation climatisation" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription('Installation climatisation');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('"8 heures de soudure" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('8 heures de soudure');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('"Peinture murs et plafonds" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription('Peinture murs et plafonds');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('"Câble RJ45 Cat6 50m" → matériel', () async {
        final c = await autoInitLigneAvecDescription('Câble RJ45 Cat6 50m');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('"Lot de vis inox 200 pièces" → matériel', () async {
        final c =
            await autoInitLigneAvecDescription('Lot de vis inox 200 pièces');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('"Tableau électrique 2 rangées" → matériel', () async {
        final c =
            await autoInitLigneAvecDescription('Tableau électrique 2 rangées');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('"Forfait MO plomberie" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('Forfait MO plomberie');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('"Intervention dépannage" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('Intervention dépannage');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('prixAchatUnitaire est toujours Decimal.zero à l\'auto-init',
          () async {
        final c = await autoInitLigneAvecDescription('Fourniture PVC 100mm');
        expect(c!.prixAchatUnitaire, Decimal.zero);
        expect(c.prixVenteInterne, Decimal.parse('100'));
      });
    });

    group('getTauxEncaissementForDevis — toutes factures liées', () {
      late MockChiffrageRepository localChiffrageRepo;
      late MockDevisRepository localDevisRepo;
      late MockFactureRepository localFactureRepo;
      late RentabiliteViewModel localVm;

      late Devis testDevis;

      setUp(() {
        localChiffrageRepo = MockChiffrageRepository();
        localDevisRepo = MockDevisRepository();
        localFactureRepo = MockFactureRepository();

        localVm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          factureRepository: localFactureRepo,
        );

        testDevis = Devis(
          id: 'devis-enc',
          userId: 'u1',
          numeroDevis: 'D-ENC',
          objet: 'Test Encaissement',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          totalTtc: Decimal.parse('1200'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.parse('360'),
          statut: 'signe',
        );
      });

      test(
          'devrait calculer l\'encaissement à partir des paiements des factures liées',
          () async {
        // ARRANGE — 2 factures liées avec des paiements
        final facture1 = Facture(
          id: 'f1',
          objet: 'Acompte',
          clientId: 'c1',
          devisSourceId: 'devis-enc',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('300'),
          totalTtc: Decimal.parse('360'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [
            Paiement(
              factureId: 'f1',
              montant: Decimal.parse('360'),
              datePaiement: DateTime.now(),
              isAcompte: true,
            ),
          ],
        );

        final facture2 = Facture(
          id: 'f2',
          objet: 'Situation 1',
          clientId: 'c1',
          devisSourceId: 'devis-enc',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          totalTtc: Decimal.parse('600'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.parse('360'),
          statut: 'payee',
          paiements: [
            Paiement(
              factureId: 'f2',
              montant: Decimal.parse('240'),
              datePaiement: DateTime.now(),
            ),
          ],
        );

        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localFactureRepo.getLinkedFactures('devis-enc'))
            .thenAnswer((_) async => [facture1, facture2]);

        await localVm.loadDevis();

        // ACT
        final taux = localVm.getTauxEncaissementForDevis(testDevis);

        // ASSERT — total paiements = 360 + 240 = 600, totalTtc = 1200 → 50%
        expect(taux, Decimal.fromInt(50));
      });

      test('devrait retourner 0 si aucune facture liée', () async {
        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localFactureRepo.getLinkedFactures('devis-enc'))
            .thenAnswer((_) async => []);

        await localVm.loadDevis();

        final taux = localVm.getTauxEncaissementForDevis(testDevis);
        expect(taux, Decimal.zero);
      });

      test(
          'devrait utiliser montantNetFacture si supérieur aux paiements enregistrés',
          () async {
        // Facture validée sans paiement enregistré mais avec statut envoyé
        final facture = Facture(
          id: 'f3',
          objet: 'Facture finale',
          clientId: 'c1',
          devisSourceId: 'devis-enc',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          totalTtc: Decimal.parse('1200'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [],
        );

        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localFactureRepo.getLinkedFactures('devis-enc'))
            .thenAnswer((_) async => [facture]);

        await localVm.loadDevis();

        final taux = localVm.getTauxEncaissementForDevis(testDevis);

        // montantNetFacture = totalTtc - acompteDejaRegle = 1200 - 0 = 1200
        // 1200 / 1200 * 100 = 100%
        expect(taux, Decimal.fromInt(100));
      });

      test('devrait ignorer les factures brouillon et annulées', () async {
        final factureBrouillon = Facture(
          id: 'f-brouillon',
          objet: 'Brouillon',
          clientId: 'c1',
          devisSourceId: 'devis-enc',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          totalTtc: Decimal.parse('1200'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'brouillon',
          paiements: [],
        );

        final factureAnnulee = Facture(
          id: 'f-annulee',
          objet: 'Annulée',
          clientId: 'c1',
          devisSourceId: 'devis-enc',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          totalTtc: Decimal.parse('600'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'annulee',
          paiements: [],
        );

        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localFactureRepo.getLinkedFactures('devis-enc'))
            .thenAnswer((_) async => [factureBrouillon, factureAnnulee]);

        await localVm.loadDevis();

        final taux = localVm.getTauxEncaissementForDevis(testDevis);
        // Brouillon et annulée sont ignorés → 0 paiements, 0 factures nettes
        expect(taux, Decimal.zero);
      });
    });

    group('Résultat avec cotisations micro-entrepreneur (UrssafConfig)', () {
      late MockChiffrageRepository localChiffrageRepo;
      late MockDevisRepository localDevisRepo;
      late MockDepenseRepository localDepenseRepo;
      late MockFactureRepository localFactureRepo;
      late MockUrssafRepository localUrssafRepo;
      late RentabiliteViewModel localVm;

      late Devis testDevis;
      late LigneChiffrage chiffrage1;
      late Depense depense1;

      setUp(() {
        localChiffrageRepo = MockChiffrageRepository();
        localDevisRepo = MockDevisRepository();
        localDepenseRepo = MockDepenseRepository();
        localFactureRepo = MockFactureRepository();
        localUrssafRepo = MockUrssafRepository();

        // Config micro artisan BIC par défaut : 21.2% social + 0.3% CFP + 0.48% TFC
        final config = UrssafConfig(userId: 'test');

        localVm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          depenseRepository: localDepenseRepo,
          factureRepository: localFactureRepo,
          urssafRepository: localUrssafRepo,
          urssafConfig: config,
        );

        testDevis = Devis(
          id: 'devis-charges',
          userId: 'u1',
          numeroDevis: 'D-CHG',
          objet: 'Test Charges',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('10000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [
            LigneDevis(
              id: 'l1',
              description: 'Fourniture',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('10000'),
              totalLigne: Decimal.parse('10000'),
              type: 'article',
              typeActivite: 'service', // Prestation BIC
            ),
          ],
        );

        chiffrage1 = LigneChiffrage(
          id: 'c-chg-1',
          devisId: 'devis-charges',
          linkedLigneDevisId: 'l1',
          designation: 'Fourniture',
          quantite: Decimal.fromInt(1),
          prixAchatUnitaire: Decimal.parse('3000'),
          prixVenteInterne: Decimal.parse('10000'),
          typeChiffrage: TypeChiffrage.materiel,
          estAchete: true,
        );

        depense1 = Depense(
          id: 'dep-1',
          titre: 'Achat matériel',
          montant: Decimal.parse('2500'),
          date: DateTime.now(),
          categorie: 'materiaux',
          chantierDevisId: 'devis-charges',
        );
      });

      test(
          'chargesSociales = social + cfp + tfc sur netCommercial (100% service BIC)',
          () async {
        when(() => localChiffrageRepo.getByDevisId('devis-charges'))
            .thenAnswer((_) async => [chiffrage1]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-charges'))
            .thenAnswer((_) async => [depense1]);
        when(() => localFactureRepo.getLinkedFactures('devis-charges'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(testDevis);

        // netCommercial = 10000, 100% service BIC
        // social = 10000 * 21.2% = 2120
        // cfp = 10000 * 0.3% = 30
        // tfc = 10000 * 0.48% = 48
        // total = 2198
        expect(localVm.chargesSociales, Decimal.parse('2198'));
      });

      test('detailCotisations retourne la ventilation correcte', () async {
        when(() => localChiffrageRepo.getByDevisId('devis-charges'))
            .thenAnswer((_) async => [chiffrage1]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-charges'))
            .thenAnswer((_) async => []);
        when(() => localFactureRepo.getLinkedFactures('devis-charges'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(testDevis);

        final detail = localVm.detailCotisations;
        expect(detail['social'], Decimal.parse('2120')); // 21.2%
        expect(detail['cfp'], Decimal.parse('30')); // 0.3%
        expect(detail['tfc'], Decimal.parse('48')); // 0.48%
        expect(detail['liberatoire'], Decimal.zero);
        expect(detail['total'], Decimal.parse('2198'));
      });

      test('resultatPrevisionnel = margePrevue - charges', () async {
        when(() => localChiffrageRepo.getByDevisId('devis-charges'))
            .thenAnswer((_) async => [chiffrage1]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-charges'))
            .thenAnswer((_) async => [depense1]);
        when(() => localFactureRepo.getLinkedFactures('devis-charges'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(testDevis);

        // margePrevue = 10000 - 3000 = 7000
        // charges = 2198
        // résultat = 7000 - 2198 = 4802
        expect(localVm.margePrevue, Decimal.parse('7000'));
        expect(localVm.resultatPrevisionnel, Decimal.parse('4802'));
      });

      test('resultatReel = margeReelle - charges', () async {
        when(() => localChiffrageRepo.getByDevisId('devis-charges'))
            .thenAnswer((_) async => [chiffrage1]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-charges'))
            .thenAnswer((_) async => [depense1]);
        when(() => localFactureRepo.getLinkedFactures('devis-charges'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(testDevis);

        // margeReelle = 10000 - 2500 = 7500
        // charges = 2198
        // résultat = 7500 - 2198 = 5302
        expect(localVm.margeReelle, Decimal.parse('7500'));
        expect(localVm.resultatReel, Decimal.parse('5302'));
      });

      test('charges calculées sur netCommercial avec remise', () async {
        final devisAvecRemise = Devis(
          id: 'devis-remise',
          userId: 'u1',
          numeroDevis: 'D-REM',
          objet: 'Test Remise',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('10000'),
          remiseTaux: Decimal.parse('10'), // 10% remise
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [
            LigneDevis(
              id: 'lr1',
              description: 'Prestation',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('10000'),
              totalLigne: Decimal.parse('10000'),
              type: 'article',
              typeActivite: 'service',
            ),
          ],
        );

        when(() => localChiffrageRepo.getByDevisId('devis-remise'))
            .thenAnswer((_) async => []);
        when(() => localDepenseRepo.getDepensesByChantier('devis-remise'))
            .thenAnswer((_) async => []);
        when(() => localFactureRepo.getLinkedFactures('devis-remise'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(devisAvecRemise);

        // netCommercial = 10000 - (10000 * 10%) = 9000
        // social = 9000 * 21.2% = 1908
        // cfp = 9000 * 0.3% = 27
        // tfc = 9000 * 0.48% = 43.2
        // total = 1978.2
        expect(localVm.chargesSociales, Decimal.parse('1978.2'));
      });

      test('ventilation mixte vente/prestation applique les bons taux',
          () async {
        final devisMixte = Devis(
          id: 'devis-mixte',
          userId: 'u1',
          numeroDevis: 'D-MIX',
          objet: 'Test Mixte',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('10000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [
            LigneDevis(
              id: 'lv1',
              description: 'Vente matériel',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('4000'),
              totalLigne: Decimal.parse('4000'),
              type: 'article',
              typeActivite: 'commerce', // Vente
            ),
            LigneDevis(
              id: 'ls1',
              description: 'Prestation service',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('6000'),
              totalLigne: Decimal.parse('6000'),
              type: 'article',
              typeActivite: 'service', // Service BIC
            ),
          ],
        );

        when(() => localChiffrageRepo.getByDevisId('devis-mixte'))
            .thenAnswer((_) async => []);
        when(() => localDepenseRepo.getDepensesByChantier('devis-mixte'))
            .thenAnswer((_) async => []);
        when(() => localFactureRepo.getLinkedFactures('devis-mixte'))
            .thenAnswer((_) async => []);

        await localVm.selectDevis(devisMixte);

        final detail = localVm.detailCotisations;
        // caVente = 4000 (12.3%), caPrestation = 6000 (21.2%)
        // social_vente = 4000 * 12.3% = 492
        // social_bic = 6000 * 21.2% = 1272
        // social = 1764
        expect(detail['social'], Decimal.parse('1764'));

        // cfp_vente = 4000 * 0.3% = 12, cfp_bic = 6000 * 0.3% = 18 → 30
        expect(detail['cfp'], Decimal.parse('30'));

        // tfc_vente = 4000 * 0.22% = 8.8, tfc_service = 6000 * 0.48% = 28.8 → 37.6
        expect(detail['tfc'], Decimal.parse('37.6'));

        // total = 1764 + 30 + 37.6 = 1831.6
        expect(detail['total'], Decimal.parse('1831.6'));
      });

      test('retourne Decimal.zero sans devis sélectionné', () {
        expect(localVm.chargesSociales, Decimal.zero);
        expect(localVm.resultatPrevisionnel, Decimal.zero);
        expect(localVm.resultatReel, Decimal.zero);
        expect(localVm.detailCotisations['social'], Decimal.zero);
      });
    });

    group('calculerCotisationsTNS — calculs TNS sur bénéfice', () {
      late UrssafConfig config;

      setUp(() {
        config = UrssafConfig(userId: 'test');
      });

      test('bénéfice 10000 → total ~4560', () {
        final result = config.calculerCotisationsTNS(Decimal.parse('10000'));

        expect(result['maladie'], Decimal.parse('650'));
        expect(result['allocations_familiales'], Decimal.parse('310'));
        expect(result['retraite_base'], Decimal.parse('1775'));
        expect(result['retraite_complementaire'], Decimal.parse('700'));
        expect(result['invalidite_deces'], Decimal.parse('130'));
        expect(result['csg_crds'], Decimal.parse('970'));
        expect(result['cfp'], Decimal.parse('25'));

        // social = 650 + 310 + 1775 + 700 + 130 + 970 = 4535
        expect(result['social'], Decimal.parse('4535'));
        // total = 4535 + 25 = 4560
        expect(result['total'], Decimal.parse('4560'));
      });

      test('bénéfice 0 → tout à zéro', () {
        final result = config.calculerCotisationsTNS(Decimal.zero);

        expect(result['total'], Decimal.zero);
        expect(result['social'], Decimal.zero);
        expect(result['cfp'], Decimal.zero);
        expect(result['maladie'], Decimal.zero);
      });

      test('bénéfice négatif → tout à zéro', () {
        final result = config.calculerCotisationsTNS(Decimal.parse('-5000'));

        expect(result['total'], Decimal.zero);
        expect(result['social'], Decimal.zero);
      });

      test('tfc et liberatoire toujours à zéro pour TNS', () {
        final result = config.calculerCotisationsTNS(Decimal.parse('10000'));

        expect(result['tfc'], Decimal.zero);
        expect(result['liberatoire'], Decimal.zero);
      });
    });

    group('Branchement régime dans RentabiliteViewModel', () {
      late MockChiffrageRepository localChiffrageRepo;
      late MockDevisRepository localDevisRepo;
      late MockDepenseRepository localDepenseRepo;
      late MockFactureRepository localFactureRepo;
      late MockEntrepriseRepository localEntrepriseRepo;

      late Devis testDevis;
      late LigneChiffrage chiffrage1;
      late Depense depense1;

      setUp(() {
        localChiffrageRepo = MockChiffrageRepository();
        localDevisRepo = MockDevisRepository();
        localDepenseRepo = MockDepenseRepository();
        localFactureRepo = MockFactureRepository();
        localEntrepriseRepo = MockEntrepriseRepository();

        testDevis = Devis(
          id: 'devis-tns',
          userId: 'u1',
          numeroDevis: 'D-TNS',
          objet: 'Test TNS',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('10000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          lignes: [
            LigneDevis(
              id: 'l1',
              description: 'Prestation',
              quantite: Decimal.fromInt(1),
              prixUnitaire: Decimal.parse('10000'),
              totalLigne: Decimal.parse('10000'),
              type: 'article',
              typeActivite: 'service',
            ),
          ],
        );

        chiffrage1 = LigneChiffrage(
          id: 'c-tns-1',
          devisId: 'devis-tns',
          linkedLigneDevisId: 'l1',
          designation: 'Prestation',
          quantite: Decimal.fromInt(1),
          prixAchatUnitaire: Decimal.parse('3000'),
          prixVenteInterne: Decimal.parse('10000'),
          typeChiffrage: TypeChiffrage.materiel,
          estAchete: true,
        );

        depense1 = Depense(
          id: 'dep-tns',
          titre: 'Charges',
          montant: Decimal.parse('2000'),
          date: DateTime.now(),
          categorie: 'materiaux',
          chantierDevisId: 'devis-tns',
        );
      });

      test('régime TNS : cotisations calculées sur bénéfice (marge réelle)',
          () async {
        // ARRANGE — profil EI (TNS)
        final profilTNS = ProfilEntreprise(
          id: 'p1',
          userId: 'u1',
          nomEntreprise: 'Test EI',
          nomGerant: 'Dupont',
          adresse: '1 rue',
          codePostal: '75000',
          ville: 'Paris',
          siret: '12345678901234',
          email: 'test@test.fr',
          typeEntreprise: TypeEntreprise.entrepriseIndividuelle,
        );

        when(() => localEntrepriseRepo.getProfil())
            .thenAnswer((_) async => profilTNS);
        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-tns'))
            .thenAnswer((_) async => [depense1]);
        when(() => localFactureRepo.getLinkedFactures('devis-tns'))
            .thenAnswer((_) async => []);
        when(() => localChiffrageRepo.getByDevisId('devis-tns'))
            .thenAnswer((_) async => [chiffrage1]);

        final vm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          depenseRepository: localDepenseRepo,
          factureRepository: localFactureRepo,
          entrepriseRepository: localEntrepriseRepo,
          urssafConfig: UrssafConfig(userId: 'test'),
        );

        await vm.loadDevis();
        await vm.selectDevis(testDevis);

        // margeReelle = 10000 - 2000 = 8000
        // Cotisations TNS sur 8000:
        // social = 8000 * (6.5+3.1+17.75+7+1.3+9.7)% = 8000 * 45.35% = 3628
        // cfp = 8000 * 0.25% = 20
        // total = 3648
        expect(vm.typeEntreprise, TypeEntreprise.entrepriseIndividuelle);
        expect(vm.margeReelle, Decimal.parse('8000'));
        expect(vm.chargesSociales, Decimal.parse('3648'));
        expect(vm.resultatReel, Decimal.parse('4352')); // 8000 - 3648
      });

      test('régime SASU : cotisations à zéro, isRegimeNonSupporte = true',
          () async {
        final profilSASU = ProfilEntreprise(
          id: 'p2',
          userId: 'u1',
          nomEntreprise: 'Test SASU',
          nomGerant: 'Martin',
          adresse: '2 rue',
          codePostal: '75001',
          ville: 'Paris',
          siret: '12345678901235',
          email: 'sasu@test.fr',
          typeEntreprise: TypeEntreprise.sasu,
        );

        when(() => localEntrepriseRepo.getProfil())
            .thenAnswer((_) async => profilSASU);
        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-tns'))
            .thenAnswer((_) async => []);
        when(() => localFactureRepo.getLinkedFactures('devis-tns'))
            .thenAnswer((_) async => []);
        when(() => localChiffrageRepo.getByDevisId('devis-tns'))
            .thenAnswer((_) async => [chiffrage1]);

        final vm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          depenseRepository: localDepenseRepo,
          factureRepository: localFactureRepo,
          entrepriseRepository: localEntrepriseRepo,
          urssafConfig: UrssafConfig(userId: 'test'),
        );

        await vm.loadDevis();
        await vm.selectDevis(testDevis);

        expect(vm.typeEntreprise, TypeEntreprise.sasu);
        expect(vm.isRegimeNonSupporte, true);
        expect(vm.chargesSociales, Decimal.zero);
        expect(vm.detailCotisations['total'], Decimal.zero);
      });

      test('régime micro par défaut quand profil null', () async {
        when(() => localEntrepriseRepo.getProfil())
            .thenAnswer((_) async => null);
        when(() => localDevisRepo.getChantiersActifs())
            .thenAnswer((_) async => [testDevis]);
        when(() => localDepenseRepo.getDepensesByChantier('devis-tns'))
            .thenAnswer((_) async => []);
        when(() => localFactureRepo.getLinkedFactures('devis-tns'))
            .thenAnswer((_) async => []);
        when(() => localChiffrageRepo.getByDevisId('devis-tns'))
            .thenAnswer((_) async => [chiffrage1]);

        final vm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
          depenseRepository: localDepenseRepo,
          factureRepository: localFactureRepo,
          entrepriseRepository: localEntrepriseRepo,
          urssafConfig: UrssafConfig(userId: 'test'),
        );

        await vm.loadDevis();
        await vm.selectDevis(testDevis);

        // Default micro → cotisations calculées sur CA
        expect(vm.typeEntreprise, TypeEntreprise.microEntrepreneur);
        expect(vm.isRegimeNonSupporte, false);
        // Charges > 0 car calcul micro sur CA
        expect(vm.chargesSociales > Decimal.zero, true);
      });
    });
  });
}
