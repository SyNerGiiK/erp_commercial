import 'package:flutter/foundation.dart';
import '../repositories/planning_repository.dart';
import '../models/planning_model.dart';
import '../models/facture_model.dart'; // Import nécessaire
import '../models/devis_model.dart'; // Import nécessaire

class PlanningViewModel extends ChangeNotifier {
  final IPlanningRepository _repository = PlanningRepository();

  final List<PlanningEvent> _allEvents = [];
  List<PlanningEvent> _filteredEvents = [];

  List<PlanningEvent> get events => _filteredEvents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  // MÉTHODE AJOUTÉE (CORRECTION ERREUR)
  Future<void> fetchEvents(List<Facture> factures, List<Devis> devis) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allEvents.clear();

      // 1. Récupération des événements manuels depuis la base
      final manualEvents = await _repository.getManualEvents();
      _allEvents.addAll(manualEvents);

      // 2. Génération des événements depuis les Factures (Échéances)
      for (var f in factures) {
        if (f.statut != 'payee' &&
            f.statut != 'brouillon' &&
            f.dateEcheance != null) {
          _allEvents.add(PlanningEvent(
            id: f.id,
            titre: "Échéance Fac. ${f.numeroFacture}",
            dateDebut: f.dateEcheance!,
            dateFin: f.dateEcheance!,
            type: 'facture_echeance',
            isManual: false,
            clientId: f.clientId,
            description: "Montant: ${f.totalHt} € HT",
          ));
        }
      }

      // 3. Génération des événements depuis les Devis (Validité)
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

      _applyFilters();
    } catch (e) {
      debugPrint("Erreur PlanningVM fetchEvents: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      await _repository.addEvent(event);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      _allEvents.removeWhere((e) => e.id == id);
      _applyFilters();
    } catch (e) {
      debugPrint("Erreur deleteEvent: $e");
    }
  }
}
