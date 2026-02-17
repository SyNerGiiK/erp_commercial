import 'dart:developer' as developer;
import '../models/shopping_model.dart';
import '../core/base_repository.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingItem>> getItems();
  Future<void> addItem(ShoppingItem item);
  Future<void> updateItem(ShoppingItem item);
  Future<void> deleteItem(String id);
}

class ShoppingRepository extends BaseRepository implements IShoppingRepository {
  @override
  Future<List<ShoppingItem>> getItems() async {
    try {
      final response = await client
          .from('courses')
          .select()
          .eq('user_id', userId)
          .order('est_achete', ascending: true);

      return (response as List).map((e) => ShoppingItem.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getItems');
    }
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    try {
      final data = prepareForInsert(item.toMap());
      await client.from('courses').insert(data);
    } catch (e) {
      throw handleError(e, 'addItem');
    }
  }

  @override
  Future<void> updateItem(ShoppingItem item) async {
    if (item.id == null) return;
    try {
      final data = prepareForUpdate(item.toMap());
      await client.from('courses').update(data).eq('id', item.id!);
    } catch (e) {
      throw handleError(e, 'updateItem');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await client.from('courses').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteItem');
    }
  }
}
