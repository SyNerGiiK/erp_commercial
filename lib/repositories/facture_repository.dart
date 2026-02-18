import 'dart:typed_data';

import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import '../core/document_repository.dart';

abstract class IFactureRepository {
  Future<List<Facture>> getFactures({bool archives = false});
  Future<Facture> createFacture(Facture facture);
  Future<void> updateFacture(Facture facture);
  Future<void> deleteFacture(String id);
  Future<void> updateStatus(String id, String status);
  Future<void> updateArchiveStatus(String id, bool isArchived);
  Future<String> generateNextNumero(int annee);

  /// Finalise une facture brouillon → validée (numéro attribué par trigger SQL)
  Future<void> finaliserFacture(String id);

  // GESTION DES PAIEMENTS
  Future<void> addPaiement(Paiement paiement);
  Future<void> deletePaiement(String id);

  // SIGNATURE
  Future<String> uploadSignature(String factureId, Uint8List bytes);

  // FACTURES LIÉES (pour historique règlements devis)
  Future<List<Facture>> getLinkedFactures(String devisSourceId,
      {String? excludeFactureId});

  // FACTURES EN RETARD
  Future<List<Facture>> getFacturesEnRetard();

  // SOFT-DELETE (Corbeille)
  Future<List<Facture>> getDeletedFactures();
  Future<void> restoreFacture(String id);
  Future<void> purgeFacture(String id);
}

class FactureRepository extends DocumentRepository
    implements IFactureRepository {
  @override
  String get tableName => 'factures';

  @override
  String get numeroPrefix => 'FAC';

  @override
  String get documentType => 'facture';

  @override
  Future<List<Facture>> getFactures({bool archives = false}) async {
    try {
      final response = await client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', archives)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_factures', ascending: true);

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getFactures');
    }
  }

  @override
  Future<Facture> createFacture(Facture facture) async {
    try {
      final data = prepareForInsert(facture.toMap());
      data.remove('lignes_factures');
      data.remove('lignes_chiffrages');
      data.remove('paiements');

      final response =
          await client.from('factures').insert(data).select().single();

      final newFactureId = response['id'];

      await _saveChildren(newFactureId, facture, savePaiements: true);

      return Facture.fromMap(response);
    } catch (e) {
      throw handleError(e, 'createFacture');
    }
  }

  @override
  Future<void> updateFacture(Facture facture) async {
    if (facture.id == null) return;
    try {
      // 🛡️ Vérifier l'immutabilité en base : seuls les brouillons sont modifiables
      final existing = await client
          .from('factures')
          .select('statut_juridique')
          .eq('id', facture.id!)
          .single();
      final currentStatut = existing['statut_juridique'] ?? 'brouillon';
      if (currentStatut != 'brouillon') {
        throw Exception(
            'Facture verrouillée (statut juridique: $currentStatut). '
            'Modification interdite après validation.');
      }

      final data = prepareForUpdate(facture.toMap());
      data.remove('numero_facture');
      data.remove('lignes_factures');
      data.remove('lignes_chiffrages');
      data.remove('paiements');

      await client.from('factures').update(data).eq('id', facture.id!);

      // Full Replace (ne pas supprimer les paiements pour garder l'historique)
      await deleteChildLines(
        facture.id!,
        ['lignes_factures', 'lignes_chiffrages'],
        'facture_id',
      );

      await _saveChildren(facture.id!, facture, savePaiements: false);
    } catch (e) {
      throw handleError(e, 'updateFacture');
    }
  }

  @override
  Future<void> deleteFacture(String id) async {
    try {
      // Soft-delete : marque comme supprimé sans effacer les données
      await client.from('factures').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteFacture');
    }
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    try {
      await client.from('factures').update({'statut': status}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'updateStatus');
    }
  }

  @override
  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      await client
          .from('factures')
          .update({'est_archive': isArchived}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'updateArchiveStatus');
    }
  }

  @override
  Future<void> finaliserFacture(String id) async {
    try {
      // Le trigger SQL generate_facture_number() détecte le changement
      // statut_juridique → 'validee' et attribue le numéro séquentiel.
      // On envoie numero_facture vide pour signaler au trigger de le remplir.
      await client.from('factures').update({
        'statut': 'validee',
        'statut_juridique': 'validee',
        'numero_facture': '', // Le trigger le remplacera
        'date_validation': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'finaliserFacture');
    }
  }

  @override
  Future<void> addPaiement(Paiement paiement) async {
    try {
      final data = paiement.toMap();
      data.remove('id');
      await client.from('paiements').insert(data);
    } catch (e) {
      throw handleError(e, 'addPaiement');
    }
  }

  @override
  Future<void> deletePaiement(String id) async {
    try {
      await client.from('paiements').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'deletePaiement');
    }
  }

  @override
  Future<List<Facture>> getLinkedFactures(String devisSourceId,
      {String? excludeFactureId}) async {
    try {
      var query = client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('devis_source_id', devisSourceId)
          .isFilter('deleted_at', null);

      if (excludeFactureId != null && excludeFactureId.isNotEmpty) {
        query = query.neq('id', excludeFactureId);
      }

      final response = await query;
      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getLinkedFactures');
    }
  }

  @override
  Future<List<Facture>> getFacturesEnRetard() async {
    try {
      final response = await client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', false)
          .isFilter('deleted_at', null)
          .inFilter('statut', ['validee', 'envoye'])
          .lt('date_echeance', DateTime.now().toIso8601String())
          .order('date_echeance', ascending: true);

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getFacturesEnRetard');
    }
  }

  Future<void> _saveChildren(String factureId, Facture facture,
      {bool savePaiements = true}) async {
    if (facture.lignes.isNotEmpty) {
      final lignesData = facture.lignes.asMap().entries.map((entry) {
        final map = entry.value.toMap();
        map['facture_id'] = factureId;
        map['ordre'] = entry.key;
        map.remove('id');
        return map;
      }).toList();
      await client.from('lignes_factures').insert(lignesData);
    }

    if (facture.chiffrage.isNotEmpty) {
      final chiffrageData = facture.chiffrage.map((c) {
        final map = c.toMap();
        map['facture_id'] = factureId;
        map['user_id'] = userId;
        map.remove('id');
        return map;
      }).toList();
      await client.from('lignes_chiffrages').insert(chiffrageData);
    }

    if (savePaiements && facture.paiements.isNotEmpty) {
      final paiementsData = facture.paiements.map((p) {
        final map = p.toMap();
        map['facture_id'] = factureId;
        map.remove('id');
        return map;
      }).toList();
      await client.from('paiements').insert(paiementsData);
    }
  }

  // --- SOFT-DELETE (Corbeille) ---

  @override
  Future<List<Facture>> getDeletedFactures() async {
    try {
      final response = await client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDeletedFactures');
    }
  }

  @override
  Future<void> restoreFacture(String id) async {
    try {
      await client.from('factures').update({
        'deleted_at': null,
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'restoreFacture');
    }
  }

  @override
  Future<void> purgeFacture(String id) async {
    try {
      // Detach Avoirs (Self-referencing FK)
      await client
          .from('factures')
          .update({'facture_source_id': null}).eq('facture_source_id', id);

      // FORCE MANUAL CASCADE
      await client.from('lignes_factures').delete().eq('facture_id', id);
      await client.from('lignes_chiffrages').delete().eq('facture_id', id);
      await client.from('paiements').delete().eq('facture_id', id);

      await client.from('factures').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'purgeFacture');
    }
  }
}
