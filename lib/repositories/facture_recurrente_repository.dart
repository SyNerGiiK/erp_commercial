import '../models/facture_recurrente_model.dart';
import '../core/base_repository.dart';

abstract class IFactureRecurrenteRepository {
  Future<List<FactureRecurrente>> getAll();
  Future<List<FactureRecurrente>> getActives();
  Future<List<FactureRecurrente>> getAGenerer();
  Future<FactureRecurrente> create(FactureRecurrente fr);
  Future<void> update(FactureRecurrente fr);
  Future<void> delete(String id);
  Future<void> toggleActive(String id, bool estActive);
  Future<void> incrementerGeneration(String id, DateTime date);
}

class FactureRecurrenteRepository extends BaseRepository
    implements IFactureRecurrenteRepository {
  @override
  Future<List<FactureRecurrente>> getAll() async {
    try {
      final response = await client
          .from('factures_recurrentes')
          .select('*, lignes_facture_recurrente(*)')
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('prochaine_emission', ascending: true);

      return (response as List)
          .map((e) => FactureRecurrente.fromMap(e))
          .toList();
    } catch (e) {
      throw handleError(e, 'getAll');
    }
  }

  @override
  Future<List<FactureRecurrente>> getActives() async {
    try {
      final response = await client
          .from('factures_recurrentes')
          .select('*, lignes_facture_recurrente(*)')
          .eq('user_id', userId)
          .eq('est_active', true)
          .isFilter('deleted_at', null)
          .order('prochaine_emission', ascending: true);

      return (response as List)
          .map((e) => FactureRecurrente.fromMap(e))
          .toList();
    } catch (e) {
      throw handleError(e, 'getActives');
    }
  }

  @override
  Future<List<FactureRecurrente>> getAGenerer() async {
    try {
      final now = DateTime.now().toIso8601String().substring(0, 10);
      final response = await client
          .from('factures_recurrentes')
          .select('*, lignes_facture_recurrente(*)')
          .eq('user_id', userId)
          .eq('est_active', true)
          .isFilter('deleted_at', null)
          .lte('prochaine_emission', now);

      return (response as List)
          .map((e) => FactureRecurrente.fromMap(e))
          .toList();
    } catch (e) {
      throw handleError(e, 'getAGenerer');
    }
  }

  @override
  Future<FactureRecurrente> create(FactureRecurrente fr) async {
    try {
      final data = prepareForInsert(
        fr.toMap(),
        nestedFields: ['lignes_facture_recurrente'],
      );

      final response = await client
          .from('factures_recurrentes')
          .insert(data)
          .select()
          .single();

      final id = response['id'];

      // Insérer les lignes
      if (fr.lignes.isNotEmpty) {
        final lignesData = fr.lignes.map((l) {
          final m = l.toMap();
          m['facture_recurrente_id'] = id;
          m.remove('id');
          return m;
        }).toList();
        await client.from('lignes_facture_recurrente').insert(lignesData);
      }

      // Re-fetch complet
      final full = await client
          .from('factures_recurrentes')
          .select('*, lignes_facture_recurrente(*)')
          .eq('id', id)
          .single();

      return FactureRecurrente.fromMap(full);
    } catch (e) {
      throw handleError(e, 'create');
    }
  }

  @override
  Future<void> update(FactureRecurrente fr) async {
    if (fr.id == null) return;
    try {
      final data = prepareForUpdate(
        fr.toMap(),
        nestedFields: ['lignes_facture_recurrente'],
      );
      await client.from('factures_recurrentes').update(data).eq('id', fr.id!);

      // Re-créer les lignes
      await client
          .from('lignes_facture_recurrente')
          .delete()
          .eq('facture_recurrente_id', fr.id!);

      if (fr.lignes.isNotEmpty) {
        final lignesData = fr.lignes.map((l) {
          final m = l.toMap();
          m['facture_recurrente_id'] = fr.id;
          m.remove('id');
          return m;
        }).toList();
        await client.from('lignes_facture_recurrente').insert(lignesData);
      }
    } catch (e) {
      throw handleError(e, 'update');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from('factures_recurrentes').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'delete');
    }
  }

  @override
  Future<void> toggleActive(String id, bool estActive) async {
    try {
      await client
          .from('factures_recurrentes')
          .update({'est_active': estActive}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'toggleActive');
    }
  }

  @override
  Future<void> incrementerGeneration(String id, DateTime date) async {
    try {
      // Note: prochaine_emission sera mise à jour par le ViewModel
      await client.rpc('', params: {}); // placeholder

      // Approche directe : incrémenter via update
      final current = await client
          .from('factures_recurrentes')
          .select('nb_factures_generees')
          .eq('id', id)
          .single();

      final nbActuel = current['nb_factures_generees'] ?? 0;

      await client.from('factures_recurrentes').update({
        'nb_factures_generees': nbActuel + 1,
        'derniere_generation': date.toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'incrementerGeneration');
    }
  }
}
