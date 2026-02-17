import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../repositories/entreprise_repository.dart';

class EntrepriseViewModel extends ChangeNotifier {
  final IEntrepriseRepository _repository;

  EntrepriseViewModel({IEntrepriseRepository? repository})
      : _repository = repository ?? EntrepriseRepository();

  ProfilEntreprise? _profil;
  bool _isLoading = false;
  int _loadingDepth = 0; // Compteur pour gérer les appels imbriqués

  ProfilEntreprise? get profil => _profil;
  bool get isLoading => _isLoading;

  /// Récupère le profil entreprise
  Future<void> fetchProfil() async {
    await _executeOperation(() async {
      _profil = await _repository.getProfil();
    });
  }

  /// Sauvegarde (Insert ou Update)
  Future<bool> saveProfil(ProfilEntreprise profil) async {
    return await _executeOperation(() async {
      await _repository.saveProfil(profil);
      await fetchProfil();
    });
  }

  /// Upload Logo ou Signature
  Future<bool> uploadImage(XFile file, String type) async {
    if (_profil == null) return false;

    return await _executeOperation(() async {
      final url = await _repository.uploadImage(file, type);

      // Mise à jour locale du profil avec la nouvelle URL
      ProfilEntreprise newProfil;
      if (type == 'logo') {
        newProfil = _profil!.copyWith(logoUrl: url);
      } else {
        newProfil = _profil!.copyWith(signatureUrl: url);
      }

      // Sauvegarde immédiate en base
      await _repository.saveProfil(newProfil);
      await fetchProfil();
    });
  }

  /// Upload Signature depuis Canvas (Bytes)
  Future<bool> uploadSignatureBytes(Uint8List bytes) async {
    if (_profil == null) return false;

    return await _executeOperation(() async {
      final url = await _repository.uploadSignatureBytes(bytes);

      // MAJ Locale
      final newProfil = _profil!.copyWith(signatureUrl: url);

      // Sauvegarde
      await _repository.saveProfil(newProfil);
      await fetchProfil();
    });
  }

  /// Suggère les mentions légales obligatoires selon le type d'entreprise
  String getLegalMentionsSuggestion(TypeEntreprise type) {
    if (type.isMicroEntrepreneur) {
      return "TVA non applicable, art. 293 B du CGI.\n"
          "Dispensé d'immatriculation au registre du commerce et des sociétés (RCS) et au répertoire des métiers (RM).";
    }
    return "";
  }

  /// Indique si la TVA est applicable pour cette entreprise
  // Si Micro-Entrepreneur -> Pas de TVA (Franchise en base)
  bool get isTvaApplicable {
    if (_profil == null) return false;
    return _profil!.tvaApplicable;
  }

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    _loadingDepth++;

    if (_loadingDepth == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await operation();
      return true;
    } catch (e) {
      debugPrint("🔴 EntrepriseViewModel Error: $e");
      return false;
    } finally {
      _loadingDepth--;

      if (_loadingDepth == 0) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
