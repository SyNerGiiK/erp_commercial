import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/depense_model.dart';
import '../config/supabase_config.dart';

abstract class IDepenseRepository {
  Future<List<Depense>> getDepenses();
  Future<void> createDepense(Depense depense);
  Future<void> updateDepense(Depense depense);
  Future<void> deleteDepense(String id);
}

class DepenseRepository implements IDepenseRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Depense>> getDepenses() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getDepenses');
    }
  }

  @override
  Future<void> createDepense(Depense depense) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = depense.toMap();
      data['user_id'] = userId;
      data.remove('id');

      await _client.from('depenses').insert(data);
    } catch (e) {
      throw _handleError(e, 'createDepense');
    }
  }

  @override
  Future<void> updateDepense(Depense depense) async {
    if (depense.id == null) return;
    try {
      final data = depense.toMap();
      data.remove('user_id'); // Sécurité RLS

      await _client.from('depenses').update(data).eq('id', depense.id!);
    } catch (e) {
      throw _handleError(e, 'updateDepense');
    }
  }

  @override
  Future<void> deleteDepense(String id) async {
    try {
      await _client.from('depenses').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteDepense');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 DepenseRepo Error ($method)", error: error);
    return Exception("Erreur Dépenses ($method): $error");
  }
}
