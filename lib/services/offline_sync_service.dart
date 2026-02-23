import 'dart:convert';
import 'dart:developer' as developer;
import '../config/supabase_config.dart';
import 'secure_storage_service.dart';

/// Service gérant la file d'attente des mutations hors-ligne
class OfflineSyncService {
  static const String _queueKey = 'artisan_offline_sync_queue';

  /// Récupère la file d'attente des mutations hors-ligne
  static Future<List<Map<String, dynamic>>> getQueue() async {
    final data = await SecureStorageService.read(_queueKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      developer.log('❌ Parsing offline queue failed: $e');
      return [];
    }
  }

  /// Ajoute une opération (insert/update/delete) à la file d'attente
  static Future<void> enqueueMutation({
    required String table,
    required String action, // 'insert', 'update', 'delete'
    required Map<String, dynamic> payload,
    String? recordId, // Obligatoire pour 'update' et 'delete'
  }) async {
    try {
      final queue = await getQueue();
      queue.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'table': table,
        'action': action,
        'payload': payload,
        'recordId': recordId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await SecureStorageService.write(_queueKey, jsonEncode(queue));
      developer.log(
          '📦 Opération hors-ligne mise en file d\'attente : $action sur $table');
    } catch (e) {
      developer.log('❌ Failed to enqueue offline mutation: $e');
    }
  }

  /// Tente de synchroniser la file d'attente vers Supabase
  /// Retourne le nombre d'erreurs (0 = succès total)
  static Future<int> syncUp() async {
    final queue = await getQueue();
    if (queue.isEmpty) {
      return 0;
    }

    developer.log(
        '🔄 Début de la synchronisation différée (${queue.length} éléments)');
    final client = SupabaseConfig.client;

    List<Map<String, dynamic>> failedItems = [];

    // Traiter dans l'ordre chronologique
    for (var item in queue) {
      final table = item['table'] as String;
      final action = item['action'] as String;
      final payload = item['payload'] as Map<String, dynamic>;
      final recordId = item['recordId'] as String?;

      try {
        switch (action) {
          case 'insert':
            await client.from(table).insert(payload);
            break;
          case 'update':
            if (recordId == null) {
              throw Exception('recordId missing for update');
            }
            await client.from(table).update(payload).eq('id', recordId);
            break;
          case 'delete':
            if (recordId == null) {
              throw Exception('recordId missing for delete');
            }
            await client.from(table).delete().eq('id', recordId);
            break;
          default:
            developer.log('Action inconnue: $action');
        }
        developer.log('✅ Sync success: $action on $table');
      } catch (e) {
        developer.log('❌ Sync error ($action on $table): $e');
        failedItems.add(item);
      }
    }

    if (failedItems.isEmpty) {
      await SecureStorageService.delete(_queueKey);
      developer.log('🎉 Synchronisation totale réussie.');
    } else {
      await SecureStorageService.write(_queueKey, jsonEncode(failedItems));
      developer.log(
          '⚠️ Synchronisation partielle : ${failedItems.length} échecs conservés en attente.');
    }

    return failedItems.length;
  }
}
