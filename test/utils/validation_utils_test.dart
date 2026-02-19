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

    test('devrait accepter un SIRET de 14 chiffres valide Luhn', () {
      // 44306184100047 passe l'algorithme de Luhn
      expect(ValidationUtils.validateSiret('44306184100047'), isNull);
      expect(ValidationUtils.validateSiret('32105077000015'), isNull);
    });

    test('devrait accepter un SIRET avec espaces valide Luhn', () {
      expect(ValidationUtils.validateSiret('443 061 841 00047'), isNull);
    });

    test('devrait rejeter un SIRET au format invalide', () {
      expect(ValidationUtils.validateSiret('1234'), isNotNull);
      expect(ValidationUtils.validateSiret('abcdefghijklmn'), isNotNull);
    });

    test('devrait rejeter un SIRET de 14 chiffres ne passant pas Luhn', () {
      // 12345678901234 a 14 chiffres mais échoue Luhn
      expect(ValidationUtils.validateSiret('12345678901234'), isNotNull);
      expect(ValidationUtils.validateSiret('11111111111111'), isNotNull);
    });

    test('devrait accepter un SIRET La Poste (SIREN 356000000)', () {
      // La Poste : somme des chiffres divisible par 5
      // 35600000049837 → somme = 45 → 45 % 5 = 0
      expect(ValidationUtils.validateSiret('35600000049837'), isNull);
    });

    test('devrait rejeter un SIRET La Poste invalide', () {
      // 35600000012345 → somme = 29 → 29 % 5 = 4
      expect(ValidationUtils.validateSiret('35600000012345'), isNotNull);
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

  // --- TESTS VALIDATION IBAN (ISO 13616) ---

  group('ValidationUtils - validateIban', () {
    test('devrait accepter null (optionnel)', () {
      expect(ValidationUtils.validateIban(null), isNull);
    });

    test('devrait accepter une chaîne vide (optionnel)', () {
      expect(ValidationUtils.validateIban(''), isNull);
    });

    test('devrait accepter un IBAN français valide', () {
      // IBAN de test standard FR76 3000 6000 0112 3456 7890 189
      expect(
          ValidationUtils.validateIban('FR7630006000011234567890189'), isNull);
    });

    test('devrait accepter un IBAN avec espaces', () {
      expect(
        ValidationUtils.validateIban('FR76 3000 6000 0112 3456 7890 189'),
        isNull,
      );
    });

    test('devrait accepter un IBAN en minuscules', () {
      expect(
        ValidationUtils.validateIban('fr7630006000011234567890189'),
        isNull,
      );
    });

    test('devrait accepter un IBAN allemand valide', () {
      // DE89 3704 0044 0532 0130 00
      expect(ValidationUtils.validateIban('DE89370400440532013000'), isNull);
    });

    test('devrait accepter un IBAN britannique valide', () {
      // GB29 NWBK 6016 1331 9268 19
      expect(ValidationUtils.validateIban('GB29NWBK60161331926819'), isNull);
    });

    test('devrait accepter un IBAN espagnol valide', () {
      // ES91 2100 0418 4502 0005 1332
      expect(ValidationUtils.validateIban('ES9121000418450200051332'), isNull);
    });

    test('devrait accepter un IBAN belge valide', () {
      // BE68 5390 0754 7034
      expect(ValidationUtils.validateIban('BE68539007547034'), isNull);
    });

    test('devrait rejeter un IBAN trop court', () {
      expect(ValidationUtils.validateIban('FR76300'), isNotNull);
    });

    test('devrait rejeter un format sans code pays', () {
      expect(ValidationUtils.validateIban('1234567890123456'), isNotNull);
    });

    test('devrait rejeter un code pays inconnu', () {
      expect(ValidationUtils.validateIban('XX1234567890123456'), isNotNull);
    });

    test('devrait rejeter un IBAN français de mauvaise longueur', () {
      // FR attend 27 caractères, ici 25
      expect(ValidationUtils.validateIban('FR76300060000112345678'), isNotNull);
    });

    test('devrait rejeter un IBAN avec clé de contrôle incorrecte', () {
      // Clé modifiée : FR00 au lieu de FR76
      expect(
        ValidationUtils.validateIban('FR0030006000011234567890189'),
        isNotNull,
      );
    });

    test('devrait rejeter un IBAN avec caractères spéciaux', () {
      expect(
        ValidationUtils.validateIban('FR76-3000-6000-0112-3456-7890-189'),
        isNotNull,
      );
    });

    test('devrait rejeter un IBAN allemand avec mauvaise clé', () {
      // DE00 au lieu de DE89
      expect(ValidationUtils.validateIban('DE00370400440532013000'), isNotNull);
    });
  });

  group('ValidationUtils - validateIbanRequired', () {
    test('devrait rejeter null', () {
      expect(ValidationUtils.validateIbanRequired(null), isNotNull);
    });

    test('devrait rejeter une chaîne vide', () {
      expect(ValidationUtils.validateIbanRequired(''), isNotNull);
    });

    test('devrait accepter un IBAN valide', () {
      expect(
        ValidationUtils.validateIbanRequired('FR7630006000011234567890189'),
        isNull,
      );
    });

    test('devrait rejeter un IBAN invalide', () {
      expect(
        ValidationUtils.validateIbanRequired('FR0000000000000000000000000'),
        isNotNull,
      );
    });
  });
}
