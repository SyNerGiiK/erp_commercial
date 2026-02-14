import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/client_model.dart';
import '../models/photo_model.dart';
import '../repositories/client_repository.dart';

class ClientViewModel extends ChangeNotifier {
  final IClientRepository _repository = ClientRepository();

  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;

  // --- PHOTOS ---
  List<PhotoChantier> _photos = [];
  List<PhotoChantier> get photos => _photos;

  Future<void> fetchClients() async {
    await _executeOperation(() async {
      _clients = await _repository.getClients();
    });
  }

  Future<bool> addClient(Client client) async {
    return await _executeOperation(() async {
      await _repository.createClient(client);
      await fetchClients();
    });
  }

  Future<bool> updateClient(Client client) async {
    return await _executeOperation(() async {
      await _repository.updateClient(client);
      await fetchClients();
    });
  }

  Future<void> deleteClient(String id) async {
    await _executeOperation(() async {
      await _repository.deleteClient(id);
      await fetchClients();
    });
  }

  // --- PHOTOS ---

  Future<void> fetchPhotos(String clientId) async {
    try {
      _photos = await _repository.getPhotos(clientId);
      notifyListeners();
    } catch (e) {
      developer.log("🔴 Erreur fetchPhotos", error: e);
    }
  }

  Future<bool> uploadPhoto(String clientId, XFile imageFile,
      {String? commentaire}) async {
    try {
      await _repository.uploadPhoto(clientId, imageFile,
          commentaire: commentaire);
      await fetchPhotos(clientId);
      return true;
    } catch (e) {
      developer.log("🔴 Erreur uploadPhoto", error: e);
      return false;
    }
  }

  // --- HELPERS ---

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    _isLoading = true;
    notifyListeners();
    try {
      await operation();
      return true;
    } catch (e) {
      developer.log("🔴 ClientVM Error", error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
