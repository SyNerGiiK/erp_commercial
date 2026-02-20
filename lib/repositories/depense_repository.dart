import 'dart:developer' as developer;
import '../models/depense_model.dart';
import '../core/base_repository.dart';

abstract class IDepenseRepository {
  Future<List<Depense>> getDepenses();
  Future<List<Depense>> getDepensesByChantier(String devisId);
  Future<void> createDepense(Depense depense);
  Future<void> updateDepense(Depense depense);
  Future<void> deleteDepense(String id);

  // SOFT-DELETE (Corbeille)
  Future<List<Depense>> getDeletedDepenses();
  Future<void> restoreDepense(String id);
  Future<void> purgeDepense(String id);
}

class DepenseRepository extends BaseRepository implements IDepenseRepository {
  @override
  Future<List<Depense>> getDepenses() async {
    try {
      final response = await client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('date', ascending: false);

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDepenses');
    }
  }

  @override
  Future<List<Depense>> getDepensesByChantier(String devisId) async {
    try {
      final response = await client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .eq('chantier_devis_id', devisId)
          .isFilter('deleted_at', null)
          .order('date', ascending: false);

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDepensesByChantier');
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
      // Soft-delete : marque comme supprimé sans effacer les données
      await client.from('depenses').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteDepense');
    }
  }

  // --- SOFT-DELETE (Corbeille) ---

  @override
  Future<List<Depense>> getDeletedDepenses() async {
    try {
      final response = await client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDeletedDepenses');
    }
  }

  @override
  Future<void> restoreDepense(String id) async {
    try {
      await client.from('depenses').update({
        'deleted_at': null,
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'restoreDepense');
    }
  }

  @override
  Future<void> purgeDepense(String id) async {
    try {
      await client.from('depenses').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'purgeDepense');
    }
  }
}
