import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/chiffrage_model.dart';
import 'package:erp_commercial/viewmodels/rentabilite_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// Fake pour mocktail registerFallbackValue
class FakeLigneChiffrage extends Fake implements LigneChiffrage {}

class FakeDevis extends Fake implements Devis {}

void main() {
  group('RentabiliteViewModel', () {
    late MockChiffrageRepository mockChiffrageRepo;
    late MockDevisRepository mockDevisRepo;
    late RentabiliteViewModel viewModel;

    setUpAll(() {
      registerFallbackValue(FakeLigneChiffrage());
      registerFallbackValue(FakeDevis());
    });

    setUp(() {
      mockChiffrageRepo = MockChiffrageRepository();
      mockDevisRepo = MockDevisRepository();
      viewModel = RentabiliteViewModel(
        chiffrageRepository: mockChiffrageRepo,
        devisRepository: mockDevisRepo,
      );
    });

    group('selectLigneDevis — auto-initialisation (BUG 1 fix)', () {
      late Devis testDevis;
      late LigneDevis ligneArticle;
      late LigneDevis ligneMo;
      late LigneDevis ligneTitre;

      setUp(() {
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
      late RentabiliteViewModel localVm;

      setUp(() {
        localChiffrageRepo = MockChiffrageRepository();
        localDevisRepo = MockDevisRepository();
        localVm = RentabiliteViewModel(
          chiffrageRepository: localChiffrageRepo,
          devisRepository: localDevisRepo,
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

      test('\"Pose carrelage\" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('Pose carrelage sol');
        expect(c, isNotNull);
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
        expect(c.prixAchatUnitaire, Decimal.zero);
      });

      test('\"Main d\'oeuvre électricité\" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription("Main d'oeuvre électricité");
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('\"Installation climatisation\" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription('Installation climatisation');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('\"8 heures de soudure\" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('8 heures de soudure');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('\"Peinture murs et plafonds\" → main d\'œuvre', () async {
        final c =
            await autoInitLigneAvecDescription('Peinture murs et plafonds');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('\"Câble RJ45 Cat6 50m\" → matériel', () async {
        final c = await autoInitLigneAvecDescription('Câble RJ45 Cat6 50m');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('\"Lot de vis inox 200 pièces\" → matériel', () async {
        final c =
            await autoInitLigneAvecDescription('Lot de vis inox 200 pièces');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('\"Tableau électrique 2 rangées\" → matériel', () async {
        final c =
            await autoInitLigneAvecDescription('Tableau électrique 2 rangées');
        expect(c!.typeChiffrage, TypeChiffrage.materiel);
      });

      test('\"Forfait MO plomberie\" → main d\'œuvre', () async {
        final c = await autoInitLigneAvecDescription('Forfait MO plomberie');
        expect(c!.typeChiffrage, TypeChiffrage.mainDoeuvre);
      });

      test('\"Intervention dépannage\" → main d\'œuvre', () async {
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
  });
}
