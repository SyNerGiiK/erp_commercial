import 'package:decimal/decimal.dart';
import '../models/depense_model.dart';
import '../repositories/depense_repository.dart';
import '../core/base_viewmodel.dart';

class DepenseViewModel extends BaseViewModel {
  final IDepenseRepository _repository;

  DepenseViewModel({IDepenseRepository? repository})
      : _repository = repository ?? DepenseRepository();

  List<Depense> _depenses = [];

  List<Depense> get depenses => _depenses;

  Decimal get totalDepenses =>
      _depenses.fold(Decimal.zero, (sum, item) => sum + item.montant);

  Future<void> fetchDepenses() async {
    await execute(() async {
      _depenses = await _repository.getDepenses();
    });
  }

  Future<bool> addDepense(Depense depense) async {
    return await executeOperation(() async {
      await _repository.createDepense(depense);
      await fetchDepenses();
    });
  }

  Future<bool> updateDepense(Depense depense) async {
    return await executeOperation(() async {
      await _repository.updateDepense(depense);
      await fetchDepenses();
    });
  }

  Future<void> deleteDepense(String id) async {
    await executeOperation(() async {
      await _repository.deleteDepense(id);
      await fetchDepenses();
    });
  }
}
