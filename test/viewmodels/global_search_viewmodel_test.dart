import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/global_search_viewmodel.dart';
import 'package:erp_commercial/models/client_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/repositories/global_search_repository.dart';
import '../mocks/repository_mocks.dart';

void main() {
  late MockGlobalSearchRepository mockRepository;
  late GlobalSearchViewModel viewModel;

  setUp(() {
    mockRepository = MockGlobalSearchRepository();
    viewModel = GlobalSearchViewModel(repository: mockRepository);
  });

  group('search', () {
    test('devrait vider les résultats si query trop courte (< 2 chars)',
        () async {
      //ARRANGE - Prepopulate with results
      when(() => mockRepository.searchAll(any())).thenAnswer(
        (_) async => GlobalSearchResults(
          clients: [
            Client(
              userId: 'user-1',
              nomComplet: 'Test',
              adresse: '',
              codePostal: '',
              ville: '',
              telephone: '',
              email: '',
            ),
          ],
        ),
      );
      await viewModel.search('abc'); // Populate first

      // ACT - Search with 1 char
      await viewModel.search('a');

      // ASSERT
      expect(viewModel.clientsResults, isEmpty);
      expect(viewModel.facturesResults, isEmpty);
      expect(viewModel.devisResults, isEmpty);
      expect(viewModel.isLoading, false);
      // Verify repository was NOT called for short query
      verify(() => mockRepository.searchAll('abc')).called(1);
      verifyNever(() => mockRepository.searchAll('a'));
    });

    test('devrait effectuer une recherche et exposer les résultats', () async {
      // ARRANGE
      final testClients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont',
          adresse: '',
          codePostal: '',
          ville: '',
          telephone: '',
          email: '',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Durant',
          adresse: '',
          codePostal: '',
          ville: '',
          telephone: '',
          email: '',
        ),
      ];

      final testFactures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Prestation Dupont',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateEcheance: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final testDevis = <Devis>[
        Devis(
          id: 'd1',
          userId: 'user-1',
          numeroDevis: 'DEV-2024-001',
          objet: 'Projet Dupont',
          clientId: 'c1',
          dateEmission: DateTime.now(),
          dateValidite: DateTime.now().add(const Duration(days: 30)),
          totalHt: Decimal.parse('5000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'envoye',
        ),
      ];

      when(() => mockRepository.searchAll(any())).thenAnswer(
        (_) async => GlobalSearchResults(
          clients: testClients,
          factures: testFactures,
          devis: testDevis,
        ),
      );

      // ACT
      await viewModel.search('Dupont');

      // ASSERT
      expect(viewModel.clientsResults.length, 2);
      expect(viewModel.facturesResults.length, 1);
      expect(viewModel.devisResults.length, 1);
      expect(viewModel.clientsResults[0].nomComplet, 'Dupont');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.searchAll('Dupont')).called(1);
    });

    test('devrait retourner des listes vides si aucun résultat', () async {
      // ARRANGE
      when(() => mockRepository.searchAll(any())).thenAnswer(
        (_) async => GlobalSearchResults(),
      );

      // ACT
      await viewModel.search('xyz');

      // ASSERT
      expect(viewModel.clientsResults, isEmpty);
      expect(viewModel.facturesResults, isEmpty);
      expect(viewModel.devisResults, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('devrait vider les résultats en cas d\'erreur', () async {
      // ARRANGE - Prepopulate
      when(() => mockRepository.searchAll(any())).thenAnswer(
        (_) async => GlobalSearchResults(
          clients: [
            Client(
              userId: 'user-1',
              nomComplet: 'Test',
              adresse: '',
              codePostal: '',
              ville: '',
              telephone: '',
              email: '',
            ),
          ],
        ),
      );
      await viewModel.search('test');

      // Setup error
      when(() => mockRepository.searchAll(any()))
          .thenThrow(Exception('Network error'));

      // ACT
      await viewModel.search('error');

      // ASSERT
      expect(viewModel.clientsResults, isEmpty);
      expect(viewModel.facturesResults, isEmpty);
      expect(viewModel.devisResults, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après recherche', () async {
      // ARRANGE
      when(() => mockRepository.searchAll(any())).thenAnswer(
        (_) async => GlobalSearchResults(),
      );

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.search('test');
      expect(viewModel.isLoading, false);
    });
  });
}
