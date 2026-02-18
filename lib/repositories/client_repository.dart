import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import '../models/client_model.dart';
import '../models/photo_model.dart';
import '../core/base_repository.dart';

abstract class IClientRepository {
  Future<List<Client>> getClients();
  Future<Client> createClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String id);
  Future<List<PhotoChantier>> getPhotos(String clientId);
  Future<void> uploadPhoto(String clientId, XFile imageFile,
      {String? commentaire});

  // SOFT-DELETE (Corbeille)
  Future<List<Client>> getDeletedClients();
  Future<void> restoreClient(String id);
  Future<void> purgeClient(String id);
}

class ClientRepository extends BaseRepository implements IClientRepository {
  @override
  Future<List<Client>> getClients() async {
    try {
      final response = await client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('nom_complet', ascending: true);

      return (response as List).map((e) => Client.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getClients');
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    try {
      final data = prepareForInsert(client.toMap());
      final response =
          await this.client.from('clients').insert(data).select().single();
      return Client.fromMap(response);
    } catch (e) {
      throw handleError(e, 'createClient');
    }
  }

  @override
  Future<void> updateClient(Client client) async {
    if (client.id == null) throw Exception("ID manquant pour updateClient");
    try {
      final data = prepareForUpdate(client.toMap());
      await this.client.from('clients').update(data).eq('id', client.id!);
    } catch (e) {
      throw handleError(e, 'updateClient');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      // Soft-delete : marque comme supprimé sans effacer les données
      await client.from('clients').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteClient');
    }
  }

  @override
  Future<List<PhotoChantier>> getPhotos(String clientId) async {
    try {
      final response = await client
          .from('photos')
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => PhotoChantier.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getPhotos');
    }
  }

  @override
  Future<void> uploadPhoto(String clientId, XFile imageFile,
      {String? commentaire}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.name.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${fileExt.isEmpty ? "jpg" : fileExt}';
      final path = '$userId/photos/$clientId/$fileName';

      // 1. Upload Storage
      await client.storage.from('documents').uploadBinary(path, bytes,
          fileOptions:
              const FileOptions(contentType: 'image/jpeg', upsert: true));

      final url = client.storage.from('documents').getPublicUrl(path);

      // 2. Insert DB
      await client.from('photos').insert({
        'user_id': userId,
        'client_id': clientId,
        'url': url,
        'commentaire': commentaire,
        'created_at': DateTime.now().toIso8601String()
      });
    } catch (e) {
      throw handleError(e, 'uploadPhoto');
    }
  }

  // --- SOFT-DELETE (Corbeille) ---

  @override
  Future<List<Client>> getDeletedClients() async {
    try {
      final response = await client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);

      return (response as List).map((e) => Client.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDeletedClients');
    }
  }

  @override
  Future<void> restoreClient(String id) async {
    try {
      await client.from('clients').update({
        'deleted_at': null,
      }).eq('id', id);
    } catch (e) {
      throw handleError(e, 'restoreClient');
    }
  }

  @override
  Future<void> purgeClient(String id) async {
    try {
      await client.from('clients').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'purgeClient');
    }
  }
}
