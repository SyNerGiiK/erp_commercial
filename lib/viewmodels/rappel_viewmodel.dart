import '../core/base_viewmodel.dart';
import '../models/rappel_model.dart';
import '../repositories/rappel_repository.dart';

/// ViewModel pour la gestion des rappels et échéances
class RappelViewModel extends BaseViewModel {
  final IRappelRepository _repository;

  RappelViewModel({IRappelRepository? repository})
      : _repository = repository ?? RappelRepository();

  List<Rappel> _items = [];
  List<Rappel> get items => _items;

  /// Rappels non complétés
  List<Rappel> get actifs => _items.where((r) => !r.estComplete).toList();

  /// Rappels en retard
  List<Rappel> get enRetard => _items.where((r) => r.estEnRetard).toList();

  /// Rappels proches (< 7 jours)
  List<Rappel> get proches => _items.where((r) => r.estProche).toList();

  /// Rappels complétés
  List<Rappel> get completes => _items.where((r) => r.estComplete).toList();

  /// Nombre total de rappels urgents (en retard + proches)
  int get nbUrgents => enRetard.length + proches.length;

  /// Rappels par type
  Map<TypeRappel, List<Rappel>> get parType {
    final map = <TypeRappel, List<Rappel>>{};
    for (final r in actifs) {
      map.putIfAbsent(r.typeRappel, () => []).add(r);
    }
    return map;
  }

  Future<void> loadAll() async {
    await executeOperation(() async {
      _items = await _repository.getAll();
    });
  }

  Future<void> loadActifs() async {
    await executeOperation(() async {
      _items = await _repository.getActifs();
    });
  }

  Future<bool> create(Rappel rappel) async {
    return executeOperation(() async {
      await _repository.create(rappel);
      _items = await _repository.getAll();
    });
  }

  Future<bool> update(Rappel rappel) async {
    return executeOperation(() async {
      await _repository.update(rappel);
      final idx = _items.indexWhere((e) => e.id == rappel.id);
      if (idx >= 0) _items[idx] = rappel;
    });
  }

  Future<bool> delete(String id) async {
    return executeOperation(() async {
      await _repository.delete(id);
      _items.removeWhere((e) => e.id == id);
    });
  }

  Future<bool> completer(String id) async {
    return executeOperation(() async {
      await _repository.completer(id);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(estComplete: true);
    });
  }

  Future<bool> decompleter(String id) async {
    return executeOperation(() async {
      await _repository.decompleter(id);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(estComplete: false);
    });
  }
}
