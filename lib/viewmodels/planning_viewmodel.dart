import 'dart:developer' as developer;
import '../repositories/planning_repository.dart';
import '../models/planning_model.dart';
import '../core/base_viewmodel.dart';

class PlanningViewModel extends BaseViewModel {
  final IPlanningRepository _repository;

  PlanningViewModel({IPlanningRepository? repository})
      : _repository = repository ?? PlanningRepository();

  final List<PlanningEvent> _allEvents = [];
  List<PlanningEvent> _filteredEvents = [];

  List<PlanningEvent> get events => _filteredEvents;

  // Filtres
  bool _showChantiers = true;
  bool _showRdv = true;
  bool _showFactures = true;
  bool _showDevis = true;

  bool get showChantiers => _showChantiers;
  bool get showRdv => _showRdv;
  bool get showFactures => _showFactures;
  bool get showDevis => _showDevis;

  // --- ACTIONS ---

  void toggleFilter(String filterType) {
    switch (filterType) {
      case 'chantier':
        _showChantiers = !_showChantiers;
        break;
      case 'rdv':
        _showRdv = !_showRdv;
        break;
      case 'facture':
        _showFactures = !_showFactures;
        break;
      case 'devis':
        _showDevis = !_showDevis;
        break;
    }
    _applyFilters();
  }

  Future<void> fetchEvents(dynamic factures, dynamic devis) async {
    await executeOperation(() async {
      _allEvents.clear();

      // 1. Manuels (DB)
      final manualEvents = await _repository.getManualEvents();
      _allEvents.addAll(manualEvents);

      // 2. Factures (Echéances)
      // On suppose que "factures" est une List<Facture>
      if (factures is List) {
        for (var f in factures) {
          if (f.statut == 'envoyee' || f.statut == 'partielle') {
            // dateEcheance est non-nullable dans le modèle, pas besoin de check
            _allEvents.add(PlanningEvent(
              id: f.id,
              titre: "Échéance Facture ${f.numeroFacture}",
              dateDebut: f.dateEcheance,
              dateFin: f.dateEcheance,
              type: 'facture_echeance',
              isManual: false,
              clientId: f.clientId,
            ));
          }
        }
      }

      // 3. Devis (Validité)
      // On suppose que "devis" est une List<Devis>
      if (devis is List) {
        for (var d in devis) {
          if (d.statut == 'envoye') {
            _allEvents.add(PlanningEvent(
              id: d.id,
              titre: "Exp. Devis ${d.numeroDevis}",
              dateDebut: d.dateValidite,
              dateFin: d.dateValidite,
              type: 'devis_fin',
              isManual: false,
              clientId: d.clientId,
            ));
          }
        }
      }

      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredEvents = _allEvents.where((e) {
      if (e.type == 'chantier' && !_showChantiers) return false;
      if (e.type == 'rdv' && !_showRdv) return false;
      if (e.type == 'facture_echeance' && !_showFactures) return false;
      if (e.type == 'devis_fin' && !_showDevis) return false;
      return true;
    }).toList();

    _filteredEvents.sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
    notifyListeners();
  }

  // --- CRUD (Manuels uniquement) ---

  Future<bool> addEvent(PlanningEvent event) async {
    try {
      // Pour un ajout, on s'assure que l'ID est null (géré par Supabase)
      await _repository.addEvent(event.copyWith(id: null));
      // On ne refetch pas tout, on demande à la vue de rafraîchir
      return true;
    } catch (e) {
      developer.log("Erreur addEvent: $e");
      return false;
    }
  }

  Future<bool> updateEvent(PlanningEvent event) async {
    if (event.id == null) return false; // ID requis pour update
    try {
      await _repository.updateEvent(event);
      return true;
    } catch (e) {
      developer.log("Erreur updateEvent: $e");
      return false;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
    } catch (e) {
      developer.log("Erreur deleteEvent: $e");
    }
  }
}
