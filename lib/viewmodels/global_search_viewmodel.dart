import '../repositories/global_search_repository.dart';
import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../core/base_viewmodel.dart';

class GlobalSearchViewModel extends BaseViewModel {
  final IGlobalSearchRepository _repository;

  GlobalSearchViewModel({IGlobalSearchRepository? repository})
      : _repository = repository ?? GlobalSearchRepository();

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

    await executeOperation(
      () async {
        final results = await _repository.searchAll(query);
        _clientsResults = results.clients;
        _facturesResults = results.factures;
        _devisResults = results.devis;
      },
      onError: _clearResults,
    );
  }

  void _clearResults() {
    _clientsResults = [];
    _facturesResults = [];
    _devisResults = [];
    notifyListeners();
  }
}
