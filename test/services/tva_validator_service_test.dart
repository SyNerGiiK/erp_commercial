import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:erp_commercial/services/tva_validator_service.dart';

void main() {
  group('TvaValidatorService', () {
    test('devrait retourner valide pour un numéro TVA existant', () async {
      final mockClient = http_testing.MockClient((request) async {
        expect(request.url.path, contains('/FR/vat/'));
        return http.Response(
          jsonEncode({
            'isValid': true,
            'name': 'ENTREPRISE TEST SARL',
            'address': '12 RUE DU TEST 75001 PARIS',
            'countryCode': 'FR',
            'vatNumber': '12345678901',
          }),
          200,
        );
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR12345678901');

      expect(result.isValid, isTrue);
      expect(result.name, 'ENTREPRISE TEST SARL');
      expect(result.address, '12 RUE DU TEST 75001 PARIS');
      expect(result.countryCode, 'FR');
      expect(result.vatNumber, '12345678901');
      expect(result.error, isNull);

      service.dispose();
    });

    test('devrait retourner invalide pour un numéro TVA inexistant', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response(
          jsonEncode({
            'isValid': false,
            'name': '---',
            'address': '---',
          }),
          200,
        );
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR00000000000');

      expect(result.isValid, isFalse);
      expect(result.name, isNull); // '---' doit être nettoyé
      expect(result.address, isNull);

      service.dispose();
    });

    test('devrait gérer une erreur HTTP 404', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR12345678901');

      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);

      service.dispose();
    });

    test('devrait gérer une erreur HTTP 500', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR12345678901');

      expect(result.isValid, isFalse);
      expect(result.error, contains('HTTP 500'));

      service.dispose();
    });

    test('devrait gérer une erreur réseau (timeout)', () async {
      final mockClient = http_testing.MockClient((request) async {
        throw Exception('Connection timed out');
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR12345678901');

      expect(result.isValid, isFalse);
      expect(result.error, contains('indisponible'));

      service.dispose();
    });

    test('devrait rejeter un numéro trop court', () async {
      final service = TvaValidatorService();
      final result = await service.validateVatNumber('FR1');

      expect(result.isValid, isFalse);
      expect(result.error, contains('trop court'));

      service.dispose();
    });

    test('devrait rejeter un code pays invalide', () async {
      final service = TvaValidatorService();
      final result = await service.validateVatNumber('1234567890123');

      expect(result.isValid, isFalse);
      expect(result.error, contains('Code pays invalide'));

      service.dispose();
    });

    test('devrait gérer les espaces dans le numéro', () async {
      final mockClient = http_testing.MockClient((request) async {
        // Vérifie que les espaces ont été supprimés
        expect(request.url.path, contains('12345678901'));
        return http.Response(
          jsonEncode({'isValid': true, 'name': 'TEST', 'address': '---'}),
          200,
        );
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('FR 123 456 789 01');

      expect(result.isValid, isTrue);

      service.dispose();
    });

    test('devrait accepter un numéro en minuscules', () async {
      final mockClient = http_testing.MockClient((request) async {
        expect(request.url.path, contains('/FR/vat/'));
        return http.Response(
          jsonEncode({'isValid': true, 'name': 'TEST', 'address': null}),
          200,
        );
      });

      final service = TvaValidatorService(client: mockClient);
      final result = await service.validateVatNumber('fr12345678901');

      expect(result.isValid, isTrue);
      expect(result.countryCode, 'FR');

      service.dispose();
    });
  });

  group('ViesValidationResult', () {
    test('factory error devrait créer un résultat invalide', () {
      final result = ViesValidationResult.error('Test erreur');

      expect(result.isValid, isFalse);
      expect(result.error, 'Test erreur');
      expect(result.countryCode, '');
      expect(result.vatNumber, '');
    });
  });
}
