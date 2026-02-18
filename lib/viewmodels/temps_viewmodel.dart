import 'package:decimal/decimal.dart';

import '../core/base_viewmodel.dart';
import '../models/temps_activite_model.dart';
import '../repositories/temps_repository.dart';

/// ViewModel pour le suivi du temps d'activité
class TempsViewModel extends BaseViewModel {
  final ITempsRepository _repository;

  TempsViewModel({ITempsRepository? repository})
      : _repository = repository ?? TempsRepository();

  List<TempsActivite> _items = [];
  List<TempsActivite> get items => _items;

  /// Entrées facturables non encore facturées
  List<TempsActivite> get nonFactures =>
      _items.where((t) => t.estFacturable && !t.estFacture).toList();

  /// Total minutes du mois en cours
  int get totalMinutesMois {
    final now = DateTime.now();
    return _items
        .where((t) =>
            t.dateActivite.year == now.year &&
            t.dateActivite.month == now.month)
        .fold(0, (sum, t) => sum + t.dureeMinutes);
  }

  /// Total heures formaté du mois en cours
  String get totalHeuresMoisFormate {
    final total = totalMinutesMois;
    final h = total ~/ 60;
    final m = total % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  /// CA potentiel (temps facturable non facturé)
  Decimal get caPotentiel {
    return nonFactures.fold(Decimal.zero, (sum, t) => sum + t.montant);
  }

  /// Temps groupé par client
  Map<String?, List<TempsActivite>> get parClient {
    final map = <String?, List<TempsActivite>>{};
    for (final t in _items) {
      map.putIfAbsent(t.clientId, () => []).add(t);
    }
    return map;
  }

  /// Temps groupé par projet
  Map<String, List<TempsActivite>> get parProjet {
    final map = <String, List<TempsActivite>>{};
    for (final t in _items) {
      final key = t.projet.isEmpty ? 'Sans projet' : t.projet;
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  Future<void> loadAll() async {
    await executeOperation(() async {
      _items = await _repository.getAll();
    });
  }

  Future<void> loadByClient(String clientId) async {
    await executeOperation(() async {
      _items = await _repository.getByClient(clientId);
    });
  }

  Future<void> loadByPeriode(DateTime debut, DateTime fin) async {
    await executeOperation(() async {
      _items = await _repository.getByPeriode(debut, fin);
    });
  }

  Future<bool> create(TempsActivite temps) async {
    return executeOperation(() async {
      await _repository.create(temps);
      _items = await _repository.getAll();
    });
  }

  Future<bool> update(TempsActivite temps) async {
    return executeOperation(() async {
      await _repository.update(temps);
      final idx = _items.indexWhere((e) => e.id == temps.id);
      if (idx >= 0) _items[idx] = temps;
    });
  }

  Future<bool> delete(String id) async {
    return executeOperation(() async {
      await _repository.delete(id);
      _items.removeWhere((e) => e.id == id);
    });
  }

  Future<bool> marquerFacture(List<String> ids, String factureId) async {
    return executeOperation(() async {
      await _repository.marquerFacture(ids, factureId);
      for (final id in ids) {
        final idx = _items.indexWhere((e) => e.id == id);
        if (idx >= 0) {
          _items[idx] = _items[idx].copyWith(
            estFacture: true,
            factureId: factureId,
          );
        }
      }
    });
  }
}
