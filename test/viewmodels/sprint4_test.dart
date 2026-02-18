import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/devis_viewmodel.dart';
import 'package:erp_commercial/viewmodels/facture_viewmodel.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/services/pdf_service.dart';
import '../mocks/repository_mocks.dart';

// Fakes pour mocktail
class FakeDevis extends Fake implements Devis {}

class FakeFacture extends Fake implements Facture {}

class FakePaiement extends Fake implements Paiement {}

void main() {
  // =====================================================================
  // SPRINT 4 TESTS
  // =====================================================================

  group('Sprint 4 — finalizeDevis simplifié (délégation SQL)', () {
    late MockDevisRepository mockRepo;
    late DevisViewModel viewModel;

    setUpAll(() {
      registerFallbackValue(FakeDevis());
    });

    setUp(() {
      mockRepo = MockDevisRepository();
      viewModel = DevisViewModel(repository: mockRepo);
    });

    test('finaliserDevis devrait appeler finalizeDevis sur le repo', () async {
      // ARRANGE
      final devis = Devis(
        id: 'devis-abc',
        userId: 'user-1',
        numeroDevis: 'Brouillon',
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateValidite: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        statut: 'brouillon',
      );

      when(() => mockRepo.finalizeDevis('devis-abc'))
          .thenAnswer((_) async {});
      when(() => mockRepo.getDevis(archives: false))
          .thenAnswer((_) async => []);

      // ACT
      final result = await viewModel.finaliserDevis(devis);

      // ASSERT
      expect(result, true);
      verify(() => mockRepo.finalizeDevis('devis-abc')).called(1);
      // generateNextNumero ne doit PAS être appelé
      verifyNever(() => mockRepo.generateNextNumero(any()));
    });

    test(
        'finaliserDevis ne devrait PAS appeler generateNextNumero (délégation SQL)',
        () async {
      // ARRANGE
      final devis = Devis(
        id: 'devis-xyz',
        userId: 'user-1',
        numeroDevis: 'Brouillon',
        objet: 'Test delegation SQL',
        clientId: 'c2',
        dateEmission: DateTime(2024, 3, 1),
        dateValidite: DateTime(2024, 4, 1),
        totalHt: Decimal.parse('500'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        statut: 'brouillon',
      );

      when(() => mockRepo.finalizeDevis('devis-xyz'))
          .thenAnswer((_) async {});
      when(() => mockRepo.getDevis(archives: false))
          .thenAnswer((_) async => []);

      // ACT
      await viewModel.finaliserDevis(devis);

      // ASSERT — Aucun appel à generateNextNumero
      verifyNever(() => mockRepo.generateNextNumero(any()));
    });

    test('finaliserDevis devrait retourner false si devis.id est null',
        () async {
      // ARRANGE
      final devis = Devis(
        id: null,
        userId: 'user-1',
        numeroDevis: 'Brouillon',
        objet: 'Sans ID',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateValidite: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('0'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        statut: 'brouillon',
      );

      // ACT
      final result = await viewModel.finaliserDevis(devis);

      // ASSERT
      expect(result, false);
      verifyNever(() => mockRepo.finalizeDevis(any()));
    });
  });

  group('Sprint 4 — PdfGenerationRequest embarque factureSourceNumero', () {
    test('PdfGenerationRequest accepte factureSourceNumero', () {
      final request = PdfGenerationRequest(
        document: {'id': 'test', 'type': 'avoir'},
        documentType: 'facture',
        client: null,
        profil: null,
        docTypeLabel: 'AVOIR',
        isTvaApplicable: false,
        factureSourceNumero: 'FAC-2024-0001',
      );

      expect(request.factureSourceNumero, 'FAC-2024-0001');
    });

    test('PdfGenerationRequest avec factureSourceNumero null par défaut', () {
      final request = PdfGenerationRequest(
        document: {'id': 'test', 'type': 'standard'},
        documentType: 'facture',
        client: null,
        profil: null,
        docTypeLabel: 'FACTURE',
        isTvaApplicable: true,
      );

      expect(request.factureSourceNumero, isNull);
    });
  });

  group('Sprint 4 — Facture model numeroBonCommande & motifAvoir', () {
    test('Facture devrait stocker numeroBonCommande', () {
      final facture = Facture(
        userId: 'user-1',
        numeroFacture: 'FAC-2024-001',
        objet: 'Test BC',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateEcheance: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        numeroBonCommande: 'BC-2024-123',
      );

      expect(facture.numeroBonCommande, 'BC-2024-123');
    });

    test('Facture devrait stocker motifAvoir', () {
      final facture = Facture(
        userId: 'user-1',
        numeroFacture: 'AVR-2024-001',
        objet: 'Avoir test',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateEcheance: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('500'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        type: 'avoir',
        motifAvoir: 'Retour marchandise',
        factureSourceId: 'facture-source-id',
      );

      expect(facture.motifAvoir, 'Retour marchandise');
      expect(facture.type, 'avoir');
      expect(facture.factureSourceId, 'facture-source-id');
    });

    test('Facture.toMap devrait inclure numeroBonCommande et motifAvoir', () {
      final facture = Facture(
        userId: 'user-1',
        numeroFacture: 'FAC-2024-001',
        objet: 'Test map',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateEcheance: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        numeroBonCommande: 'BC-42',
        motifAvoir: 'Erreur facturation',
      );

      final map = facture.toMap();
      expect(map['numero_bon_commande'], 'BC-42');
      expect(map['motif_avoir'], 'Erreur facturation');
    });

    test('Facture.fromMap devrait lire numeroBonCommande et motifAvoir', () {
      final map = {
        'id': 'f1',
        'user_id': 'u1',
        'numero_facture': 'FAC-2024-001',
        'objet': 'Test from map',
        'client_id': 'c1',
        'date_emission': '2024-01-01T00:00:00.000',
        'date_echeance': '2024-02-01T00:00:00.000',
        'total_ht': '1000',
        'remise_taux': '0',
        'acompte_deja_regle': '0',
        'numero_bon_commande': 'BON-99',
        'motif_avoir': 'Annulation partielle',
        'statut': 'brouillon',
      };

      final facture = Facture.fromMap(map);
      expect(facture.numeroBonCommande, 'BON-99');
      expect(facture.motifAvoir, 'Annulation partielle');
    });

    test('Facture.copyWith devrait permettre de modifier les champs', () {
      final original = Facture(
        userId: 'user-1',
        numeroFacture: 'FAC-2024-001',
        objet: 'Original',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateEcheance: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final withBC =
          original.copyWith(numeroBonCommande: 'BC-NEW');
      final withMotif = original.copyWith(motifAvoir: 'Erreur');

      expect(withBC.numeroBonCommande, 'BC-NEW');
      expect(withMotif.motifAvoir, 'Erreur');
    });
  });

  group('Sprint 4 — FactureViewModel résolution factureSourceNumero', () {
    late MockFactureRepository mockRepo;
    late FactureViewModel viewModel;

    setUpAll(() {
      registerFallbackValue(FakeFacture());
      registerFallbackValue(FakePaiement());
    });

    setUp(() {
      mockRepo = MockFactureRepository();
      viewModel = FactureViewModel(repository: mockRepo);
    });

    test(
        'Les factures chargées avec factureSourceId devraient être accessibles pour résolution',
        () async {
      // Simule le chargement de factures incluant une source et un avoir
      final factureSource = Facture(
        id: 'source-id',
        userId: 'user-1',
        numeroFacture: 'FAC-2024-0042',
        objet: 'Facture originale',
        clientId: 'c1',
        dateEmission: DateTime(2024, 1, 1),
        dateEcheance: DateTime(2024, 2, 1),
        totalHt: Decimal.parse('5000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        statut: 'validee',
      );

      final avoir = Facture(
        id: 'avoir-id',
        userId: 'user-1',
        numeroFacture: 'AVR-2024-0001',
        objet: 'Avoir sur FAC-2024-0042',
        clientId: 'c1',
        dateEmission: DateTime(2024, 3, 1),
        dateEcheance: DateTime(2024, 4, 1),
        totalHt: Decimal.parse('500'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        type: 'avoir',
        factureSourceId: 'source-id',
        motifAvoir: 'Erreur quantité',
      );

      when(() => mockRepo.getFactures(archives: false))
          .thenAnswer((_) async => [factureSource, avoir]);

      // ACT
      await viewModel.fetchFactures();

      // ASSERT — On peut résoudre le numéro de la facture source
      final resolvedNumero = viewModel.factures
          .firstWhere((f) => f.id == avoir.factureSourceId)
          .numeroFacture;

      expect(resolvedNumero, 'FAC-2024-0042');
      expect(avoir.motifAvoir, 'Erreur quantité');
    });
  });
}
