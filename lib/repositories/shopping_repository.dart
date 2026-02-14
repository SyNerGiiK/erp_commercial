import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/shopping_model.dart';
import '../config/supabase_config.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingItem>> getItems();
  Future<void> addItem(ShoppingItem item);
  Future<void> updateItem(ShoppingItem item);
  Future<void> deleteItem(String id);
}

class ShoppingRepository implements IShoppingRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<ShoppingItem>> getItems() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('courses')
          .select()
          .eq('user_id', userId)
          .order('est_achete', ascending: true);

      return (response as List).map((e) => ShoppingItem.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getItems');
    }
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = item.toMap();
      data['user_id'] = userId;
      data.remove('id');

      await _client.from('courses').insert(data);
    } catch (e) {
      throw _handleError(e, 'addItem');
    }
  }

  @override
  Future<void> updateItem(ShoppingItem item) async {
    if (item.id == null) return;
    try {
      final data = item.toMap();
      data.remove('user_id'); // RLS

      await _client.from('courses').update(data).eq('id', item.id!);
    } catch (e) {
      throw _handleError(e, 'updateItem');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _client.from('courses').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteItem');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 ShoppingRepo Error ($method)", error: error);
    return Exception("Erreur Courses ($method): $error");
  }
}
