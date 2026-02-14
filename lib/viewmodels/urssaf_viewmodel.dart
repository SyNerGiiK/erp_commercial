import 'package:flutter/foundation.dart';
import '../models/urssaf_model.dart';
import '../repositories/urssaf_repository.dart';

class UrssafViewModel extends ChangeNotifier {
  final IUrssafRepository _repository = UrssafRepository();

  UrssafConfig? _config;
  UrssafConfig? get config => _config;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();
    try {
      _config = await _repository.getConfig();
    } catch (e) {
      // En cas d'erreur fatale, on init une config vide par sécurité
      _config = UrssafConfig();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveConfig(UrssafConfig newConfig) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.saveConfig(newConfig);
      await loadConfig(); // Recharger pour confirmer
    } catch (e) {
      // Propagation de l'erreur pour la Vue (SnackBar)
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
