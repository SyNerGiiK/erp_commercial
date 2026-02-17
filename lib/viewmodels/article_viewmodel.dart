import '../models/article_model.dart';
import '../repositories/article_repository.dart';
import '../core/base_viewmodel.dart';

class ArticleViewModel extends BaseViewModel {
  final IArticleRepository _repository;

  ArticleViewModel({IArticleRepository? repository})
      : _repository = repository ?? ArticleRepository();

  List<Article> _articles = [];

  List<Article> get articles => _articles;

  Future<void> fetchArticles() async {
    await executeOperation(
      () async {
        _articles = await _repository.getArticles();
      },
      onError: () {
        // En cas d'erreur, on garde une liste vide pour éviter les crashs UI
        _articles = [];
      },
    );
  }

  Future<bool> addArticle(Article article) async {
    return await executeOperation(() async {
      await _repository.createArticle(article);
      await fetchArticles();
    });
  }

  Future<bool> updateArticle(Article article) async {
    return await executeOperation(() async {
      await _repository.updateArticle(article);
      await fetchArticles();
    });
  }

  Future<void> deleteArticle(String id) async {
    await executeOperation(() async {
      await _repository.deleteArticle(id);
      await fetchArticles();
    });
  }
}
