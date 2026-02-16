import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _prefix = 'artisan_draft_';

  /// Sauvegarde un brouillon (JSON)
  static Future<void> saveDraft(String key, Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    final String fullKey = '$_prefix$key';
    await prefs.setString(fullKey, jsonEncode(json));
  }

  /// Récupère un brouillon
  static Future<Map<String, dynamic>?> getDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String fullKey = '$_prefix$key';
    final String? data = prefs.getString(fullKey);

    if (data == null) return null;

    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      // En cas de corruption, on supprime
      await prefs.remove(fullKey);
      return null;
    }
  }

  /// Supprime un brouillon
  static Future<void> clearDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String fullKey = '$_prefix$key';
    await prefs.remove(fullKey);
  }

  /// Helper pour générer la clé
  static String generateKey(String type, String? id) {
    if (id == null) {
      return '${type}_new';
    } else {
      return '${type}_$id';
    }
  }
}
