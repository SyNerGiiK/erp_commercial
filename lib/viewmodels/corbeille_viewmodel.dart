import '../core/base_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/depense_model.dart';
import '../repositories/facture_repository.dart';
import '../repositories/devis_repository.dart';
import '../repositories/client_repository.dart';
import '../repositories/depense_repository.dart';

/// ViewModel pour la gestion de la corbeille (soft-delete)
/// Affiche les éléments supprimés et permet de les restaurer ou purger
class CorbeilleViewModel extends BaseViewModel {
  final IFactureRepository _factureRepo;
  final IDevisRepository _devisRepo;
  final IClientRepository _clientRepo;
  final IDepenseRepository _depenseRepo;

  CorbeilleViewModel({
    IFactureRepository? factureRepository,
    IDevisRepository? devisRepository,
    IClientRepository? clientRepository,
    IDepenseRepository? depenseRepository,
  })  : _factureRepo = factureRepository ?? FactureRepository(),
        _devisRepo = devisRepository ?? DevisRepository(),
        _clientRepo = clientRepository ?? ClientRepository(),
        _depenseRepo = depenseRepository ?? DepenseRepository();

  // État
  List<Facture> _deletedFactures = [];
  List<Devis> _deletedDevis = [];
  List<Client> _deletedClients = [];
  List<Depense> _deletedDepenses = [];

  // Getters
  List<Facture> get deletedFactures => _deletedFactures;
  List<Devis> get deletedDevis => _deletedDevis;
  List<Client> get deletedClients => _deletedClients;
  List<Depense> get deletedDepenses => _deletedDepenses;

  /// Nombre total d'éléments dans la corbeille
  int get totalItems =>
      _deletedFactures.length +
      _deletedDevis.length +
      _deletedClients.length +
      _deletedDepenses.length;

  /// Indique si la corbeille est vide
  bool get isEmpty => totalItems == 0;

  /// Charge tous les éléments supprimés
  Future<void> fetchAll() async {
    await execute(() async {
      final results = await Future.wait([
        _factureRepo.getDeletedFactures(),
        _devisRepo.getDeletedDevis(),
        _clientRepo.getDeletedClients(),
        _depenseRepo.getDeletedDepenses(),
      ]);

      _deletedFactures = results[0] as List<Facture>;
      _deletedDevis = results[1] as List<Devis>;
      _deletedClients = results[2] as List<Client>;
      _deletedDepenses = results[3] as List<Depense>;
    });
  }

  // --- RESTAURATION ---

  /// Restaure une facture depuis la corbeille
  Future<bool> restoreFacture(String id) async {
    return await executeOperation(() async {
      await _factureRepo.restoreFacture(id);
      _deletedFactures.removeWhere((f) => f.id == id);
    });
  }

  /// Restaure un devis depuis la corbeille
  Future<bool> restoreDevis(String id) async {
    return await executeOperation(() async {
      await _devisRepo.restoreDevis(id);
      _deletedDevis.removeWhere((d) => d.id == id);
    });
  }

  /// Restaure un client depuis la corbeille
  Future<bool> restoreClient(String id) async {
    return await executeOperation(() async {
      await _clientRepo.restoreClient(id);
      _deletedClients.removeWhere((c) => c.id == id);
    });
  }

  /// Restaure une dépense depuis la corbeille
  Future<bool> restoreDepense(String id) async {
    return await executeOperation(() async {
      await _depenseRepo.restoreDepense(id);
      _deletedDepenses.removeWhere((d) => d.id == id);
    });
  }

  // --- PURGE (Suppression définitive) ---

  /// Supprime définitivement une facture
  Future<bool> purgeFacture(String id) async {
    return await executeOperation(() async {
      await _factureRepo.purgeFacture(id);
      _deletedFactures.removeWhere((f) => f.id == id);
    });
  }

  /// Supprime définitivement un devis
  Future<bool> purgeDevis(String id) async {
    return await executeOperation(() async {
      await _devisRepo.purgeDevis(id);
      _deletedDevis.removeWhere((d) => d.id == id);
    });
  }

  /// Supprime définitivement un client
  Future<bool> purgeClient(String id) async {
    return await executeOperation(() async {
      await _clientRepo.purgeClient(id);
      _deletedClients.removeWhere((c) => c.id == id);
    });
  }

  /// Supprime définitivement une dépense
  Future<bool> purgeDepense(String id) async {
    return await executeOperation(() async {
      await _depenseRepo.purgeDepense(id);
      _deletedDepenses.removeWhere((d) => d.id == id);
    });
  }

  /// Vide entièrement la corbeille (purge tout)
  Future<bool> purgeAll() async {
    return await executeOperation(() async {
      // Purge en parallèle par type
      await Future.wait([
        ...(_deletedFactures.map((f) => _factureRepo.purgeFacture(f.id!))),
        ...(_deletedDevis.map((d) => _devisRepo.purgeDevis(d.id!))),
        ...(_deletedClients.map((c) => _clientRepo.purgeClient(c.id!))),
        ...(_deletedDepenses.map((d) => _depenseRepo.purgeDepense(d.id!))),
      ]);

      _deletedFactures = [];
      _deletedDevis = [];
      _deletedClients = [];
      _deletedDepenses = [];
    });
  }
}
