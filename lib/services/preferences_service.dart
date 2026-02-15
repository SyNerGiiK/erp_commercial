import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/config_charges_model.dart';

/// Service de gestion de la persistance des préférences utilisateur
class PreferencesService {
  static const String _keyConfigCharges = 'config_charges';

  /// Récupère la configuration des charges depuis le stockage local
  /// Retourne une configuration par défaut si aucune n'est sauvegardée
  static Future<ConfigCharges> getConfigCharges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyConfigCharges);
      if (json == null) {
        return ConfigCharges(); // Configuration par défaut
      }
      return ConfigCharges.fromMap(jsonDecode(json));
    } catch (e) {
      // En cas d'erreur, retourner la config par défaut
      return ConfigCharges();
    }
  }

  /// Sauvegarde la configuration des charges dans le stockage local
  static Future<bool> saveConfigCharges(ConfigCharges config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(config.toMap());
      return await prefs.setString(_keyConfigCharges, json);
    } catch (e) {
      return false;
    }
  }

  /// Réinitialise la configuration des charges aux valeurs par défaut
  static Future<bool> resetConfigCharges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyConfigCharges);
    } catch (e) {
      return false;
    }
  }
}
