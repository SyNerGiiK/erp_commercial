import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../repositories/article_repository.dart';

class ArticleViewModel extends ChangeNotifier {
  final IArticleRepository _repository;

  ArticleViewModel({IArticleRepository? repository})
      : _repository = repository ?? ArticleRepository();

  List<Article> _articles = [];
  bool _isLoading = false;
  int _loadingDepth = 0; // Compteur pour gérer les appels imbriqués

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> fetchArticles() async {
    await _executeOperation(() async {
      _articles = await _repository.getArticles();
    }, onError: () {
      // En cas d'erreur, on garde une liste vide pour éviter les crashs UI
      _articles = [];
    });
  }

  Future<bool> addArticle(Article article) async {
    return await _executeOperation(() async {
      await _repository.createArticle(article);
      await fetchArticles();
    });
  }

  Future<bool> updateArticle(Article article) async {
    return await _executeOperation(() async {
      await _repository.updateArticle(article);
      await fetchArticles();
    });
  }

  Future<void> deleteArticle(String id) async {
    await _executeOperation(() async {
      await _repository.deleteArticle(id);
      await fetchArticles();
    });
  }

  Future<bool> _executeOperation(
    Future<void> Function() operation, {
    Function()? onError,
  }) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("🔴 ArticleViewModel Error: $e");
      }
      if (onError != null) {
        onError();
      }
      return false;
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
