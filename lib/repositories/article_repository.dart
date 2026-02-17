import 'dart:developer' as developer;
import '../models/article_model.dart';
import '../core/base_repository.dart';

abstract class IArticleRepository {
  Future<List<Article>> getArticles();
  Future<void> createArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> deleteArticle(String id);
}

class ArticleRepository extends BaseRepository implements IArticleRepository {
  @override
  Future<List<Article>> getArticles() async {
    try {
      final response = await client
          .from('articles')
          .select()
          .eq('user_id', userId)
          .order('designation', ascending: true);

      return (response as List).map((e) => Article.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getArticles');
    }
  }

  @override
  Future<void> createArticle(Article article) async {
    try {
      final data = prepareForInsert(article.toMap());
      await client.from('articles').insert(data);
    } catch (e) {
      throw handleError(e, 'createArticle');
    }
  }

  @override
  Future<void> updateArticle(Article article) async {
    if (article.id == null) return;
    try {
      final data = prepareForUpdate(article.toMap());
      await client.from('articles').update(data).eq('id', article.id!);
    } catch (e) {
      throw handleError(e, 'updateArticle');
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      await client.from('articles').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteArticle');
    }
  }
}
