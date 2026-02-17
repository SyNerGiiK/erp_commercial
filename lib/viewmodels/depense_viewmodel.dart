import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import '../models/depense_model.dart';
import '../repositories/depense_repository.dart';

class DepenseViewModel extends ChangeNotifier {
  final IDepenseRepository _repository = DepenseRepository();

  List<Depense> _depenses = [];
  bool _isLoading = false;

  List<Depense> get depenses => _depenses;
  bool get isLoading => _isLoading;

  Decimal get totalDepenses =>
      _depenses.fold(Decimal.zero, (sum, item) => sum + item.montant);

  Future<void> fetchDepenses() async {
    if (_isLoading) return;
    _isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      _depenses = await _repository.getDepenses();
    } catch (e) {
      _depenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    try {
      await operation();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("🔴 DepenseViewModel Error: $e");
      }
      return false;
    }
  }
}
