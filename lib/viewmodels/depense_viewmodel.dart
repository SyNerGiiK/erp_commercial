import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import '../models/depense_model.dart';
import '../repositories/depense_repository.dart';

class DepenseViewModel extends ChangeNotifier {
  final IDepenseRepository _repository;

  DepenseViewModel({IDepenseRepository? repository})
      : _repository = repository ?? DepenseRepository();

  List<Depense> _depenses = [];
  bool _isLoading = false;
  int _loadingDepth = 0; // Compteur pour gérer les appels imbriqués

  List<Depense> get depenses => _depenses;
  bool get isLoading => _isLoading;

  Decimal get totalDepenses =>
      _depenses.fold(Decimal.zero, (sum, item) => sum + item.montant);

  Future<void> fetchDepenses() async {
    await _executeOperation(() async {
      _depenses = await _repository.getDepenses();
    });
  }

  Future<bool> addDepense(Depense depense) async {
    return await _executeOperation(() async {
      await _repository.createDepense(depense);
      await fetchDepenses();
    });
  }

  Future<bool> updateDepense(Depense depense) async {
    return await _executeOperation(() async {
      await _repository.updateDepense(depense);
      await fetchDepenses();
    });
  }

  Future<void> deleteDepense(String id) async {
    await _executeOperation(() async {
      await _repository.deleteDepense(id);
      await fetchDepenses();
    });
  }

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("🔴 DepenseViewModel Error: $e");
      }
      return false;
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
