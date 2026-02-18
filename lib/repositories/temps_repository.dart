import '../models/temps_activite_model.dart';
import '../core/base_repository.dart';

abstract class ITempsRepository {
  Future<List<TempsActivite>> getAll();
  Future<List<TempsActivite>> getByClient(String clientId);
  Future<List<TempsActivite>> getNonFactures();
  Future<List<TempsActivite>> getByPeriode(DateTime debut, DateTime fin);
  Future<void> create(TempsActivite temps);
  Future<void> update(TempsActivite temps);
  Future<void> delete(String id);
  Future<void> marquerFacture(List<String> ids, String factureId);

  /// Statistiques du temps
  Future<int> getTotalMinutesMois(int annee, int mois);
}

class TempsRepository extends BaseRepository implements ITempsRepository {
  @override
  Future<List<TempsActivite>> getAll() async {
    try {
      final response = await client
          .from('temps_activites')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('date_activite', ascending: false);

      return (response as List).map((e) => TempsActivite.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getAll');
    }
  }

  @override
  Future<List<TempsActivite>> getByClient(String clientId) async {
    try {
      final response = await client
          .from('temps_activites')
          .select()
          .eq('user_id', userId)
          .eq('client_id', clientId)
          .isFilter('deleted_at', null)
          .order('date_activite', ascending: false);

      return (response as List).map((e) => TempsActivite.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getByClient');
    }
  }

  @override
  Future<List<TempsActivite>> getNonFactures() async {
    try {
      final response = await client
          .from('temps_activites')
          .select()
          .eq('user_id', userId)
          .eq('est_facturable', true)
          .eq('est_facture', false)
          .isFilter('deleted_at', null)
          .order('date_activite', ascending: false);

      return (response as List).map((e) => TempsActivite.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getNonFactures');
    }
  }

  @override
  Future<List<TempsActivite>> getByPeriode(DateTime debut, DateTime fin) async {
    try {
      final response = await client
          .from('temps_activites')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .gte('date_activite', debut.toIso8601String().substring(0, 10))
          .lte('date_activite', fin.toIso8601String().substring(0, 10))
          .order('date_activite', ascending: false);

      return (response as List).map((e) => TempsActivite.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getByPeriode');
    }
  }

  @override
  Future<void> create(TempsActivite temps) async {
    try {
      final data = prepareForInsert(temps.toMap());
      await client.from('temps_activites').insert(data);
    } catch (e) {
      throw handleError(e, 'create');
    }
  }

  @override
  Future<void> update(TempsActivite temps) async {
    if (temps.id == null) return;
    try {
      final data = prepareForUpdate(temps.toMap());
      await client.from('temps_activites').update(data).eq('id', temps.id!);
    } catch (e) {
      throw handleError(e, 'update');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from('temps_activites').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'delete');
    }
  }

  @override
  Future<void> marquerFacture(List<String> ids, String factureId) async {
    try {
      for (final id in ids) {
        await client.from('temps_activites').update({
          'est_facture': true,
          'facture_id': factureId,
        }).eq('id', id);
      }
    } catch (e) {
      throw handleError(e, 'marquerFacture');
    }
  }

  @override
  Future<int> getTotalMinutesMois(int annee, int mois) async {
    try {
      final debut = DateTime(annee, mois, 1);
      final fin = DateTime(annee, mois + 1, 0); // dernier jour

      final response = await client
          .from('temps_activites')
          .select('duree_minutes')
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .gte('date_activite', debut.toIso8601String().substring(0, 10))
          .lte('date_activite', fin.toIso8601String().substring(0, 10));

      int total = 0;
      for (final row in response as List) {
        total += (row['duree_minutes'] as int? ?? 0);
      }
      return total;
    } catch (e) {
      throw handleError(e, 'getTotalMinutesMois');
    }
  }
}
