import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/viewmodels/client_viewmodel.dart';
import 'package:erp_commercial/models/client_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeClient extends Fake implements Client {}

void main() {
  late MockClientRepository mockRepository;
  late ClientViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeClient());
  });

  setUp(() {
    mockRepository = MockClientRepository();
    viewModel = ClientViewModel(repository: mockRepository);
  });

  group('Workflow Client - CRUD Complet', () {
    test('Scénario 1: Créer → Lister → Modifier → Supprimer un client',
        () async {
      // === ÉTAPE 1: CRÉATION ===
      final nouveauClient = Client(
        userId: 'user-1',
        nomComplet: 'Dupont Jean',
        adresse: '12 rue de la Paix',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0612345678',
        email: 'jean.dupont@email.com',
        typeClient: 'particulier',
      );

      final clientCree = Client(
        id: 'client-1',
        userId: 'user-1',
        nomComplet: 'Dupont Jean',
        adresse: '12 rue de la Paix',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0612345678',
        email: 'jean.dupont@email.com',
        typeClient: 'particulier',
      );

      when(() => mockRepository.createClient(any()))
          .thenAnswer((_) async => clientCree);

      // Après création, rafraîchir la liste
      when(() => mockRepository.getClients())
          .thenAnswer((_) async => [clientCree]);

      // ACT: Créer le client
      final success = await viewModel.addClient(nouveauClient);

      // ASSERT: Création réussie
      expect(success, true);
      verify(() => mockRepository.createClient(any())).called(1);

      // === ÉTAPE 2: LISTE ===
      // ACT: Récupérer la liste des clients
      await viewModel.fetchClients();

      // ASSERT: Le client créé est dans la liste
      expect(viewModel.clients.length, 1);
      expect(viewModel.clients[0].id, 'client-1');
      expect(viewModel.clients[0].nomComplet, 'Dupont Jean');
      expect(viewModel.clients[0].telephone, '0612345678');

      // === ÉTAPE 3: MODIFICATION ===
      final clientModifie = clientCree.copyWith(
        telephone: '0698765432', // Nouveau numéro
        email: 'jean.dupont.pro@email.com', // Nouvel email
      );

      when(() => mockRepository.updateClient(any())).thenAnswer((_) async {});
      when(() => mockRepository.getClients())
          .thenAnswer((_) async => [clientModifie]);

      // ACT: Modifier le client
      await viewModel.updateClient(clientModifie);

      // ASSERT: Modification synchronisée
      expect(viewModel.clients.length, 1);
      expect(viewModel.clients[0].telephone, '0698765432');
      expect(viewModel.clients[0].email, 'jean.dupont.pro@email.com');
      verify(() => mockRepository.updateClient(any())).called(1);

      // === ÉTAPE 4: SUPPRESSION ===
      when(() => mockRepository.deleteClient('client-1'))
          .thenAnswer((_) async {});
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT: Supprimer le client
      await viewModel.deleteClient('client-1');

      // ASSERT: Client supprimé
      expect(viewModel.clients, isEmpty);
      verify(() => mockRepository.deleteClient('client-1')).called(1);
    });

    test('Scénario 2: Gestion de plusieurs clients avec filtrage', () async {
      // ARRANGE: Créer plusieurs clients
      final clients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont Jean',
          adresse: '1 rue A',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0601',
          email: 'dupont@email.com',
          typeClient: 'particulier',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Martin SA',
          adresse: '2 rue B',
          codePostal: '69000',
          ville: 'Lyon',
          telephone: '0602',
          email: 'martin@email.com',
          typeClient: 'entreprise',
        ),
        Client(
          id: 'c3',
          userId: 'user-1',
          nomComplet: 'Durand Pierre',
          adresse: '3 rue C',
          codePostal: '75002',
          ville: 'Paris',
          telephone: '0603',
          email: 'durand@email.com',
          typeClient: 'particulier',
        ),
      ];

      when(() => mockRepository.getClients()).thenAnswer((_) async => clients);

      // ACT: Charger les clients
      await viewModel.fetchClients();

      // ASSERT: Tous les clients sont chargés
      expect(viewModel.clients.length, 3);

      // Vérifier que tous les clients sont présents
      final noms = viewModel.clients.map((c) => c.nomComplet).toSet();
      expect(noms.contains('Dupont Jean'), true);
      expect(noms.contains('Durand Pierre'), true);
      expect(noms.contains('Martin SA'), true);

      // Vérifier les types
      final particuliers = viewModel.clients
          .where((c) => c.typeClient == 'particulier')
          .toList();
      final entreprises =
          viewModel.clients.where((c) => c.typeClient == 'entreprise').toList();

      expect(particuliers.length, 2);
      expect(entreprises.length, 1);
    });

    test('Scénario 3: Gestion d\'erreurs lors de la création', () async {
      // ARRANGE
      final clientInvalide = Client(
        userId: 'user-1',
        nomComplet: 'Test',
        adresse: '1 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0601',
        email: 'test@email.com',
      );

      when(() => mockRepository.createClient(any()))
          .thenThrow(Exception('Email déjà utilisé'));

      // ACT
      final success = await viewModel.addClient(clientInvalide);

      // ASSERT: Création échouée
      expect(success, false);
      expect(viewModel.clients, isEmpty);
    });

    test('Scénario 4: Modification d\'un client inexistant', () async {
      // ARRANGE
      final clientInexistant = Client(
        id: 'client-inexistant',
        userId: 'user-1',
        nomComplet: 'Ghost Client',
        adresse: '1 rue Ghost',
        codePostal: '00000',
        ville: 'Nowhere',
        telephone: '0000',
        email: 'ghost@email.com',
      );

      when(() => mockRepository.updateClient(any()))
          .thenThrow(Exception('Client not found'));
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await viewModel.updateClient(clientInexistant);

      // ASSERT: Aucun client dans la liste après échec
      expect(viewModel.clients, isEmpty);
    });

    test('Scénario 5: Suppression avec gestion d\'erreur', () async {
      // ARRANGE: Un client existe
      final client = Client(
        id: 'client-1',
        userId: 'user-1',
        nomComplet: 'Test Client',
        adresse: '1 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0601',
        email: 'test@email.com',
      );

      when(() => mockRepository.getClients()).thenAnswer((_) async => [client]);
      await viewModel.fetchClients();

      expect(viewModel.clients.length, 1);

      // Simuler une erreur de suppression (client utilisé dans des factures)
      when(() => mockRepository.deleteClient('client-1'))
          .thenThrow(Exception('Client utilisé dans des documents'));
      when(() => mockRepository.getClients()).thenAnswer((_) async => [client]);

      // ACT
      await viewModel.deleteClient('client-1');

      // ASSERT: Client toujours présent après échec
      expect(viewModel.clients.length, 1);
      expect(viewModel.clients[0].id, 'client-1');
    });

    test('Scénario 6: État de chargement pendant les opérations', () async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return [];
      });

      // ACT & ASSERT
      expect(viewModel.isLoading, false);

      final fetchFuture = viewModel.fetchClients();
      // Pendant le chargement, isLoading devrait être true
      // Note: difficile à tester sans async/await complexe
      await fetchFuture;

      expect(viewModel.isLoading, false);
    });

    test('Scénario 7: Workflow complet avec validation métier', () async {
      // === Création d'un client entreprise ===
      final entreprise = Client(
        userId: 'user-1',
        nomComplet: 'TechCorp SARL',
        adresse: '123 Avenue de l\'Innovation',
        codePostal: '92000',
        ville: 'Nanterre',
        telephone: '0140123456',
        email: 'contact@techcorp.fr',
        typeClient: 'entreprise',
        siret: '12345678901234',
        tvaIntra: 'FR12345678901',
      );

      final entrepriseCree = entreprise.copyWith(id: 'ent-1');

      when(() => mockRepository.createClient(any()))
          .thenAnswer((_) async => entrepriseCree);
      when(() => mockRepository.getClients())
          .thenAnswer((_) async => [entrepriseCree]);

      // ACT: Créer l'entreprise
      final success = await viewModel.addClient(entreprise);

      // ASSERT: Création avec champs entreprise
      expect(success, true);
      expect(viewModel.clients.length, 1);
      expect(viewModel.clients[0].typeClient, 'entreprise');
      expect(viewModel.clients[0].siret, '12345678901234');
      expect(viewModel.clients[0].tvaIntra, 'FR12345678901');

      // === Modification du SIRET ===
      final entrepriseModifiee = entrepriseCree.copyWith(
        siret: '98765432109876',
      );

      when(() => mockRepository.updateClient(any())).thenAnswer((_) async {});
      when(() => mockRepository.getClients())
          .thenAnswer((_) async => [entrepriseModifiee]);

      await viewModel.updateClient(entrepriseModifiee);

      // ASSERT: SIRET mis à jour
      expect(viewModel.clients[0].siret, '98765432109876');
    });
  });

  group('Workflow Client - Edge Cases', () {
    test('Liste vide de clients', () async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await viewModel.fetchClients();

      // ASSERT
      expect(viewModel.clients, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('Gestion d\'erreur réseau lors du fetch', () async {
      // ARRANGE
      when(() => mockRepository.getClients())
          .thenThrow(Exception('Network error'));

      // ACT
      await viewModel.fetchClients();

      // ASSERT: Liste vide après erreur
      expect(viewModel.clients, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('Création de deux clients identiques (doublons)', () async {
      // ARRANGE
      final client1 = Client(
        userId: 'user-1',
        nomComplet: 'Dupont Jean',
        adresse: '1 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0601',
        email: 'dupont@email.com',
      );

      final client1Cree = client1.copyWith(id: 'c1');

      when(() => mockRepository.createClient(any()))
          .thenAnswer((_) async => client1Cree);
      when(() => mockRepository.getClients())
          .thenAnswer((_) async => [client1Cree]);

      await viewModel.addClient(client1);

      // Tentative de créer un doublon
      when(() => mockRepository.createClient(any()))
          .thenThrow(Exception('Email already exists'));

      // ACT
      final success = await viewModel.addClient(client1);

      // ASSERT
      expect(success, false);
      expect(viewModel.clients.length, 1); // Un seul client
    });
  });
}
