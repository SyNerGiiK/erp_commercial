import '../models/rappel_model.dart';
import '../core/base_repository.dart';

abstract class IRappelRepository {
  Future<List<Rappel>> getAll();
  Future<List<Rappel>> getActifs();
  Future<List<Rappel>> getProchains(int joursAhead);
  Future<void> create(Rappel rappel);
  Future<void> update(Rappel rappel);
  Future<void> delete(String id);
  Future<void> completer(String id);
  Future<void> decompleter(String id);
}

class RappelRepository extends BaseRepository implements IRappelRepository {
  @override
  Future<List<Rappel>> getAll() async {
    try {
      final response = await client
          .from('rappels')
          .select()
          .eq('user_id', userId)
          .order('date_echeance', ascending: true);

      return (response as List).map((e) => Rappel.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getAll');
    }
  }

  @override
  Future<List<Rappel>> getActifs() async {
    try {
      final response = await client
          .from('rappels')
          .select()
          .eq('user_id', userId)
          .eq('est_complete', false)
          .order('date_echeance', ascending: true);

      return (response as List).map((e) => Rappel.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getActifs');
    }
  }

  @override
  Future<List<Rappel>> getProchains(int joursAhead) async {
    try {
      final limit =
          DateTime.now().add(Duration(days: joursAhead)).toIso8601String();

      final response = await client
          .from('rappels')
          .select()
          .eq('user_id', userId)
          .eq('est_complete', false)
          .lte('date_echeance', limit)
          .order('date_echeance', ascending: true);

      return (response as List).map((e) => Rappel.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getProchains');
    }
  }

  @override
  Future<void> create(Rappel rappel) async {
    try {
      final data = prepareForInsert(rappel.toMap());
      await client.from('rappels').insert(data);
    } catch (e) {
      throw handleError(e, 'create');
    }
  }

  @override
  Future<void> update(Rappel rappel) async {
    if (rappel.id == null) return;
    try {
      final data = prepareForUpdate(rappel.toMap());
      await client.from('rappels').update(data).eq('id', rappel.id!);
    } catch (e) {
      throw handleError(e, 'update');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from('rappels').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'delete');
    }
  }

  @override
  Future<void> completer(String id) async {
    try {
      await client.from('rappels').update({'est_complete': true}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'completer');
    }
  }

  @override
  Future<void> decompleter(String id) async {
    try {
      await client.from('rappels').update({'est_complete': false}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'decompleter');
    }
  }
}
