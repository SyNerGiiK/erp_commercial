import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

import '../models/client_model.dart';
import '../models/photo_model.dart';
import '../config/supabase_config.dart';

abstract class IClientRepository {
  Future<List<Client>> getClients();
  Future<Client> createClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String id);

  // Photos
  Future<List<PhotoChantier>> getPhotos(String clientId);
  Future<void> uploadPhoto(String clientId, XFile imageFile,
      {String? commentaire});
}

class ClientRepository implements IClientRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Client>> getClients() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .order('nom_complet', ascending: true);

      return (response as List).map((e) => Client.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getClients');
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = client.toMap();
      data['user_id'] = userId;
      data.remove('id');

      final response =
          await _client.from('clients').insert(data).select().single();

      return Client.fromMap(response);
    } catch (e) {
      throw _handleError(e, 'createClient');
    }
  }

  @override
  Future<void> updateClient(Client client) async {
    if (client.id == null) throw Exception("ID manquant pour updateClient");
    try {
      final data = client.toMap();
      data.remove('user_id'); // RLS Safety
      data.remove('id');

      await _client.from('clients').update(data).eq('id', client.id!);
    } catch (e) {
      throw _handleError(e, 'updateClient');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await _client.from('clients').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteClient');
    }
  }

  // --- PHOTOS ---

  @override
  Future<List<PhotoChantier>> getPhotos(String clientId) async {
    try {
      final response = await _client
          .from('photos')
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => PhotoChantier.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getPhotos');
    }
  }

  @override
  Future<void> uploadPhoto(String clientId, XFile imageFile,
      {String? commentaire}) async {
    try {
      final userId = SupabaseConfig.userId;
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.name.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${fileExt.isEmpty ? "jpg" : fileExt}';
      final path = '$userId/photos/$clientId/$fileName';

      // 1. Upload Storage
      await _client.storage.from('documents').uploadBinary(path, bytes,
          fileOptions:
              const FileOptions(contentType: 'image/jpeg', upsert: true));

      final url = _client.storage.from('documents').getPublicUrl(path);

      // 2. Insert DB
      await _client.from('photos').insert({
        'user_id': userId,
        'client_id': clientId,
        'url': url,
        'commentaire': commentaire,
        'created_at': DateTime.now().toIso8601String()
      });
    } catch (e) {
      throw _handleError(e, 'uploadPhoto');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 ClientRepo Error ($method)", error: error);
    return Exception("Erreur ($method): $error");
  }
}
