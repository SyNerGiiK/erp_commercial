import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Classe de base pour tous les ViewModels
/// Fournit la gestion standardisée du loading state avec pattern réentrant
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  int _loadingDepth = 0; // Compteur réentrant pour appels imbriqués

  bool get isLoading => _isLoading;

  /// Exécute une opération async avec gestion automatique du loading state
  ///
  /// Le pattern `_loadingDepth` permet de gérer les appels async imbriqués :
  /// - isLoading = true seulement au premier appel (depth 0 → 1)
  /// - isLoading = false seulement quand tous les appels sont terminés (depth n → 0)
  ///
  /// [operation] : L'opération async à exécuter
  /// [onError] : Callback optionnel exécuté en cas d'erreur
  /// [logPrefix] : Préfixe pour les logs d'erreur (par défaut: nom de classe)
  ///
  /// Retourne `true` si succès, `false` si erreur
  Future<bool> executeOperation(
    Future<void> Function() operation, {
    VoidCallback? onError,
    String? logPrefix,
  }) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
      return true;
    } catch (e, stackTrace) {
      final prefix = logPrefix ?? runtimeType.toString();
      developer.log(
        "🔴 $prefix Error",
        error: e,
        stackTrace: stackTrace,
      );
      onError?.call();
      return false;
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Helper pour exécuter une opération sans retour de succès/échec
  /// Pratique pour les fetch simples
  Future<void> execute(Future<void> Function() operation) async {
    await executeOperation(operation);
  }
}
