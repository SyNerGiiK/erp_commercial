import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../repositories/article_repository.dart';

class ArticleViewModel extends ChangeNotifier {
  final IArticleRepository _repository = ArticleRepository();

  List<Article> _articles = [];
  bool _isLoading = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> fetchArticles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _articles = await _repository.getArticles();
    } catch (e) {
      // En cas d'erreur, on garde une liste vide pour éviter les crashs UI
      _articles = [];
      debugPrint("Erreur ArticleVM: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      debugPrint("Erreur opération ArticleVM: $e");
      return false;
    }
  }
}
