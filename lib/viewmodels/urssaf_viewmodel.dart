import 'package:flutter/foundation.dart';
import '../models/urssaf_model.dart';
import '../repositories/urssaf_repository.dart';
import '../config/supabase_config.dart';

class UrssafViewModel extends ChangeNotifier {
  final IUrssafRepository _repository;

  UrssafViewModel({IUrssafRepository? repository})
      : _repository = repository ?? UrssafRepository();

  UrssafConfig? _config;
  UrssafConfig? get config => _config;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _loadingDepth = 0; // Compteur pour gérer les appels imbriqués

  Future<void> loadConfig() async {
    await _executeOperation(() async {
      _config = await _repository.getConfig();
    }, onError: () {
      // En cas d'erreur fatale, on init une config vide par sécurité
      _config = UrssafConfig(
        userId: '', // Empty userId en cas d'erreur
        id: '',
      );
    });
  }

  Future<void> saveConfig(UrssafConfig newConfig) async {
    await _executeOperation(() async {
      await _repository.saveConfig(newConfig);
      await loadConfig(); // Recharger pour confirmer
    }, shouldRethrow: true);
  }

  Future<void> _executeOperation(
    Future<void> Function() operation, {
    Function()? onError,
    bool shouldRethrow = false,
  }) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
    } catch (e) {
      if (onError != null) {
        onError();
      }
      if (shouldRethrow) {
        rethrow;
      }
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
