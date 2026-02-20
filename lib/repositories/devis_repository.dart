import 'dart:typed_data';

import '../models/devis_model.dart';
import '../core/document_repository.dart';

abstract class IDevisRepository {
  Future<List<Devis>> getDevis({bool archives = false});
  Future<List<Devis>> getChantiersActifs();
  Future<Devis> createDevis(Devis devis);
  Future<void> updateDevis(Devis devis);
  Future<void> deleteDevis(String id);
  Future<void> toggleArchive(String id, bool archive);
  Future<void> finalizeDevis(String id);
  Future<void> markAsSigned(String id, String? signatureUrl);
  Future<String> uploadSignature(String devisId, Uint8List bytes);
  Future<String> generateNextNumero(int annee);
  Future<void> changeStatut(String id, String newStatut);
  Future<int> expireDevisDepasses();
  Future<Devis> createAvenant(String devisParentId);

  // SOFT-DELETE (Corbeille)
  Future<List<Devis>> getDeletedDevis();
  Future<void> restoreDevis(String id);
  Future<void> purgeDevis(String id);
}

class DevisRepository extends DocumentRepository implements IDevisRepository {
  @override
  String get tableName => 'devis';

  @override
  String get numeroPrefix => 'DEV';

  @override
  String get documentType => 'devis';

  @override
  Future<List<Devis>> getDevis({bool archives = false}) async {
    try {
      final response = await client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', archives)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_devis', ascending: true);

      return (response as List).map((e) => Devis.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDevis');
    }
  }

  @override
  Future<List<Devis>> getChantiersActifs() async {
    try {
      final response = await client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', false)
          .inFilter('statut', ['accepte', 'facture', 'signe', 'valide', 'validee'])
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_devis', ascending: true);

      return (response as List).map((e) => Devis.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getChantiersActifs');
    }
  }

  @override
  Future<Devis> createDevis(Devis devis) async {
    try {
      final data = prepareForInsert(devis.toMap());
      data.remove('lignes_devis');
      data.remove('lignes_chiffrages');

      final response =
          await client.from('devis').insert(data).select().single();

      final newId = response['id'] as String;
      await _saveChildren(newId, devis);

      return devis.copyWith(id: newId);
    } catch (e) {
      throw handleError(e, 'createDevis');
    }
  }

  @override
  Future<void> updateDevis(Devis devis) async {
    if (devis.id == null) throw Exception("ID Manquant");
    try {
      final data = prepareForUpdate(devis.toMap());
      data.remove('lignes_devis');
      data.remove('lignes_chiffrages');

      await client.from('devis').update(data).eq('id', devis.id!);

      // Full Replace Strategy
      await deleteChildLines(
        devis.id!,
        ['lignes_devis', 'lignes_chiffrages'],
        'devis_id',
      );
      await _saveChildren(devis.id!, devis);
    } catch (e) {
      throw handleError(e, 'updateDevis');
    }
  }

  @override
  Future<void> deleteDevis(String id) async {
    try {
      // Soft-delete : marque comme supprimé sans effacer les données
      await client.from('devis').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteDevis');
    }
  }

  @override
  Future<void> toggleArchive(String id, bool archive) async {
    await client.from('devis').update({'est_archive': archive}).eq('id', id);
  }

  @override
  Future<void> finalizeDevis(String id) async {
    try {
      // Le trigger SQL `generate_devis_number` assigne automatiquement
      // un numéro séquentiel quand le statut passe à 'envoye'.
      // On ne génère plus de numéro côté Dart (évite les doublons/race conditions).
      await client.from('devis').update({
        'statut': 'envoye',
        'date_emission': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'finalizeDevis');
    }
  }

  @override
  Future<void> markAsSigned(String id, String? signatureUrl) async {
    await client.from('devis').update({
      'statut': 'signe',
      'date_signature': DateTime.now().toIso8601String(),
      if (signatureUrl != null) 'signature_url': signatureUrl,
    }).eq('id', id);
  }

  Future<void> _saveChildren(String devisId, Devis devis) async {
    if (devis.lignes.isNotEmpty) {
      final lignesData = devis.lignes.asMap().entries.map((entry) {
        final map = entry.value.toMap();
        map['devis_id'] = devisId;
        map['ordre'] = entry.key;
        map.remove('id');
        return map;
      }).toList();
      await client.from('lignes_devis').insert(lignesData);
    }
    if (devis.chiffrage.isNotEmpty) {
      final chiffrageData = devis.chiffrage.map((c) {
        final map = c.toMap();
        map['devis_id'] = devisId;
        map['user_id'] = userId;
        map.remove('id');
        return map;
      }).toList();
      await client.from('lignes_chiffrages').insert(chiffrageData);
    }
  }

  @override
  Future<void> changeStatut(String id, String newStatut) async {
    try {
      await client.from('devis').update({'statut': newStatut}).eq('id', id);
    } catch (e) {
      throw handleError(e, 'changeStatut');
    }
  }

  @override
  Future<int> expireDevisDepasses() async {
    try {
      final result = await client.rpc('expire_devis_depasses');
      return (result as int?) ?? 0;
    } catch (e) {
      throw handleError(e, 'expireDevisDepasses');
    }
  }

  @override
  Future<Devis> createAvenant(String devisParentId) async {
    try {
      // Recuperer le devis parent avec ses lignes
      final response = await client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('id', devisParentId)
          .single();
      final parent = Devis.fromMap(response);

      // Creer l'avenant comme nouveau brouillon
      final avenantData = prepareForInsert(parent.toMap());
      avenantData.remove('lignes_devis');
      avenantData.remove('lignes_chiffrages');
      avenantData['statut'] = 'brouillon';
      avenantData['numero_devis'] = '';
      avenantData['devis_parent_id'] = devisParentId;
      avenantData['objet'] = 'Avenant - ${parent.objet}';
      avenantData['date_emission'] = DateTime.now().toIso8601String();
      avenantData['date_validite'] =
          DateTime.now().add(const Duration(days: 30)).toIso8601String();
      avenantData.remove('signature_url');
      avenantData.remove('date_signature');
      avenantData['est_transforme'] = false;
      avenantData['est_archive'] = false;

      final insertResponse =
          await client.from('devis').insert(avenantData).select().single();
      final newId = insertResponse['id'] as String;

      // Copier les lignes et chiffrage
      await _saveChildren(newId, parent);

      return parent.copyWith(
        id: newId,
        devisParentId: devisParentId,
        statut: 'brouillon',
        numeroDevis: '',
        objet: 'Avenant - ${parent.objet}',
      );
    } catch (e) {
      throw handleError(e, 'createAvenant');
    }
  }

  // --- SOFT-DELETE (Corbeille) ---

  @override
  Future<List<Devis>> getDeletedDevis() async {
    try {
      final response = await client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);

      return (response as List).map((e) => Devis.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDeletedDevis');
    }
  }

  @override
  Future<void> restoreDevis(String id) async {
    try {
      await client.from('devis').update({
        'deleted_at': null,
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'restoreDevis');
    }
  }

  @override
  Future<void> purgeDevis(String id) async {
    try {
      await client.from('lignes_devis').delete().eq('devis_id', id);
      await client.from('lignes_chiffrages').delete().eq('devis_id', id);
      await client.from('devis').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'purgeDevis');
    }
  }
}
