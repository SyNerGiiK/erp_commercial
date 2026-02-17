import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:decimal/decimal.dart';

import '../models/client_model.dart';
import '../models/photo_model.dart';
import '../repositories/client_repository.dart';
import '../core/base_viewmodel.dart';

class ClientViewModel extends BaseViewModel {
  final IClientRepository _repository;

  List<Client> _clients = [];

  ClientViewModel({IClientRepository? repository})
      : _repository = repository ?? ClientRepository();

  List<Client> get clients => _clients;

  // --- PHOTOS ---
  List<PhotoChantier> _photos = [];
  List<PhotoChantier> get photos => _photos;

  Future<void> fetchClients() async {
    await execute(() async {
      _clients = await _repository.getClients();
    });
  }

  Future<bool> addClient(Client client) async {
    return await executeOperation(() async {
      await _repository.createClient(client);
      await fetchClients();
    });
  }

  Future<bool> updateClient(Client client) async {
    return await executeOperation(() async {
      await _repository.updateClient(client);
      await fetchClients();
    });
  }

  Future<void> deleteClient(String id) async {
    await executeOperation(() async {
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

  // --- DASHBOARD & KPI ---

  /// Retourne les clients triés par CA généré (Factures validées)
  /// Nécessite la liste des factures pour le calcul
  List<Map<String, dynamic>> getTopClients(
      List<Client> allClients, List<dynamic> allFactures, int limit) {
    // Map<ClientId, TotalCA>
    final Map<String, Decimal> clientCA = {};

    for (var f in allFactures) {
      // On suppose que f est une Facture (ou un objet avec clientId et totalHt)
      // On check le statut si c'est une Facture
      // Pour éviter le couplage fort ici, on peut passer les factures déjà filtrées
      if (f.clientId != null) {
        final current = clientCA[f.clientId] ?? Decimal.zero;
        clientCA[f.clientId!] = current + f.totalHt;
      }
    }

    // Convertir en liste pour trier
    final List<Map<String, dynamic>> ranked = [];
    for (var c in allClients) {
      if (c.id != null && clientCA.containsKey(c.id)) {
        ranked.add({
          'client': c,
          'ca': clientCA[c.id!]!,
        });
      }
    }

    // Trier DESC
    ranked.sort((a, b) => (b['ca'] as Decimal).compareTo(a['ca'] as Decimal));

    return ranked.take(limit).toList();
  }
}
