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

  group('Workflow Articles - Catalogue Produits', () {
    test('Scénario 1: Créer → Lister → Modifier → Supprimer un article',
        () async {
      // === ÉTAPE 1: CRÉATION ===
      final nouvelArticle = Article(
        userId: 'user-1',
        designation: 'Planche de bois 2x4',
        prixUnitaire: Decimal.parse('12.50'),
        prixAchat: Decimal.parse('8.00'),
        typeActivite: 'materiel',
        unite: 'm',
        tauxTva: Decimal.parse('20'),
      );

      final articleCree = Article(
        id: 'art-1',
        userId: 'user-1',
        designation: 'Planche de bois 2x4',
        prixUnitaire: Decimal.parse('12.50'),
        prixAchat: Decimal.parse('8.00'),
        typeActivite: 'materiel',
        unite: 'm',
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.createArticle(any())).thenAnswer((_) async {});
      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [articleCree]);

      // ACT: Créer l'article
      final success = await viewModel.addArticle(nouvelArticle);

      // ASSERT: Création réussie
      expect(success, true);
      verify(() => mockRepository.createArticle(any())).called(1);

      // === ÉTAPE 2: LISTE ===
      expect(viewModel.articles.length, 1);
      expect(viewModel.articles[0].designation, 'Planche de bois 2x4');
      expect(viewModel.articles[0].prixUnitaire, Decimal.parse('12.50'));
      expect(viewModel.articles[0].prixAchat, Decimal.parse('8.00'));
      expect(viewModel.articles[0].unite, 'm');

      // === ÉTAPE 3: MODIFICATION (Augmentation de prix) ===
      final articleModifie = articleCree.copyWith(
        prixUnitaire: Decimal.parse('15.00'), // +20%
        prixAchat: Decimal.parse('10.00'),
      );

      when(() => mockRepository.updateArticle(any())).thenAnswer((_) async {});
      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [articleModifie]);

      // ACT: Modifier l'article
      await viewModel.updateArticle(articleModifie);

      // ASSERT: Prix mis à jour
      expect(viewModel.articles.length, 1);
      expect(viewModel.articles[0].prixUnitaire, Decimal.parse('15.00'));
      verify(() => mockRepository.updateArticle(any())).called(1);

      // === ÉTAPE 4: SUPPRESSION ===
      when(() => mockRepository.deleteArticle('art-1'))
          .thenAnswer((_) async {});
      when(() => mockRepository.getArticles()).thenAnswer((_) async => []);

      // ACT: Supprimer l'article
      await viewModel.deleteArticle('art-1');

      // ASSERT: Article supprimé
      expect(viewModel.articles, isEmpty);
      verify(() => mockRepository.deleteArticle('art-1')).called(1);
    });

    test('Scénario 2: Gestion d\'un catalogue avec plusieurs types d\'articles',
        () async {
      // ARRANGE: Catalogue varié
      final articles = <Article>[
        Article(
          id: 'a1',
          userId: 'user-1',
          designation: 'Pose de parquet',
          prixUnitaire: Decimal.parse('45.00'),
          prixAchat: Decimal.zero,
          typeActivite: 'service',
          unite: 'm²',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'a2',
          userId: 'user-1',
          designation: 'Peinture blanche 10L',
          prixUnitaire: Decimal.parse('89.90'),
          prixAchat: Decimal.parse('45.00'),
          typeActivite: 'materiel',
          unite: 'u',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'a3',
          userId: 'user-1',
          designation: 'Consultation technique',
          prixUnitaire: Decimal.parse('120.00'),
          prixAchat: Decimal.zero,
          typeActivite: 'service',
          unite: 'h',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'a4',
          userId: 'user-1',
          designation: 'Vis à bois 4x40mm boîte 500',
          prixUnitaire: Decimal.parse('12.50'),
          prixAchat: Decimal.parse('6.00'),
          typeActivite: 'materiel',
          unite: 'u',
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => articles);

      // ACT: Charger le catalogue
      await viewModel.fetchArticles();

      // ASSERT: Tous les articles chargés
      expect(viewModel.articles.length, 4);

      // Vérifier les types d'activité
      final services =
          viewModel.articles.where((a) => a.typeActivite == 'service').toList();
      final materiels = viewModel.articles
          .where((a) => a.typeActivite == 'materiel')
          .toList();

      expect(services.length, 2);
      expect(materiels.length, 2);

      // Vérifier les marges (prixUnitaire - prixAchat)
      final peinture = articles[1];
      final marge = peinture.prixUnitaire - peinture.prixAchat;
      expect(marge, Decimal.parse('44.90')); // 89.90 - 45.00
    });

    test('Scénario 3: Calculs de marge et rentabilité', () async {
      // ARRANGE: Article avec marge
      final article = Article(
        id: 'a1',
        designation: 'Robinet mitigeur',
        prixUnitaire: Decimal.parse('89.00'), // Prix de vente
        prixAchat: Decimal.parse('45.00'), // Prix d\'achat
        typeActivite: 'materiel',
        unite: 'u',
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [article]);
      await viewModel.fetchArticles();

      // CALCULS
      final prixVente = viewModel.articles[0].prixUnitaire;
      final prixAchat = viewModel.articles[0].prixAchat;
      final marge = prixVente - prixAchat;

      // ASSERT
      expect(marge, Decimal.parse('44.00')); // 89 - 45
      // Marge de 44€ sur 89€ = environ 49% de marge
      expect(viewModel.articles[0].prixUnitaire, Decimal.parse('89.00'));
      expect(viewModel.articles[0].prixAchat, Decimal.parse('45.00'));
    });

    test('Scénario 4: Gestion d\'erreurs lors de la création', () async {
      // ARRANGE
      final articleInvalide = Article(
        userId: 'user-1',
        designation: '',
        prixUnitaire: Decimal.parse('-10.00'),
        prixAchat: Decimal.zero,
        typeActivite: 'service',
        unite: 'u',
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.createArticle(any())).thenThrow(
          Exception('Designation requise et prix doit être positif'));

      // ACT
      final success = await viewModel.addArticle(articleInvalide);

      // ASSERT: Création échouée
      expect(success, false);
      expect(viewModel.articles, isEmpty);
    });

    test('Scénario 5: Modification de prix en masse', () async {
      // ARRANGE
      final articlesInitiaux = <Article>[
        Article(
          id: 'a1',
          designation: 'Service A',
          prixUnitaire: Decimal.parse('100.00'),
          prixAchat: Decimal.zero,
          typeActivite: 'service',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'a2',
          designation: 'Service B',
          prixUnitaire: Decimal.parse('150.00'),
          prixAchat: Decimal.zero,
          typeActivite: 'service',
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => articlesInitiaux);
      await viewModel.fetchArticles();

      // Augmentation de 10%
      final tauxAugmentation = Decimal.parse('1.10');

      final articlesAugmentes = articlesInitiaux.map((a) {
        return a.copyWith(
          prixUnitaire: a.prixUnitaire * tauxAugmentation,
        );
      }).toList();

      for (final article in articlesAugmentes) {
        when(() => mockRepository.updateArticle(article))
            .thenAnswer((_) async {});
      }

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => articlesAugmentes);

      for (final article in articlesAugmentes) {
        await viewModel.updateArticle(article);
      }

      // ASSERT
      expect(viewModel.articles.length, 2);
      expect(viewModel.articles[0].prixUnitaire, Decimal.parse('110.00'));
      expect(viewModel.articles[1].prixUnitaire, Decimal.parse('165.00'));
    });

    test('Scénario 6: Suppression d\'un article utilisé', () async {
      // ARRANGE
      final article = Article(
        id: 'art-1',
        designation: 'Article populaire',
        prixUnitaire: Decimal.parse('50.00'),
        prixAchat: Decimal.parse('25.00'),
        typeActivite: 'service',
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [article]);
      await viewModel.fetchArticles();

      when(() => mockRepository.deleteArticle('art-1')).thenThrow(
          Exception('Article utilisé dans 5 devis, suppression impossible'));

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [article]);

      // ACT
      await viewModel.deleteArticle('art-1');

      // ASSERT: Article toujours présent
      expect(viewModel.articles.length, 1);
      expect(viewModel.articles[0].id, 'art-1');
    });
  });

  group('Workflow Articles - Calculs avancés', () {
    test('Calcul de marge minimale requise', () async {
      // ARRANGE: Articles avec différentes marges
      final articles = <Article>[
        Article(
          id: 'a1',
          designation: 'Article marge faible',
          prixUnitaire: Decimal.parse('110.00'),
          prixAchat: Decimal.parse('100.00'), // Marge 10%
          typeActivite: 'materiel',
          tauxTva: Decimal.parse('20'),
        ),
        Article(
          id: 'a2',
          designation: 'Article marge correcte',
          prixUnitaire: Decimal.parse('150.00'),
          prixAchat: Decimal.parse('100.00'), // Marge 50%
          typeActivite: 'materiel',
          tauxTva: Decimal.parse('20'),
        ),
      ];

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => articles);
      await viewModel.fetchArticles();

      final articlesRentables = viewModel.articles.where((a) {
        final marge = a.prixUnitaire - a.prixAchat;
        // Vérifier que la marge absolue est d'au moins 30€
        return marge >= Decimal.parse('30.00');
      }).toList();

      // ASSERT: Article avec marge de 50€ passe (150-100=50)
      expect(articlesRentables.length, 1);
      expect(articlesRentables[0].designation, 'Article marge correcte');
    });

    test('Application de TVA sur différents taux', () async {
      // ARRANGE: Articles avec TVA variée
      final articles = <Article>[
        Article(
          id: 'a1',
          designation: 'Produit alimentaire',
          prixUnitaire: Decimal.parse('100.00'),
          prixAchat: Decimal.parse('60.00'),
          typeActivite: 'materiel',
          tauxTva: Decimal.parse('5.5'), // Taux réduit
        ),
        Article(
          id: 'a2',
          designation: 'Produit standard',
          prixUnitaire: Decimal.parse('100.00'),
          prixAchat: Decimal.parse('60.00'),
          typeActivite: 'materiel',
          tauxTva: Decimal.parse('20'), // Taux normal
        ),
      ];

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => articles);
      await viewModel.fetchArticles();

      // Calcul TTC pour chaque article
      // HT = 100, TVA 5.5% → TTC = 105.5
      // HT = 100, TVA 20% → TTC = 120

      // ASSERT
      expect(viewModel.articles.length, 2);
      expect(viewModel.articles[0].tauxTva, Decimal.parse('5.5'));
      expect(viewModel.articles[1].tauxTva, Decimal.parse('20'));
    });
  });

  group('Workflow Articles - Edge Cases', () {
    test('Catalogue vide au démarrage', () async {
      when(() => mockRepository.getArticles()).thenAnswer((_) async => []);

      await viewModel.fetchArticles();

      expect(viewModel.articles, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('Gestion d\'erreur réseau', () async {
      when(() => mockRepository.getArticles()).thenThrow(Exception('Timeout'));

      await viewModel.fetchArticles();

      expect(viewModel.articles, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('Prix avec précision décimale', () async {
      final article = Article(
        id: 'a1',
        designation: 'Article précis',
        prixUnitaire: Decimal.parse('12.4567'),
        prixAchat: Decimal.parse('8.1234'),
        typeActivite: 'materiel',
        tauxTva: Decimal.parse('20'),
      );

      when(() => mockRepository.getArticles())
          .thenAnswer((_) async => [article]);
      await viewModel.fetchArticles();

      expect(viewModel.articles[0].prixUnitaire, Decimal.parse('12.4567'));
      expect(viewModel.articles[0].prixAchat, Decimal.parse('8.1234'));
    });
  });
}
