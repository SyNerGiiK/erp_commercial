import 'package:decimal/decimal.dart';
import '../core/base_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../services/relance_service.dart';
import '../services/email_service.dart';
import '../repositories/facture_repository.dart';
import '../repositories/client_repository.dart';

/// ViewModel pour l'écran des relances
class RelanceViewModel extends BaseViewModel {
  final IFactureRepository _factureRepo;
  final IClientRepository _clientRepo;

  RelanceViewModel({
    IFactureRepository? factureRepo,
    IClientRepository? clientRepo,
  })  : _factureRepo = factureRepo ?? FactureRepository(),
        _clientRepo = clientRepo ?? ClientRepository();

  List<RelanceInfo> _relances = [];
  List<RelanceInfo> get relances => _relances;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  NiveauRelance? _filtreNiveau;
  NiveauRelance? get filtreNiveau => _filtreNiveau;

  ProfilEntreprise? _profil;

  void setProfil(ProfilEntreprise? profil) => _profil = profil;

  /// Charge toutes les relances
  Future<void> chargerRelances() async {
    await execute(() async {
      final factures = await _factureRepo.getFactures();
      final clients = await _clientRepo.getClients();

      _relances = RelanceService.analyserRelances(factures, clients: clients);
      _stats = RelanceService.getStatistiquesRelances(_relances);
    });
  }

  /// Filtre par niveau de relance
  void filtrerParNiveau(NiveauRelance? niveau) {
    _filtreNiveau = niveau;
    notifyListeners();
  }

  /// Relances filtrées selon le niveau sélectionné
  List<RelanceInfo> get relancesFiltrees {
    if (_filtreNiveau == null) return _relances;
    return _relances.where((r) => r.niveau == _filtreNiveau).toList();
  }

  /// Nombre total de relances
  int get totalRelances => _relances.length;

  /// Montant total impayé
  Decimal get montantTotalImpaye {
    final mt = _stats['montantTotal'];
    return (mt is Decimal) ? mt : Decimal.zero;
  }

  /// Retard moyen en jours
  double get retardMoyen {
    final rm = _stats['retardMoyen'];
    return (rm is double) ? rm : 0.0;
  }

  /// Envoyer une relance par email
  Future<EmailResult> envoyerRelance(RelanceInfo relance) async {
    return await EmailService.envoyerRelance(
      relance: relance,
      profil: _profil,
    );
  }
}
