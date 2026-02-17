import 'dart:typed_data';

import '../models/devis_model.dart';
import '../core/document_repository.dart';

abstract class IDevisRepository {
  Future<List<Devis>> getDevis({bool archives = false});
  Future<Devis> createDevis(Devis devis);
  Future<void> updateDevis(Devis devis);
  Future<void> deleteDevis(String id);
  Future<void> toggleArchive(String id, bool archive);
  Future<void> finalizeDevis(String id);
  Future<void> markAsSigned(String id, String? signatureUrl);
  Future<String> uploadSignature(String devisId, Uint8List bytes);
  Future<String> generateNextNumero(int annee);
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
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_devis', ascending: true);

      return (response as List).map((e) => Devis.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDevis');
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
      await client.from('devis').delete().eq('id', id);
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
      final current = await client
          .from('devis')
          .select('numero_devis')
          .eq('id', id)
          .single();
      final currentNum = current['numero_devis'] as String?;

      final updates = <String, dynamic>{
        'statut': 'en_attente',
      };

      if (currentNum == null ||
          currentNum.trim().toLowerCase() == 'brouillon' ||
          currentNum.isEmpty) {
        final newNum = await generateNextNumero(DateTime.now().year);
        updates['numero_devis'] = newNum;
        updates['date_emission'] = DateTime.now().toIso8601String();
      }

      await client.from('devis').update(updates).eq('id', id);
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
}
