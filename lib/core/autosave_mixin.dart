import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

/// Mixin pour l'auto-save des brouillons
/// Utilisé par DevisViewModel et FactureViewModel
mixin AutoSaveMixin on ChangeNotifier {
  Timer? _saveDebounce;
  bool _isRestoringDraft = false;

  bool get isRestoringDraft => _isRestoringDraft;

  /// Vérifie s'il existe un brouillon local pour ce document
  ///
  /// [documentType] : 'devis' ou 'facture'
  /// [id] : ID du document (null pour nouveau)
  Future<Map<String, dynamic>?> checkLocalDraft(
    String documentType,
    String? id,
  ) async {
    _isRestoringDraft = true;
    Future.microtask(() => notifyListeners());

    final key = LocalStorageService.generateKey(documentType, id);
    final data = await LocalStorageService.getDraft(key);

    _isRestoringDraft = false;
    notifyListeners();
    return data;
  }

  /// Sauvegarde automatique du brouillon avec debounce (2s)
  ///
  /// [documentType] : 'devis' ou 'facture'
  /// [id] : ID du document (null pour nouveau)
  /// [data] : Données à sauvegarder
  void autoSaveDraft(
    String documentType,
    String? id,
    Map<String, dynamic> data,
  ) {
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();

    _saveDebounce = Timer(const Duration(seconds: 2), () async {
      final key = LocalStorageService.generateKey(documentType, id);
      await LocalStorageService.saveDraft(key, data);
      developer.log("💾 Auto-saved draft: $key");
    });
  }

  /// Nettoie le brouillon local (après validation/suppression)
  ///
  /// [documentType] : 'devis' ou 'facture'
  /// [id] : ID du document (null pour nouveau)
  Future<void> clearLocalDraft(String documentType, String? id) async {
    _saveDebounce?.cancel();
    final key = LocalStorageService.generateKey(documentType, id);
    await LocalStorageService.clearDraft(key);
    developer.log("🗑️ Cleared draft: $key");
  }

  /// Dispose du timer (appeler dans @override dispose())
  void disposeAutoSave() {
    _saveDebounce?.cancel();
  }
}
