import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/models/client_model.dart';
import 'package:erp_commercial/viewmodels/client_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// Fake client pour mocktail
class FakeClient extends Fake implements Client {}

void main() {
  group('ClientViewModel', () {
    late MockClientRepository mockRepository;
    late ClientViewModel viewModel;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(FakeClient());
    });

    setUp(() {
      mockRepository = MockClientRepository();
      viewModel = ClientViewModel(repository: mockRepository);
    });

    group('fetchClients', () {
      test('devrait récupérer et exposer la liste des clients', () async {
        // ARRANGE
        final testClients = [
          Client(
            id: 'client-1',
            nomComplet: 'John Doe',
            adresse: '123 Rue Test',
            codePostal: '75001',
            ville: 'Paris',
            telephone: '0123456789',
            email: 'john@example.com',
          ),
          Client(
            id: 'client-2',
            nomComplet: 'Jane Smith',
            adresse: '456 Avenue Test',
            codePostal: '69001',
            ville: 'Lyon',
            telephone: '0987654321',
            email: 'jane@example.com',
          ),
        ];

        when(() => mockRepository.getClients())
            .thenAnswer((_) async => testClients);

        // ACT
        await viewModel.fetchClients();

        // ASSERT
        expect(viewModel.clients, testClients);
        expect(viewModel.clients.length, 2);
        expect(viewModel.clients[0].nomComplet, 'John Doe');
        expect(viewModel.clients[1].nomComplet, 'Jane Smith');
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.getClients()).called(1);
      });

      test('devrait gérer les erreurs sans crash', () async {
        // ARRANGE
        when(() => mockRepository.getClients())
            .thenThrow(Exception('Network error'));

        // ACT
        await viewModel.fetchClients();

        // ASSERT
        expect(viewModel.clients, isEmpty);
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.getClients()).called(1);
      });
    });

    group('addClient', () {
      test('devrait ajouter un client et rafraîchir la liste', () async {
        // ARRANGE
        final newClient = Client(
          nomComplet: 'New Client',
          adresse: 'New Address',
          codePostal: '12345',
          ville: 'New City',
          telephone: '0000000000',
          email: 'new@example.com',
        );

        final updatedClients = [
          Client(
            id: 'client-2',
            nomComplet: 'New Client',
            adresse: 'New Address',
            codePostal: '12345',
            ville: 'New City',
            telephone: '0000000000',
            email: 'new@example.com',
          ),
        ];

        when(() => mockRepository.createClient(any())).thenAnswer(
            (_) async => updatedClients[0]); // Return the created client
        when(() => mockRepository.getClients())
            .thenAnswer((_) async => updatedClients);

        // ACT
        final success = await viewModel.addClient(newClient);

        // ASSERT
        expect(success, true);
        expect(viewModel.clients.length, 1);
        expect(viewModel.clients.first.nomComplet, 'New Client');
        verify(() => mockRepository.createClient(newClient)).called(1);
        verify(() => mockRepository.getClients()).called(1);
      });

      test('devrait retourner false en cas d\'erreur', () async {
        // ARRANGE
        final newClient = Client(
          nomComplet: 'Error Client',
          adresse: 'Address',
          codePostal: '99999',
          ville: 'City',
          telephone: '0000000000',
          email: 'error@example.com',
        );

        when(() => mockRepository.createClient(any()))
            .thenThrow(Exception('Creation failed'));

        // ACT
        final success = await viewModel.addClient(newClient);

        // ASSERT
        expect(success, false);
        expect(viewModel.isLoading, false);
        verify(() => mockRepository.createClient(newClient)).called(1);
        verifyNever(() => mockRepository.getClients());
      });
    });

    group('updateClient', () {
      test('devrait mettre à jour un client et rafraîchir', () async {
        // ARRANGE
        final updatedClient = Client(
          id: 'client-1',
          nomComplet: 'Updated Name',
          adresse: 'Updated Address',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0123456789',
          email: 'updated@example.com',
        );

        final resultClients = [updatedClient];

        when(() => mockRepository.updateClient(any())).thenAnswer((_) async {});
        when(() => mockRepository.getClients())
            .thenAnswer((_) async => resultClients);

        // ACT
        final success = await viewModel.updateClient(updatedClient);

        // ASSERT
        expect(success, true);
        expect(viewModel.clients.first.nomComplet, 'Updated Name');
        verify(() => mockRepository.updateClient(updatedClient)).called(1);
        verify(() => mockRepository.getClients()).called(1);
      });
    });

    group('deleteClient', () {
      test('devrait supprimer un client et rafraîchir', () async {
        // ARRANGE
        const clientIdToDelete = 'client-1';
        final remainingClients = [
          Client(
            id: 'client-2',
            nomComplet: 'Remaining Client',
            adresse: 'Address',
            codePostal: '22222',
            ville: 'City',
            telephone: '2222222222',
            email: 'remaining@example.com',
          ),
        ];

        when(() => mockRepository.deleteClient(clientIdToDelete))
            .thenAnswer((_) async {});
        when(() => mockRepository.getClients())
            .thenAnswer((_) async => remainingClients);

        // ACT
        await viewModel.deleteClient(clientIdToDelete);

        // ASSERT
        expect(viewModel.clients.length, 1);
        expect(viewModel.clients.first.id, 'client-2');
        verify(() => mockRepository.deleteClient(clientIdToDelete)).called(1);
        verify(() => mockRepository.getClients()).called(1);
      });
    });

    group('isLoading state', () {
      test('devrait être false initialement et après un fetch réussi', () async {
        // ARRANGE
        when(() => mockRepository.getClients())
            .thenAnswer((_) async => <Client>[]);

        // ACT & ASSERT
        expect(viewModel.isLoading, false); // Initial
        await viewModel.fetchClients();
        expect(viewModel.isLoading, false); // Après le chargement réussi
      });
    });
  });
}
