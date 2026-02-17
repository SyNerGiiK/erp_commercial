import 'dart:developer' as developer;
import '../models/urssaf_model.dart';
import '../core/base_repository.dart';

abstract class IUrssafRepository {
  Future<UrssafConfig> getConfig();
  Future<void> saveConfig(UrssafConfig config);
}

class UrssafRepository extends BaseRepository implements IUrssafRepository {
  @override
  Future<UrssafConfig> getConfig() async {
    try {
      final response = await client
          .from('urssaf_configs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UrssafConfig.fromMap(response);
      }
      return UrssafConfig(userId: userId);
    } catch (e, s) {
      developer.log("⚠️ UrssafRepo: Pas de config chargée",
          error: e, stackTrace: s);
      return UrssafConfig(userId: userId, id: '');
    }
  }

  @override
  Future<void> saveConfig(UrssafConfig config) async {
    try {
      final data = prepareForUpdate(config.toMap());

      final existing = await client
          .from('urssaf_configs')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await client
            .from('urssaf_configs')
            .update(data)
            .eq('id', existing['id']);
      } else {
        final insertData = prepareForInsert(config.toMap());
        await client.from('urssaf_configs').insert(insertData);
      }
    } catch (e, s) {
      developer.log("🔴 UrssafRepo Error (saveConfig)",
          error: e, stackTrace: s);
      throw handleError(e, 'saveConfig');
    }
  }
}
