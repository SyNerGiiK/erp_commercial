import 'dart:convert';
import '../models/config_charges_model.dart';
import 'secure_storage_service.dart';

/// Service de gestion de la persistance des préférences utilisateur.
///
/// Utilise SecureStorageService (chiffrement hardware-backed) pour les données
/// de configuration financière (charges sociales, taux, etc.)
class PreferencesService {
  /// Récupère la configuration des charges depuis le stockage sécurisé
  /// Retourne une configuration par défaut si aucune n'est sauvegardée
  static Future<ConfigCharges> getConfigCharges() async {
    try {
      final jsonMap = await SecureStorageService.readJson(
          SecureStorageService.keyConfigCharges);
      if (jsonMap == null) {
        return ConfigCharges(); // Configuration par défaut
      }
      return ConfigCharges.fromMap(jsonMap);
    } catch (e) {
      // En cas d'erreur, retourner la config par défaut
      return ConfigCharges();
    }
  }

  /// Sauvegarde la configuration des charges dans le stockage sécurisé
  static Future<bool> saveConfigCharges(ConfigCharges config) async {
    try {
      return await SecureStorageService.writeJson(
        SecureStorageService.keyConfigCharges,
        config.toMap(),
      );
    } catch (e) {
      return false;
    }
  }

  /// Réinitialise la configuration des charges aux valeurs par défaut
  static Future<bool> resetConfigCharges() async {
    try {
      return await SecureStorageService.delete(
          SecureStorageService.keyConfigCharges);
    } catch (e) {
      return false;
    }
  }
}
