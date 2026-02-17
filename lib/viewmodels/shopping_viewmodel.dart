import 'package:decimal/decimal.dart';
import '../models/shopping_model.dart';
import '../repositories/shopping_repository.dart';
import '../core/base_viewmodel.dart';

class ShoppingViewModel extends BaseViewModel {
  final IShoppingRepository _repository;

  ShoppingViewModel({IShoppingRepository? repository})
      : _repository = repository ?? ShoppingRepository();

  List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => _items;

  Decimal get totalPanier =>
      _items.fold(Decimal.zero, (sum, item) => sum + item.totalLigne);

  Future<void> fetchItems() async {
    await executeOperation(
      () async {
        _items = await _repository.getItems();
      },
      onError: () {
        _items = [];
      },
    );
  }

  Future<void> addItem(ShoppingItem item) async {
    await executeOperation(() async {
      await _repository.addItem(item);
      await fetchItems();
    });
  }

  Future<void> deleteItem(String id) async {
    await executeOperation(() async {
      await _repository.deleteItem(id);
      await fetchItems();
    });
  }

  Future<void> toggleCheck(ShoppingItem item) async {
    try {
      // Optimistic Update UI
      final newState = !item.estAchete;
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(estAchete: newState);
        notifyListeners();
      }

      // Appel Réseau
      await _repository.updateItem(item.copyWith(estAchete: newState));
    } catch (e) {
      // Rollback si erreur (rechargement depuis serveur)
      await fetchItems();
    }
  }
}
