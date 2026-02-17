import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/article_viewmodel.dart';
import 'package:erp_commercial/models/article_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeArticle extends Fake implements Article {}

void main() {
  late MockArticleRepository mockRepository;
  late ArticleViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeArticle());
  });

  setUp(() {
    mockRepository = MockArticleRepository();
    viewModel = ArticleViewModel(repository: mockRepository);
  });

  group('fetchArticles', () {
    test('devrait récupérer et exposer la liste des articles', () async {
      // ARRANGE
      final testArticles = <Article>[
        Article(
          id: 'art-1',
          userId: 'user-1',
          designation: 'Prestation Web',
          prixUnitaire: Decimal.parse('500'),
          prixAchat: Decimal.parse('0'),
          unite: 'jour',
          typeActivite: 'service',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'art-2',
          userId: 'user-1',
          designation: 'Produit Logiciel',
          prixUnitaire: Decimal.parse('1000'),
          prixAchat: Decimal.parse('200'),
          unite: 'u',
          typeActivite: 'vente',
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => testArticles);

      // ACT
      await viewModel.fetchArticles();

      // ASSERT
      expect(viewModel.articles.length, 2);
      expect(viewModel.articles[0].designation, 'Prestation Web');
      expect(viewModel.articles[1].designation, 'Produit Logiciel');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getArticles()).called(1);
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      when(() => mockRepository.getArticles())
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.fetchArticles();

      // ASSERT
      expect(viewModel.articles, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('addArticle', () {
    test('devrait ajouter un article et rafraîchir la liste', () async {
      // ARRANGE
      final newArticle = Article(
        userId: 'user-1',
        designation: 'Nouvelle Prestation',
        prixUnitaire: Decimal.parse('750'),
        prixAchat: Decimal.parse('0'),
        unite: 'jour',
        typeActivite: 'service',
        tauxTva: Decimal.parse('20'),
      );

      final updatedArticles = <Article>[
        Article(
          id: 'art-3',
          userId: 'user-1',
          designation: 'Nouvelle Prestation',
          prixUnitaire: Decimal.parse('750'),
          prixAchat: Decimal.parse('0'),
          unite: 'jour',
          typeActivite: 'service',
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.createArticle(any())).thenAnswer((_) async {});
      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => updatedArticles);

      // ACT
      final success = await viewModel.addArticle(newArticle);

      // ASSERT
      expect(success, true);
      expect(viewModel.articles.length, 1);
      verify(() => mockRepository.createArticle(newArticle)).called(1);
      verify(() => mockRepository.getArticles()).called(1);
    });

    test('devrait retourner false en cas d\'erreur', () async {
      // ARRANGE
      final newArticle = Article(
        userId: 'user-1',
        designation: 'Error Article',
        prixUnitaire: Decimal.parse('100'),
        prixAchat: Decimal.parse('0'),
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.createArticle(any()))
          .thenThrow(Exception('Creation failed'));

      // ACT
      final success = await viewModel.addArticle(newArticle);

      // ASSERT
      expect(success, false);
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.createArticle(newArticle)).called(1);
      verifyNever(() => mockRepository.getArticles());
    });
  });

  group('updateArticle', () {
    test('devrait mettre à jour un article et rafraîchir', () async {
      // ARRANGE
      final updatedArticle = Article(
        id: 'art-1',
        userId: 'user-1',
        designation: 'Prestation Mise à jour',
        prixUnitaire: Decimal.parse('600'),
        prixAchat: Decimal.parse('0'),
        unite: 'jour',
        typeActivite: 'service',
        tauxTva: Decimal.parse('20'),
      );

      final resultArticles = <Article>[updatedArticle];

      when(() => mockRepository.updateArticle(any())).thenAnswer((_) async {});
      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => resultArticles);

      // ACT
      final success = await viewModel.updateArticle(updatedArticle);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.updateArticle(updatedArticle)).called(1);
      verify(() => mockRepository.getArticles()).called(1);
    });
  });

  group('deleteArticle', () {
    test('devrait supprimer un article et rafraîchir', () async {
      // ARRANGE
      const articleIdToDelete = 'art-1';
      final remainingArticles = <Article>[
        Article(
          id: 'art-2',
          userId: 'user-1',
          designation: 'Remaining Article',
          prixUnitaire: Decimal.parse('500'),
          prixAchat: Decimal.parse('100'),
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.deleteArticle(articleIdToDelete))
          .thenAnswer((_) async {});
      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => remainingArticles);

      // ACT
      await viewModel.deleteArticle(articleIdToDelete);

      // ASSERT
      expect(viewModel.articles.length, 1);
      verify(() => mockRepository.deleteArticle(articleIdToDelete)).called(1);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après fetch réussi', () async {
      // ARRANGE
      when(() => mockRepository.getArticles()).thenAnswer((_) async => []);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchArticles();
      expect(viewModel.isLoading, false);
    });
  });
}
