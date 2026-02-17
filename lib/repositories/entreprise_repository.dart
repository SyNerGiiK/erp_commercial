import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import '../models/entreprise_model.dart';
import '../core/base_repository.dart';

abstract class IEntrepriseRepository {
  Future<ProfilEntreprise?> getProfil();
  Future<void> saveProfil(ProfilEntreprise profil);
  Future<String> uploadImage(XFile file, String type);
  Future<String> uploadSignatureBytes(Uint8List bytes);
}

class EntrepriseRepository extends BaseRepository
    implements IEntrepriseRepository {
  @override
  Future<ProfilEntreprise?> getProfil() async {
    try {
      final response = await client
          .from('entreprises')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ProfilEntreprise.fromMap(response);
    } catch (e) {
      developer.log("Info: Pas de profil trouvé ou erreur", error: e);
      return null;
    }
  }

  @override
  Future<void> saveProfil(ProfilEntreprise profil) async {
    try {
      final data = profil.toMap();

      if (profil.id != null) {
        // UPDATE
        final updateData = prepareForUpdate(data);
        await client
            .from('entreprises')
            .update(updateData)
            .eq('id', profil.id!);
      } else {
        // INSERT
        final insertData = prepareForInsert(data);
        await client.from('entreprises').insert(insertData);
      }
    } catch (e) {
      throw handleError(e, 'saveProfil');
    }
  }

  @override
  Future<String> uploadImage(XFile file, String type) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.name.split('.').last;
      final fileName = '$type.$fileExt';
      final path = '$userId/entreprise/$fileName';

      await client.storage.from('documents').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = client.storage.from('documents').getPublicUrl(path);
      return "$url?t=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      throw handleError(e, 'uploadImage ($type)');
    }
  }

  @override
  Future<String> uploadSignatureBytes(Uint8List bytes) async {
    try {
      final path = '$userId/entreprise/signature.png';

      await client.storage.from('documents').uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(upsert: true, contentType: 'image/png'),
          );

      final url = client.storage.from('documents').getPublicUrl(path);
      return "$url?t=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      throw handleError(e, 'uploadSignatureBytes');
    }
  }
}
