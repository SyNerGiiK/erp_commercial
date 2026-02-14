import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/article_model.dart';
import '../config/supabase_config.dart';

abstract class IArticleRepository {
  Future<List<Article>> getArticles();
  Future<void> createArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> deleteArticle(String id);
}

class ArticleRepository implements IArticleRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Article>> getArticles() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('articles')
          .select()
          .eq('user_id', userId)
          .order('designation', ascending: true);

      return (response as List).map((e) => Article.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getArticles');
    }
  }

  @override
  Future<void> createArticle(Article article) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = article.toMap();
      data['user_id'] = userId;
      data.remove('id');

      await _client.from('articles').insert(data);
    } catch (e) {
      throw _handleError(e, 'createArticle');
    }
  }

  @override
  Future<void> updateArticle(Article article) async {
    if (article.id == null) return;
    try {
      final data = article.toMap();
      data.remove('user_id');

      await _client.from('articles').update(data).eq('id', article.id!);
    } catch (e) {
      throw _handleError(e, 'updateArticle');
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      await _client.from('articles').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteArticle');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 ArticleRepo Error ($method)", error: error);
    return Exception("Erreur Articles ($method): $error");
  }
}
