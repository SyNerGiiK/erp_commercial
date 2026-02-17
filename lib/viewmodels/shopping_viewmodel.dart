import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import '../models/shopping_model.dart';
import '../repositories/shopping_repository.dart';

class ShoppingViewModel extends ChangeNotifier {
  final IShoppingRepository _repository;

  ShoppingViewModel({IShoppingRepository? repository})
      : _repository = repository ?? ShoppingRepository();

  List<ShoppingItem> _items = [];
  bool _isLoading = false;

  int _loadingDepth = 0; // Compteur réentrant pour appels imbriqués

  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;

  Decimal get totalPanier =>
      _items.fold(Decimal.zero, (sum, item) => sum + item.totalLigne);

  Future<void> fetchItems() async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _items = await _repository.getItems();
    } catch (e) {
      _items = [];
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    await _executeOperation(() async {
      await _repository.addItem(item);
      await fetchItems();
    });
  }

  Future<void> deleteItem(String id) async {
    await _executeOperation(() async {
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

  Future<void> _executeOperation(Future<void> Function() operation) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
    } catch (e) {
      debugPrint("ShoppingViewModel Error: $e");
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
