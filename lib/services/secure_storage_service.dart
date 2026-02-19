import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé avec chiffrement hardware-backed.
///
/// Remplace SharedPreferences pour toute donnée sensible :
/// - Tokens d'authentification
/// - Clés cryptographiques
/// - IBAN, données bancaires
/// - Configurations confidentielles locales
///
/// Utilise flutter_secure_storage (Keychain iOS, EncryptedSharedPreferences Android,
/// libsecret Linux, Windows Credential API).
class SecureStorageService {
  static const String _prefix = 'artisan_secure_';

  // Clés prédéfinies pour les données sensibles
  static const String keyAuthToken = '${_prefix}auth_token';
  static const String keyRefreshToken = '${_prefix}refresh_token';
  static const String keyIban = '${_prefix}iban';
  static const String keyApiKeys = '${_prefix}api_keys';
  static const String keyConfigCharges = '${_prefix}config_charges';

  /// Options de sécurité renforcées
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    wOptions: WindowsOptions(),
    lOptions: LinuxOptions(),
  );

  // --- OPÉRATIONS GÉNÉRIQUES ---

  /// Écrit une valeur chiffrée
  static Future<bool> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      developer.log('❌ SecureStorage write error ($key): $e');
      return false;
    }
  }

  /// Lit une valeur chiffrée
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      developer.log('❌ SecureStorage read error ($key): $e');
      return null;
    }
  }

  /// Supprime une valeur
  static Future<bool> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      developer.log('❌ SecureStorage delete error ($key): $e');
      return false;
    }
  }

  /// Vérifie si une clé existe
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      developer.log('❌ SecureStorage containsKey error ($key): $e');
      return false;
    }
  }

  /// Supprime toutes les données sécurisées (déconnexion)
  static Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      developer.log('❌ SecureStorage deleteAll error: $e');
      return false;
    }
  }

  // --- OPÉRATIONS JSON (pour objets complexes) ---

  /// Écrit un objet JSON chiffré
  static Future<bool> writeJson(String key, Map<String, dynamic> json) async {
    try {
      final encoded = jsonEncode(json);
      return await write(key, encoded);
    } catch (e) {
      developer.log('❌ SecureStorage writeJson error ($key): $e');
      return false;
    }
  }

  /// Lit un objet JSON chiffré
  static Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      final data = await read(key);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      developer.log('❌ SecureStorage readJson error ($key): $e');
      // En cas de corruption, on supprime
      await delete(key);
      return null;
    }
  }

  // --- OPÉRATIONS MÉTIER SPÉCIFIQUES ---

  /// Sauvegarde l'IBAN de l'entreprise (donnée bancaire sensible)
  static Future<bool> saveIban(String iban) async {
    return await write(keyIban, iban);
  }

  /// Récupère l'IBAN chiffré
  static Future<String?> getIban() async {
    return await read(keyIban);
  }

  /// Sauvegarde un token d'authentification
  static Future<bool> saveAuthToken(String token) async {
    return await write(keyAuthToken, token);
  }

  /// Récupère le token d'authentification
  static Future<String?> getAuthToken() async {
    return await read(keyAuthToken);
  }

  /// Sauvegarde le refresh token
  static Future<bool> saveRefreshToken(String token) async {
    return await write(keyRefreshToken, token);
  }

  /// Récupère le refresh token
  static Future<String?> getRefreshToken() async {
    return await read(keyRefreshToken);
  }

  /// Efface tous les tokens (déconnexion)
  static Future<void> clearAuthData() async {
    await delete(keyAuthToken);
    await delete(keyRefreshToken);
  }
}
