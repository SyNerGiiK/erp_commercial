import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import '../models/pdf_design_config.dart';
import '../core/base_repository.dart';

abstract class IPdfDesignRepository {
  Future<PdfDesignConfig?> getConfig(String entrepriseId);
  Future<void> saveConfig(PdfDesignConfig config);
  Future<String> uploadAsset(XFile file, String assetName);
  Future<String> uploadAssetBytes(Uint8List bytes, String assetName);
}

class PdfDesignRepository extends BaseRepository
    implements IPdfDesignRepository {
  @override
  Future<PdfDesignConfig?> getConfig(String entrepriseId) async {
    try {
      final response = await client
          .from('pdf_design_configs')
          .select()
          .eq('entreprise_id', entrepriseId)
          .maybeSingle();

      if (response == null) return null;
      return PdfDesignConfig.fromJson(response);
    } catch (e) {
      developer.log("Erreur lors de la récupération de PdfDesignConfig",
          error: e);
      return null;
    }
  }

  @override
  Future<void> saveConfig(PdfDesignConfig config) async {
    try {
      final data = config.toJson();
      // Retirer les champs gérés par Supabase
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      // UPSERT sur la contrainte UNIQUE (entreprise_id)
      await client
          .from('pdf_design_configs')
          .upsert(data, onConflict: 'entreprise_id');
    } catch (e) {
      throw handleError(e, 'saveConfig');
    }
  }

  @override
  Future<String> uploadAsset(XFile file, String assetName) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.name.split('.').last;
      // Using userId internally for the storage path isolation
      final fileName =
          '${assetName}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$userId/pdf_assets/$fileName';

      await client.storage.from('pdf_assets').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('pdf_assets').getPublicUrl(path);
      return url;
    } catch (e) {
      throw handleError(e, 'uploadAsset ($assetName)');
    }
  }

  @override
  Future<String> uploadAssetBytes(Uint8List bytes, String assetName) async {
    try {
      final fileName =
          '${assetName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = '$userId/pdf_assets/$fileName';

      await client.storage.from('pdf_assets').uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(upsert: true, contentType: 'image/png'),
          );

      final url = client.storage.from('pdf_assets').getPublicUrl(path);
      return url;
    } catch (e) {
      throw handleError(e, 'uploadAssetBytes ($assetName)');
    }
  }
}
