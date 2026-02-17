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

  // GESTION DES PAIEMENTS
  Future<void> addPaiement(Paiement paiement);
  Future<void> deletePaiement(String id);

  // SIGNATURE
  Future<String> uploadSignature(String factureId, Uint8List bytes);
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
}
