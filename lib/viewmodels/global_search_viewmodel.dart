import 'package:flutter/foundation.dart';
import '../repositories/global_search_repository.dart';
import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';

class GlobalSearchViewModel extends ChangeNotifier {
  final IGlobalSearchRepository _repository;

  GlobalSearchViewModel({IGlobalSearchRepository? repository})
      : _repository = repository ?? GlobalSearchRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _loadingDepth = 0; // Compteur réentrant pour appels imbriqués

  List<Client> _clientsResults = [];
  List<Facture> _facturesResults = [];
  List<Devis> _devisResults = [];

  List<Client> get clientsResults => _clientsResults;
  List<Facture> get facturesResults => _facturesResults;
  List<Devis> get devisResults => _devisResults;

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      _clearResults();
      return;
    }

    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final results = await _repository.searchAll(query);
      _clientsResults = results.clients;
      _facturesResults = results.factures;
      _devisResults = results.devis;
    } catch (e) {
      _clearResults();
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _clearResults() {
    _clientsResults = [];
    _facturesResults = [];
    _devisResults = [];
    notifyListeners();
  }
}
