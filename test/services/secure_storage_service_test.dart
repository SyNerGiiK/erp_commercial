import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/services/secure_storage_service.dart';

/// Tests unitaires pour SecureStorageService.
///
/// Note : flutter_secure_storage utilise des API natives (Keychain, EncryptedSharedPreferences)
/// qui ne sont pas disponibles en environnement de test unitaire pur.
/// Ces tests vérifient la structure et les constantes du service.
/// Les tests d'intégration complets doivent être exécutés sur un appareil/émulateur.
void main() {
  group('SecureStorageService - constantes', () {
    test('devrait avoir les clés prédéfinies correctes', () {
      expect(SecureStorageService.keyAuthToken, contains('auth_token'));
      expect(SecureStorageService.keyRefreshToken, contains('refresh_token'));
      expect(SecureStorageService.keyIban, contains('iban'));
      expect(SecureStorageService.keyApiKeys, contains('api_keys'));
      expect(SecureStorageService.keyConfigCharges, contains('config_charges'));
    });

    test('toutes les clés devrait avoir le même préfixe', () {
      const prefix = 'artisan_secure_';
      expect(SecureStorageService.keyAuthToken, startsWith(prefix));
      expect(SecureStorageService.keyRefreshToken, startsWith(prefix));
      expect(SecureStorageService.keyIban, startsWith(prefix));
      expect(SecureStorageService.keyApiKeys, startsWith(prefix));
      expect(SecureStorageService.keyConfigCharges, startsWith(prefix));
    });

    test('les clés doivent être uniques', () {
      final keys = {
        SecureStorageService.keyAuthToken,
        SecureStorageService.keyRefreshToken,
        SecureStorageService.keyIban,
        SecureStorageService.keyApiKeys,
        SecureStorageService.keyConfigCharges,
      };
      expect(keys.length, 5, reason: 'Toutes les clés doivent être uniques');
    });
  });
}
