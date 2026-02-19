import 'package:decimal/decimal.dart';
import '../models/chiffrage_model.dart';
import '../core/base_repository.dart';

/// Interface du repository de chiffrage.
/// Permet le CRUD unitaire des lignes de chiffrage avec auto-save transparent.
abstract class IChiffrageRepository {
  /// Récupère toutes les lignes de chiffrage d'un devis
  Future<List<LigneChiffrage>> getByDevisId(String devisId);

  /// Récupère les lignes liées à une ligne de devis spécifique
  Future<List<LigneChiffrage>> getByLigneDevisId(String ligneDevisId);

  /// Crée une ligne de chiffrage et retourne l'objet avec son ID
  Future<LigneChiffrage> create(LigneChiffrage ligne);

  /// Met à jour une ligne de chiffrage (auto-save unitaire)
  Future<void> update(LigneChiffrage ligne);

  /// Met à jour uniquement le statut d'achat (toggle rapide)
  Future<void> updateEstAchete(String id, bool estAchete);

  /// Met à jour uniquement l'avancement MO (slider rapide)
  Future<void> updateAvancementMo(String id, Decimal avancementMo);

  /// Supprime une ligne de chiffrage
  Future<void> delete(String id);

  /// Supprime toutes les lignes de chiffrage d'un devis
  Future<void> deleteAllForDevis(String devisId);
}

class ChiffrageRepository extends BaseRepository
    implements IChiffrageRepository {
  @override
  Future<List<LigneChiffrage>> getByDevisId(String devisId) async {
    try {
      final response = await client
          .from('lignes_chiffrages')
          .select()
          .eq('user_id', userId)
          .eq('devis_id', devisId)
          .order('created_at', ascending: true);

      return (response as List).map((e) => LigneChiffrage.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getByDevisId');
    }
  }

  @override
  Future<List<LigneChiffrage>> getByLigneDevisId(String ligneDevisId) async {
    try {
      final response = await client
          .from('lignes_chiffrages')
          .select()
          .eq('user_id', userId)
          .eq('linked_ligne_devis_id', ligneDevisId)
          .order('created_at', ascending: true);

      return (response as List).map((e) => LigneChiffrage.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getByLigneDevisId');
    }
  }

  @override
  Future<LigneChiffrage> create(LigneChiffrage ligne) async {
    try {
      final data = ligne.toMap();
      data['user_id'] = userId;
      data.remove('id');

      final response =
          await client.from('lignes_chiffrages').insert(data).select().single();

      return LigneChiffrage.fromMap(response);
    } catch (e) {
      throw handleError(e, 'create');
    }
  }

  @override
  Future<void> update(LigneChiffrage ligne) async {
    if (ligne.id == null) throw Exception('ID manquant pour update chiffrage');
    try {
      final data = ligne.toMap();
      data.remove('id');
      data.remove('user_id');

      await client.from('lignes_chiffrages').update(data).eq('id', ligne.id!);
    } catch (e) {
      throw handleError(e, 'update');
    }
  }

  @override
  Future<void> updateEstAchete(String id, bool estAchete) async {
    try {
      await client
          .from('lignes_chiffrages')
          .update({'est_achete': estAchete}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'updateEstAchete');
    }
  }

  @override
  Future<void> updateAvancementMo(String id, Decimal avancementMo) async {
    try {
      await client
          .from('lignes_chiffrages')
          .update({'avancement_mo': avancementMo.toString()}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'updateAvancementMo');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await client.from('lignes_chiffrages').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'delete');
    }
  }

  @override
  Future<void> deleteAllForDevis(String devisId) async {
    try {
      await client.from('lignes_chiffrages').delete().eq('devis_id', devisId);
    } catch (e) {
      throw handleError(e, 'deleteAllForDevis');
    }
  }
}
