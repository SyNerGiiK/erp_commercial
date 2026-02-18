import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';

import 'package:erp_commercial/viewmodels/corbeille_viewmodel.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/client_model.dart';
import 'package:erp_commercial/models/depense_model.dart';
import '../mocks/repository_mocks.dart';

void main() {
  late MockFactureRepository mockFactureRepo;
  late MockDevisRepository mockDevisRepo;
  late MockClientRepository mockClientRepo;
  late MockDepenseRepository mockDepenseRepo;
  late CorbeilleViewModel viewModel;

  final testFacture = Facture(
    id: 'f1',
    userId: 'u1',
    numeroFacture: 'FAC-2026-001',
    objet: 'Facture test',
    clientId: 'c1',
    dateEmission: DateTime(2026, 1, 15),
    dateEcheance: DateTime(2026, 2, 15),
    statut: 'brouillon',
    totalHt: Decimal.parse('1000'),
    totalTva: Decimal.parse('200'),
    totalTtc: Decimal.parse('1200'),
    remiseTaux: Decimal.zero,
    acompteDejaRegle: Decimal.zero,
  );

  final testDevis = Devis(
    id: 'd1',
    userId: 'u1',
    numeroDevis: 'DEV-2026-001',
    objet: 'Devis test',
    clientId: 'c1',
    dateEmission: DateTime(2026, 1, 10),
    dateValidite: DateTime(2026, 2, 10),
    statut: 'brouillon',
    totalHt: Decimal.parse('500'),
    totalTva: Decimal.parse('100'),
    totalTtc: Decimal.parse('600'),
    remiseTaux: Decimal.zero,
    acompteMontant: Decimal.zero,
  );

  final testClient = Client(
    id: 'c1',
    nomComplet: 'Client Test',
    typeClient: 'professionnel',
    adresse: '1 rue Test',
    codePostal: '75000',
    ville: 'Paris',
    telephone: '0600000000',
    email: 'test@test.fr',
  );

  final testDepense = Depense(
    id: 'dep1',
    titre: 'Fournitures bureau',
    montant: Decimal.parse('150'),
    date: DateTime(2026, 1, 20),
    categorie: 'Fournitures',
  );

  setUp(() {
    mockFactureRepo = MockFactureRepository();
    mockDevisRepo = MockDevisRepository();
    mockClientRepo = MockClientRepository();
    mockDepenseRepo = MockDepenseRepository();

    viewModel = CorbeilleViewModel(
      factureRepository: mockFactureRepo,
      devisRepository: mockDevisRepo,
      clientRepository: mockClientRepo,
      depenseRepository: mockDepenseRepo,
    );
  });

  group('CorbeilleViewModel — Chargement', () {
    test('fetchAll charge tous les éléments supprimés', () async {
      when(() => mockFactureRepo.getDeletedFactures())
          .thenAnswer((_) async => [testFacture]);
      when(() => mockDevisRepo.getDeletedDevis())
          .thenAnswer((_) async => [testDevis]);
      when(() => mockClientRepo.getDeletedClients())
          .thenAnswer((_) async => [testClient]);
      when(() => mockDepenseRepo.getDeletedDepenses())
          .thenAnswer((_) async => [testDepense]);

      await viewModel.fetchAll();

      expect(viewModel.deletedFactures.length, 1);
      expect(viewModel.deletedDevis.length, 1);
      expect(viewModel.deletedClients.length, 1);
      expect(viewModel.deletedDepenses.length, 1);
      expect(viewModel.totalItems, 4);
      expect(viewModel.isEmpty, false);
    });

    test('corbeille vide correctement détectée', () async {
      when(() => mockFactureRepo.getDeletedFactures())
          .thenAnswer((_) async => []);
      when(() => mockDevisRepo.getDeletedDevis()).thenAnswer((_) async => []);
      when(() => mockClientRepo.getDeletedClients())
          .thenAnswer((_) async => []);
      when(() => mockDepenseRepo.getDeletedDepenses())
          .thenAnswer((_) async => []);

      await viewModel.fetchAll();

      expect(viewModel.totalItems, 0);
      expect(viewModel.isEmpty, true);
    });
  });

  group('CorbeilleViewModel — Restauration', () {
    setUp(() {
      when(() => mockFactureRepo.getDeletedFactures())
          .thenAnswer((_) async => [testFacture]);
      when(() => mockDevisRepo.getDeletedDevis())
          .thenAnswer((_) async => [testDevis]);
      when(() => mockClientRepo.getDeletedClients())
          .thenAnswer((_) async => [testClient]);
      when(() => mockDepenseRepo.getDeletedDepenses())
          .thenAnswer((_) async => [testDepense]);
    });

    test('restaurer une facture la retire de la corbeille', () async {
      await viewModel.fetchAll();
      when(() => mockFactureRepo.restoreFacture('f1')).thenAnswer((_) async {});

      final success = await viewModel.restoreFacture('f1');

      expect(success, true);
      expect(viewModel.deletedFactures.length, 0);
      expect(viewModel.totalItems, 3);
      verify(() => mockFactureRepo.restoreFacture('f1')).called(1);
    });

    test('restaurer un devis le retire de la corbeille', () async {
      await viewModel.fetchAll();
      when(() => mockDevisRepo.restoreDevis('d1')).thenAnswer((_) async {});

      final success = await viewModel.restoreDevis('d1');

      expect(success, true);
      expect(viewModel.deletedDevis.length, 0);
      verify(() => mockDevisRepo.restoreDevis('d1')).called(1);
    });

    test('restaurer un client le retire de la corbeille', () async {
      await viewModel.fetchAll();
      when(() => mockClientRepo.restoreClient('c1')).thenAnswer((_) async {});

      final success = await viewModel.restoreClient('c1');

      expect(success, true);
      expect(viewModel.deletedClients.length, 0);
      verify(() => mockClientRepo.restoreClient('c1')).called(1);
    });

    test('restaurer une dépense la retire de la corbeille', () async {
      await viewModel.fetchAll();
      when(() => mockDepenseRepo.restoreDepense('dep1'))
          .thenAnswer((_) async {});

      final success = await viewModel.restoreDepense('dep1');

      expect(success, true);
      expect(viewModel.deletedDepenses.length, 0);
      verify(() => mockDepenseRepo.restoreDepense('dep1')).called(1);
    });
  });

  group('CorbeilleViewModel — Purge', () {
    setUp(() {
      when(() => mockFactureRepo.getDeletedFactures())
          .thenAnswer((_) async => [testFacture]);
      when(() => mockDevisRepo.getDeletedDevis())
          .thenAnswer((_) async => [testDevis]);
      when(() => mockClientRepo.getDeletedClients())
          .thenAnswer((_) async => [testClient]);
      when(() => mockDepenseRepo.getDeletedDepenses())
          .thenAnswer((_) async => [testDepense]);
    });

    test('purger une facture la supprime définitivement', () async {
      await viewModel.fetchAll();
      when(() => mockFactureRepo.purgeFacture('f1')).thenAnswer((_) async {});

      final success = await viewModel.purgeFacture('f1');

      expect(success, true);
      expect(viewModel.deletedFactures.length, 0);
      verify(() => mockFactureRepo.purgeFacture('f1')).called(1);
    });

    test('purger un devis le supprime définitivement', () async {
      await viewModel.fetchAll();
      when(() => mockDevisRepo.purgeDevis('d1')).thenAnswer((_) async {});

      final success = await viewModel.purgeDevis('d1');

      expect(success, true);
      expect(viewModel.deletedDevis.length, 0);
      verify(() => mockDevisRepo.purgeDevis('d1')).called(1);
    });

    test('purger un client le supprime définitivement', () async {
      await viewModel.fetchAll();
      when(() => mockClientRepo.purgeClient('c1')).thenAnswer((_) async {});

      final success = await viewModel.purgeClient('c1');

      expect(success, true);
      expect(viewModel.deletedClients.length, 0);
    });

    test('purger une dépense la supprime définitivement', () async {
      await viewModel.fetchAll();
      when(() => mockDepenseRepo.purgeDepense('dep1')).thenAnswer((_) async {});

      final success = await viewModel.purgeDepense('dep1');

      expect(success, true);
      expect(viewModel.deletedDepenses.length, 0);
    });

    test('vider la corbeille purge tous les éléments', () async {
      await viewModel.fetchAll();
      when(() => mockFactureRepo.purgeFacture('f1')).thenAnswer((_) async {});
      when(() => mockDevisRepo.purgeDevis('d1')).thenAnswer((_) async {});
      when(() => mockClientRepo.purgeClient('c1')).thenAnswer((_) async {});
      when(() => mockDepenseRepo.purgeDepense('dep1')).thenAnswer((_) async {});

      final success = await viewModel.purgeAll();

      expect(success, true);
      expect(viewModel.isEmpty, true);
      expect(viewModel.totalItems, 0);
    });
  });
}
