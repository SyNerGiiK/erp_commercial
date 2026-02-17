import 'dart:developer' as developer;
import '../models/depense_model.dart';
import '../core/base_repository.dart';

abstract class IDepenseRepository {
  Future<List<Depense>> getDepenses();
  Future<void> createDepense(Depense depense);
  Future<void> updateDepense(Depense depense);
  Future<void> deleteDepense(String id);
}

class DepenseRepository extends BaseRepository implements IDepenseRepository {
  @override
  Future<List<Depense>> getDepenses() async {
    try {
      final response = await client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDepenses');
    }
  }

  @override
  Future<void> createDepense(Depense depense) async {
    try {
      final data = prepareForInsert(depense.toMap());
      await client.from('depenses').insert(data);
    } catch (e) {
      throw handleError(e, 'createDepense');
    }
  }

  @override
  Future<void> updateDepense(Depense depense) async {
    if (depense.id == null) return;
    try {
      final data = prepareForUpdate(depense.toMap());
      await client.from('depenses').update(data).eq('id', depense.id!);
    } catch (e) {
      throw handleError(e, 'updateDepense');
    }
  }

  @override
  Future<void> deleteDepense(String id) async {
    try {
      await client.from('depenses').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteDepense');
    }
  }
}
