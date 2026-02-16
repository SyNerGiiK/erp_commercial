import 'package:flutter/foundation.dart';

class EditorStateProvider extends ChangeNotifier {
  dynamic _minimizedDraft;
  String? _draftType; // 'devis' ou 'facture'
  String? _originalId; // ID original si mode édition, null si création

  // Extra data preservation
  String? _sourceDevisId; // Pour transformation facture

  bool get hasDraft => _minimizedDraft != null;
  String? get draftType => _draftType;

  void minimize({
    required dynamic draft,
    required String type,
    String? id,
    String? sourceDevisId,
  }) {
    _minimizedDraft = draft;
    _draftType = type;
    _originalId = id;
    _sourceDevisId = sourceDevisId;
    notifyListeners();
  }

  /// Retourne les données pour la restauration
  Map<String, dynamic>? restore() {
    if (!hasDraft) return null;

    final data = {
      'draft': _minimizedDraft,
      'type': _draftType,
      'id': _originalId,
      'sourceDevisId': _sourceDevisId,
    };

    // On ne clear pas ici, mais au moment où l'utilisateur confirme ou annule
    // Ou on clear et on relance l'éditeur.
    _minimizedDraft = null;
    _draftType = null;
    _originalId = null;
    _sourceDevisId = null;
    notifyListeners();

    return data;
  }

  void clear() {
    _minimizedDraft = null;
    _draftType = null;
    _originalId = null;
    _sourceDevisId = null;
    notifyListeners();
  }
}
