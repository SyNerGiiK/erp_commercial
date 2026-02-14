import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/urssaf_model.dart';
import '../config/supabase_config.dart';

abstract class IUrssafRepository {
  Future<UrssafConfig> getConfig();
  Future<void> saveConfig(UrssafConfig config);
}

class UrssafRepository implements IUrssafRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<UrssafConfig> getConfig() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('urssaf_configs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UrssafConfig.fromMap(response);
      }
      return UrssafConfig(); // Retourne config par défaut si pas trouvée
    } catch (e) {
      // Log sans crash critique, retourne défaut
      developer.log("⚠️ UrssafRepo: Pas de config chargée", error: e);
      return UrssafConfig();
    }
  }

  @override
  Future<void> saveConfig(UrssafConfig config) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = config.toMap();
      data.remove('id'); // On ne touche pas à l'ID directement

      // Stratégie "Check existence" pour gérer l'ID correctement
      final existing = await _client
          .from('urssaf_configs')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // UPDATE
        data.remove('user_id'); // Sécurité RLS
        await _client
            .from('urssaf_configs')
            .update(data)
            .eq('id', existing['id']);
      } else {
        // INSERT
        data['user_id'] = userId;
        await _client.from('urssaf_configs').insert(data);
      }
    } catch (e) {
      throw _handleError(e, 'saveConfig');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 UrssafRepo Error ($method)", error: error);
    return Exception("Erreur Urssaf ($method): $error");
  }
}
