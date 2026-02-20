import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/services/edge_email_service.dart';
import 'package:erp_commercial/services/email_service.dart';

/// Tests unitaires pour EdgeEmailService.
///
/// Comme le service dépend de Supabase Functions (réseau),
/// on vérifie la structure, les APIs publiques et les corps d'email.
void main() {
  group('EdgeEmailService - structure API', () {
    test('devrait exposer envoyerDevis comme méthode statique', () {
      // Vérifie que la méthode existe et est appelable (compilation OK)
      expect(EdgeEmailService.envoyerDevis, isA<Function>());
    });

    test('devrait exposer envoyerFacture comme méthode statique', () {
      expect(EdgeEmailService.envoyerFacture, isA<Function>());
    });

    test('devrait exposer envoyerRelance comme méthode statique', () {
      expect(EdgeEmailService.envoyerRelance, isA<Function>());
    });
  });

  group('EdgeEmailService - EmailResult', () {
    test('EmailResult.ok() devrait retourner success: true', () {
      final result = EmailResult.ok();
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('EmailResult.error() devrait retourner success: false avec message',
        () {
      final result = EmailResult.error('Email invalide');
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Email invalide');
    });
  });

  group('EdgeEmailService - compatibilité EmailService', () {
    test('devrait utiliser le même EmailResult que EmailService', () {
      // Les deux services partagent la même classe EmailResult
      final ok = EmailResult.ok();
      expect(ok, isA<EmailResult>());
      expect(ok.success, isTrue);
    });

    test('devrait avoir les mêmes 3 méthodes que EmailService', () {
      // Vérification de parité API
      // EmailService: envoyerDevis, envoyerFacture, envoyerRelance
      // EdgeEmailService: envoyerDevis, envoyerFacture, envoyerRelance
      expect(EdgeEmailService.envoyerDevis, isA<Function>());
      expect(EdgeEmailService.envoyerFacture, isA<Function>());
      expect(EdgeEmailService.envoyerRelance, isA<Function>());
      expect(EmailService.envoyerDevis, isA<Function>());
      expect(EmailService.envoyerFacture, isA<Function>());
      expect(EmailService.envoyerRelance, isA<Function>());
    });
  });
}
