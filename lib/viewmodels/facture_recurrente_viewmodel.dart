import '../core/base_viewmodel.dart';
import '../models/facture_recurrente_model.dart';
import '../repositories/facture_recurrente_repository.dart';

/// ViewModel pour la gestion des factures récurrentes
class FactureRecurrenteViewModel extends BaseViewModel {
  final IFactureRecurrenteRepository _repository;

  FactureRecurrenteViewModel({IFactureRecurrenteRepository? repository})
      : _repository = repository ?? FactureRecurrenteRepository();

  List<FactureRecurrente> _items = [];
  List<FactureRecurrente> get items => _items;

  List<FactureRecurrente> get actives =>
      _items.where((f) => f.estActive).toList();
  List<FactureRecurrente> get inactives =>
      _items.where((f) => !f.estActive).toList();

  /// Factures récurrentes dont la prochaine émission est passée ou aujourd'hui
  List<FactureRecurrente> get aGenerer {
    final now = DateTime.now();
    return _items.where((f) {
      if (!f.estActive) return false;
      if (f.dateFin != null && f.dateFin!.isBefore(now)) return false;
      return !f.prochaineEmission.isAfter(now);
    }).toList();
  }

  /// Nombre total de factures générées
  int get totalGeneres =>
      _items.fold(0, (sum, f) => sum + f.nbFacturesGenerees);

  Future<void> loadAll() async {
    await executeOperation(() async {
      _items = await _repository.getAll();
    });
  }

  Future<bool> create(FactureRecurrente fr) async {
    return executeOperation(() async {
      final created = await _repository.create(fr);
      _items.insert(0, created);
    });
  }

  Future<bool> update(FactureRecurrente fr) async {
    return executeOperation(() async {
      await _repository.update(fr);
      final idx = _items.indexWhere((e) => e.id == fr.id);
      if (idx >= 0) _items[idx] = fr;
    });
  }

  Future<bool> delete(String id) async {
    return executeOperation(() async {
      await _repository.delete(id);
      _items.removeWhere((e) => e.id == id);
    });
  }

  Future<bool> toggleActive(String id) async {
    final item = _items.firstWhere((e) => e.id == id);
    final newState = !item.estActive;
    return executeOperation(() async {
      await _repository.toggleActive(id, newState);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(estActive: newState);
    });
  }

  /// Calcule la prochaine date d'émission après génération
  static DateTime calculerProchaineDate(
      DateTime current, FrequenceRecurrence frequence) {
    switch (frequence) {
      case FrequenceRecurrence.hebdomadaire:
        return current.add(const Duration(days: 7));
      case FrequenceRecurrence.mensuelle:
        return DateTime(current.year, current.month + 1, current.day);
      case FrequenceRecurrence.trimestrielle:
        return DateTime(current.year, current.month + 3, current.day);
      case FrequenceRecurrence.annuelle:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }
}
