import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/devis_model.dart';
import '../config/supabase_config.dart';

abstract class IDevisRepository {
  Future<List<Devis>> getDevis({bool archives = false});
  Future<Devis> createDevis(Devis devis);
  Future<void> updateDevis(Devis devis);
  Future<void> deleteDevis(String id);
  Future<void> toggleArchive(String id, bool archive);
  Future<void> finalizeDevis(String id, String numero);
  Future<void> markAsSigned(String id, String? signatureUrl);
  Future<String> generateNextNumero(int annee);
}

class DevisRepository implements IDevisRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Devis>> getDevis({bool archives = false}) async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', archives)
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_devis', ascending: true);

      return (response as List).map((e) => Devis.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getDevis');
    }
  }

  @override
  Future<Devis> createDevis(Devis devis) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = devis.toMap();
      data['user_id'] = userId;
      data.remove('id');

      final response =
          await _client.from('devis').insert(data).select().single();

      final newId = response['id'] as String;
      await _saveChildren(newId, devis, userId);

      return devis.copyWith(id: newId);
    } catch (e) {
      throw _handleError(e, 'createDevis');
    }
  }

  @override
  Future<void> updateDevis(Devis devis) async {
    if (devis.id == null) throw Exception("ID Manquant");
    try {
      final userId = SupabaseConfig.userId;
      final data = devis.toMap();
      data.remove('user_id');
      data.remove('id');

      await _client.from('devis').update(data).eq('id', devis.id!);

      // Full Replace Strategy (Comme Facture)
      await _client.from('lignes_devis').delete().eq('devis_id', devis.id!);
      await _client
          .from('lignes_chiffrages')
          .delete()
          .eq('devis_id', devis.id!);

      await _saveChildren(devis.id!, devis, userId);
    } catch (e) {
      throw _handleError(e, 'updateDevis');
    }
  }

  @override
  Future<void> deleteDevis(String id) async {
    try {
      await _client.from('devis').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteDevis');
    }
  }

  @override
  Future<void> toggleArchive(String id, bool archive) async {
    await _client.from('devis').update({'est_archive': archive}).eq('id', id);
  }

  @override
  Future<void> finalizeDevis(String id, String numero) async {
    await _client
        .from('devis')
        .update({'numero_devis': numero, 'statut': 'envoye'}).eq('id', id);
  }

  @override
  Future<void> markAsSigned(String id, String? signatureUrl) async {
    await _client.from('devis').update({
      'statut': 'signe',
      'date_signature': DateTime.now().toIso8601String(),
      if (signatureUrl != null) 'signature_url': signatureUrl,
    }).eq('id', id);
  }

  @override
  Future<String> generateNextNumero(int annee) async {
    final userId = SupabaseConfig.userId;
    final params = {
      'p_type_doc': 'devis',
      'p_user_id': userId,
      'p_annee': annee
    };
    return await _client.rpc('get_next_document_number', params: params);
  }

  Future<void> _saveChildren(String devisId, Devis devis, String userId) async {
    if (devis.lignes.isNotEmpty) {
      final lignesData = devis.lignes.asMap().entries.map((entry) {
        final map = entry.value.toMap();
        map['devis_id'] = devisId;
        map['ordre'] = entry.key;
        map.remove('id');
        return map;
      }).toList();
      await _client.from('lignes_devis').insert(lignesData);
    }
    if (devis.chiffrage.isNotEmpty) {
      final chiffrageData = devis.chiffrage.map((c) {
        final map = c.toMap();
        map['devis_id'] = devisId;
        map['user_id'] = userId;
        map.remove('id');
        return map;
      }).toList();
      await _client.from('lignes_chiffrages').insert(chiffrageData);
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 DevisRepo Error ($method)", error: error);
    return Exception("Erreur ($method): $error");
  }
}
