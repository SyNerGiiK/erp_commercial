import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/urssaf_model.dart';
import '../config/supabase_config.dart';

abstract class IUrssafRepository {
  Future<UrssafConfig> getConfig();
  Future<void> saveConfig(UrssafConfig config);
}

class UrssafRepository implements IUrssafRepository {
  // Instance singleton pour éviter les soucis de scope
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<UrssafConfig> getConfig() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return UrssafConfig(userId: '');

      final userId = session.user.id;
      final response = await _client
          .from('urssaf_configs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UrssafConfig.fromMap(response);
      }
      // Retourne config par défaut avec l'ID user actuel
      return UrssafConfig(userId: userId);
    } catch (e, s) {
      developer.log("⚠️ UrssafRepo: Pas de config chargée",
          error: e, stackTrace: s);
      // Fallback safe
      return UrssafConfig(userId: _client.auth.currentUser?.id ?? '', id: '');
    }
  }

  @override
  Future<void> saveConfig(UrssafConfig config) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) throw Exception("Utilisateur non connecté");

      final userId = session.user.id;
      final data = config.toMap();

      // Nettoyage sécurité
      data.remove('id');
      data.remove('user_id'); // On ne peut pas update le user_id

      // Check existence
      final existing = await _client
          .from('urssaf_configs')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // UPDATE
        await _client
            .from('urssaf_configs')
            .update(data)
            .eq('id', existing['id']);
      } else {
        // INSERT
        data['user_id'] = userId; // Nécessaire pour l'insert
        await _client.from('urssaf_configs').insert(data);
      }
    } catch (e, s) {
      developer.log("🔴 UrssafRepo Error (saveConfig)",
          error: e, stackTrace: s);
      throw Exception("Erreur sauvegarde Urssaf: $e");
    }
  }
}
