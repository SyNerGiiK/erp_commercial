import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

import '../models/entreprise_model.dart';
import '../config/supabase_config.dart';

abstract class IEntrepriseRepository {
  Future<ProfilEntreprise?> getProfil();
  Future<void> saveProfil(ProfilEntreprise profil);
  Future<String> uploadImage(
      XFile file, String type); // type = 'logo' ou 'signature'
}

class EntrepriseRepository implements IEntrepriseRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<ProfilEntreprise?> getProfil() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
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
      final userId = SupabaseConfig.userId;
      final data = profil.toMap();

      if (profil.id != null) {
        // UPDATE
        data.remove('user_id'); // Sécurité RLS
        await _client.from('entreprises').update(data).eq('id', profil.id!);
      } else {
        // INSERT
        data['user_id'] = userId;
        if (data['id'] == null) data.remove('id');
        await _client.from('entreprises').insert(data);
      }
    } catch (e) {
      throw _handleError(e, 'saveProfil');
    }
  }

  @override
  Future<String> uploadImage(XFile file, String type) async {
    try {
      final userId = SupabaseConfig.userId;
      final bytes = await file.readAsBytes();
      final fileExt = file.name.split('.').last;
      // On utilise un nom fixe pour écraser l'ancien fichier automatiquement (gain de place)
      final fileName = '$type.$fileExt';
      final path = '$userId/entreprise/$fileName';

      // Upload dans le bucket 'documents' (ou 'public' selon ta config Supabase)
      await _client.storage.from('documents').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Récupération URL publique
      final url = _client.storage.from('documents').getPublicUrl(path);

      // Hack pour invalider le cache navigateur si l'image change mais garde le même nom
      return "$url?t=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      throw _handleError(e, 'uploadImage ($type)');
    }
  }

  Exception _handleError(dynamic error, String context) {
    developer.log("🔴 Erreur Repo Entreprise ($context)", error: error);
    return Exception("Erreur ($context): $error");
  }
}
