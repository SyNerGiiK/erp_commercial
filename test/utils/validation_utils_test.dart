import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/utils/validation_utils.dart';

void main() {
  group('ValidationUtils - validateEmail', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validateEmail(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validateEmail(''), isNull);
    });

    test('devrait accepter un email valide', () {
      expect(ValidationUtils.validateEmail('test@example.com'), isNull);
      expect(ValidationUtils.validateEmail('user.name@domain.fr'), isNull);
      expect(ValidationUtils.validateEmail('a+b@c.com'), isNull);
    });

    test('devrait rejeter un email invalide', () {
      expect(ValidationUtils.validateEmail('test'), isNotNull);
      expect(ValidationUtils.validateEmail('test@'), isNotNull);
      expect(ValidationUtils.validateEmail('@domain.com'), isNotNull);
      expect(ValidationUtils.validateEmail('test@.com'), isNotNull);
    });
  });

  group('ValidationUtils - validateEmailRequired', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validateEmailRequired(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validateEmailRequired(''), isNotNull);
    });

    test('devrait accepter un email valide', () {
      expect(ValidationUtils.validateEmailRequired('test@example.com'), isNull);
    });

    test('devrait rejeter un email invalide', () {
      expect(ValidationUtils.validateEmailRequired('not-an-email'), isNotNull);
    });
  });

  group('ValidationUtils - validatePhone', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validatePhone(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validatePhone(''), isNull);
    });

    test('devrait accepter un numéro français valide', () {
      expect(ValidationUtils.validatePhone('0612345678'), isNull);
      expect(ValidationUtils.validatePhone('06 12 34 56 78'), isNull);
      expect(ValidationUtils.validatePhone('06.12.34.56.78'), isNull);
      expect(ValidationUtils.validatePhone('+33612345678'), isNull);
    });

    test('devrait rejeter un numéro trop court', () {
      expect(ValidationUtils.validatePhone('06123'), isNotNull);
    });
  });

  group('ValidationUtils - validatePhoneRequired', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validatePhoneRequired(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validatePhoneRequired(''), isNotNull);
    });

    test('devrait accepter un numéro valide', () {
      expect(ValidationUtils.validatePhoneRequired('0612345678'), isNull);
    });
  });

  group('ValidationUtils - validateSiret', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validateSiret(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validateSiret(''), isNull);
    });

    test('devrait accepter un SIRET de 14 chiffres', () {
      expect(ValidationUtils.validateSiret('12345678901234'), isNull);
    });

    test('devrait accepter un SIRET avec espaces', () {
      expect(ValidationUtils.validateSiret('123 456 789 01234'), isNull);
    });

    test('devrait rejeter un SIRET invalide', () {
      expect(ValidationUtils.validateSiret('1234'), isNotNull);
      expect(ValidationUtils.validateSiret('abcdefghijklmn'), isNotNull);
    });
  });

  group('ValidationUtils - validateTvaIntra', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validateTvaIntra(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validateTvaIntra(''), isNull);
    });

    test('devrait accepter un TVA intracommunautaire FR valide', () {
      expect(ValidationUtils.validateTvaIntra('FR12345678901'), isNull);
    });

    test('devrait accepter un TVA avec espaces', () {
      expect(ValidationUtils.validateTvaIntra('FR 12 345678901'), isNull);
    });

    test('devrait rejeter un numéro TVA invalide', () {
      expect(ValidationUtils.validateTvaIntra('12345'), isNotNull);
    });
  });

  group('ValidationUtils - validateRequired', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validateRequired(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validateRequired(''), isNotNull);
    });

    test('devrait rejeter une chaîne d\'espaces', () {
      expect(ValidationUtils.validateRequired('   '), isNotNull);
    });

    test('devrait accepter une chaîne non vide', () {
      expect(ValidationUtils.validateRequired('Hello'), isNull);
    });

    test('devrait utiliser le nom du champ dans le message', () {
      final result = ValidationUtils.validateRequired(null, 'Nom');
      expect(result, contains('Nom'));
    });
  });

  group('ValidationUtils - validateMontant', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validateMontant(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validateMontant(''), isNotNull);
    });

    test('devrait accepter un montant valide', () {
      expect(ValidationUtils.validateMontant('100'), isNull);
      expect(ValidationUtils.validateMontant('100.50'), isNull);
    });

    test('devrait rejeter un montant négatif', () {
      expect(ValidationUtils.validateMontant('-10'), isNotNull);
    });

    test('devrait rejeter zéro par défaut', () {
      expect(ValidationUtils.validateMontant('0'), isNotNull);
    });

    test('devrait accepter zéro si allowZero', () {
      expect(ValidationUtils.validateMontant('0', allowZero: true), isNull);
    });

    test('devrait rejeter négatif même avec allowZero', () {
      expect(
          ValidationUtils.validateMontant('-10', allowZero: true), isNotNull);
    });

    test('devrait rejeter un montant non numérique', () {
      expect(ValidationUtils.validateMontant('abc'), isNotNull);
    });

    test('devrait accepter la virgule comme séparateur', () {
      expect(ValidationUtils.validateMontant('100,50'), isNull);
    });
  });

  group('ValidationUtils - validateCodePostal', () {
    test('devrait rejeter null (requis)', () {
      expect(ValidationUtils.validateCodePostal(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide (requis)', () {
      expect(ValidationUtils.validateCodePostal(''), isNotNull);
    });

    test('devrait accepter un code postal français valide', () {
      expect(ValidationUtils.validateCodePostal('75001'), isNull);
      expect(ValidationUtils.validateCodePostal('97400'), isNull);
    });

    test('devrait rejeter un code postal invalide', () {
      expect(ValidationUtils.validateCodePostal('7500'), isNotNull);
      expect(ValidationUtils.validateCodePostal('ABCDE'), isNotNull);
      expect(ValidationUtils.validateCodePostal('750011'), isNotNull);
    });
  });

  group('ValidationUtils - validateDateEcheance', () {
    test('devrait rejeter null (requis)', () {
      final emission = DateTime(2024, 1, 1);
      expect(ValidationUtils.validateDateEcheance(null, emission), isNotNull);
    });

    test('devrait accepter une date après émission', () {
      final emission = DateTime(2024, 1, 1);
      final echeance = DateTime(2024, 2, 1);
      expect(ValidationUtils.validateDateEcheance(echeance, emission), isNull);
    });

    test('devrait rejeter une date avant émission', () {
      final emission = DateTime(2024, 3, 1);
      final echeance = DateTime(2024, 2, 1);
      expect(
          ValidationUtils.validateDateEcheance(echeance, emission), isNotNull);
    });

    test('devrait accepter la même date que émission', () {
      final date = DateTime(2024, 1, 15);
      expect(ValidationUtils.validateDateEcheance(date, date), isNull);
    });
  });

  group('ValidationUtils - validatePourcentage', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validatePourcentage(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validatePourcentage(''), isNull);
    });

    test('devrait accepter 0', () {
      expect(ValidationUtils.validatePourcentage('0'), isNull);
    });

    test('devrait accepter 100', () {
      expect(ValidationUtils.validatePourcentage('100'), isNull);
    });

    test('devrait accepter 50.5', () {
      expect(ValidationUtils.validatePourcentage('50.5'), isNull);
    });

    test('devrait rejeter un pourcentage > 100', () {
      expect(ValidationUtils.validatePourcentage('101'), isNotNull);
    });

    test('devrait rejeter un pourcentage négatif', () {
      expect(ValidationUtils.validatePourcentage('-5'), isNotNull);
    });

    test('devrait rejeter une valeur non numérique', () {
      expect(ValidationUtils.validatePourcentage('abc'), isNotNull);
    });
  });

  group('ValidationUtils - validateQuantite', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validateQuantite(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validateQuantite(''), isNotNull);
    });

    test('devrait accepter un entier positif', () {
      expect(ValidationUtils.validateQuantite('5'), isNull);
    });

    test('devrait accepter un décimal positif', () {
      expect(ValidationUtils.validateQuantite('2.5'), isNull);
    });

    test('devrait rejeter zéro', () {
      expect(ValidationUtils.validateQuantite('0'), isNotNull);
    });

    test('devrait rejeter un négatif', () {
      expect(ValidationUtils.validateQuantite('-1'), isNotNull);
    });

    test('devrait rejeter une valeur non numérique', () {
      expect(ValidationUtils.validateQuantite('abc'), isNotNull);
    });
  });
}
