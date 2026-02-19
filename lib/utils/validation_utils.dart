import 'package:decimal/decimal.dart';

/// Utilitaires de validation pour les formulaires et modèles
class ValidationUtils {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optionnel
    final regex = RegExp(r'^[\w\-.+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return "Email invalide";
    }
    return null;
  }

  /// Valide un email obligatoire
  static String? validateEmailRequired(String? value) {
    if (value == null || value.trim().isEmpty) return "Email requis";
    return validateEmail(value);
  }

  /// Valide un numéro de téléphone français
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optionnel
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 10 || digits.length > 14) {
      return "Numéro de téléphone invalide";
    }
    return null;
  }

  /// Valide un numéro de téléphone obligatoire
  static String? validatePhoneRequired(String? value) {
    if (value == null || value.trim().isEmpty) return "Téléphone requis";
    return validatePhone(value);
  }

  /// Valide un SIRET (14 chiffres + algorithme de Luhn).
  ///
  /// Le SIRET standard est validé par l'algorithme de Luhn sur 14 chiffres.
  /// Cas particulier : les établissements de La Poste (SIREN 356 000 000)
  /// ne respectent pas Luhn → on vérifie que la somme des chiffres = 0 mod 5.
  static String? validateSiret(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optionnel
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{14}$').hasMatch(digits)) {
      return "Le SIRET doit contenir 14 chiffres";
    }

    // Cas La Poste : SIREN 356000000
    if (digits.startsWith('356000000')) {
      final digitSum =
          digits.codeUnits.fold<int>(0, (sum, c) => sum + (c - 48));
      if (digitSum % 5 != 0) {
        return "SIRET La Poste invalide";
      }
      return null;
    }

    // Algorithme de Luhn sur 14 chiffres
    if (!_luhnCheck(digits)) {
      return "SIRET invalide (vérification Luhn échouée)";
    }
    return null;
  }

  /// Algorithme de Luhn : retourne true si la chaîne de chiffres est valide.
  static bool _luhnCheck(String digits) {
    int sum = 0;
    // On parcourt de droite à gauche ; les positions paires (0-indexed
    // depuis la droite) restent telles quelles, les impaires sont doublées.
    for (int i = 0; i < digits.length; i++) {
      int digit = digits.codeUnitAt(digits.length - 1 - i) - 48;
      if (i.isOdd) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0;
  }

  /// Valide un numéro de TVA intracommunautaire
  static String? validateTvaIntra(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    // Format français : FR + 2 chiffres + SIREN (9 chiffres)
    final cleaned = value.trim().replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!RegExp(r'^FR\d{11}$').hasMatch(cleaned)) {
      return "Format TVA invalide (ex: FR12345678901)";
    }
    return null;
  }

  /// Valide un champ texte obligatoire
  static String? validateRequired(String? value,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName est requis";
    }
    return null;
  }

  /// Valide un montant (Decimal positif)
  static String? validateMontant(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) return "Montant requis";
    try {
      final decimal = Decimal.parse(value.replaceAll(',', '.'));
      if (!allowZero && decimal <= Decimal.zero) {
        return "Le montant doit être positif";
      }
      if (allowZero && decimal < Decimal.zero) {
        return "Le montant ne peut pas être négatif";
      }
      return null;
    } catch (_) {
      return "Montant invalide";
    }
  }

  /// Valide un code postal français (5 chiffres)
  static String? validateCodePostal(String? value) {
    if (value == null || value.trim().isEmpty) return "Code postal requis";
    if (!RegExp(r'^\d{5}$').hasMatch(value.trim())) {
      return "Code postal invalide (5 chiffres)";
    }
    return null;
  }

  /// Valide une date d'échéance (doit être après la date d'émission)
  static String? validateDateEcheance(DateTime? echeance, DateTime emission) {
    if (echeance == null) return "Date d'échéance requise";
    if (echeance.isBefore(emission)) {
      return "La date d'échéance doit être après la date d'émission";
    }
    return null;
  }

  /// Valide un pourcentage (0-100)
  static String? validatePourcentage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final d = double.parse(value.replaceAll(',', '.'));
      if (d < 0 || d > 100) return "Pourcentage entre 0 et 100";
      return null;
    } catch (_) {
      return "Pourcentage invalide";
    }
  }

  /// Valide une quantité
  static String? validateQuantite(String? value) {
    if (value == null || value.trim().isEmpty) return "Quantité requise";
    try {
      final d = Decimal.parse(value.replaceAll(',', '.'));
      if (d <= Decimal.zero) return "La quantité doit être positive";
      return null;
    } catch (_) {
      return "Quantité invalide";
    }
  }

  // --- VALIDATION IBAN (ISO 13616) ---

  /// Table des longueurs IBAN par pays (norme ISO 13616).
  /// Couvre les pays européens + principaux pays internationaux.
  static const Map<String, int> _ibanLengths = {
    'AL': 28,
    'AD': 24,
    'AT': 20,
    'AZ': 28,
    'BH': 22,
    'BY': 28,
    'BE': 16,
    'BA': 20,
    'BR': 29,
    'BG': 22,
    'CR': 22,
    'HR': 21,
    'CY': 28,
    'CZ': 24,
    'DK': 18,
    'DO': 28,
    'TL': 23,
    'EE': 20,
    'FO': 18,
    'FI': 18,
    'FR': 27,
    'GE': 22,
    'DE': 22,
    'GI': 23,
    'GR': 27,
    'GL': 18,
    'GT': 28,
    'HU': 28,
    'IS': 26,
    'IQ': 23,
    'IE': 22,
    'IL': 23,
    'IT': 27,
    'JO': 30,
    'KZ': 20,
    'XK': 20,
    'KW': 30,
    'LV': 21,
    'LB': 28,
    'LI': 21,
    'LT': 20,
    'LU': 20,
    'MK': 19,
    'MT': 31,
    'MR': 27,
    'MU': 30,
    'MC': 27,
    'MD': 24,
    'ME': 22,
    'NL': 18,
    'NO': 15,
    'PK': 24,
    'PS': 29,
    'PL': 28,
    'PT': 25,
    'QA': 29,
    'RO': 24,
    'SM': 27,
    'SA': 24,
    'RS': 22,
    'SC': 31,
    'SK': 24,
    'SI': 19,
    'ES': 24,
    'SE': 24,
    'CH': 21,
    'TN': 24,
    'TR': 26,
    'UA': 29,
    'AE': 23,
    'GB': 22,
    'VG': 24,
  };

  /// Valide un IBAN selon la norme ISO 13616 :
  /// 1. Format : 2 lettres (pays) + 2 chiffres (clé) + BBAN
  /// 2. Longueur spécifique au pays
  /// 3. Vérification modulo 97 (algorithme MOD-97-10, ISO 7064)
  ///
  /// Champ optionnel : retourne null si vide.
  static String? validateIban(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optionnel

    // Nettoyage : suppression espaces et mise en majuscules
    final cleaned = value.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Vérification format de base : min 15 chars, commence par 2 lettres + 2 chiffres
    if (cleaned.length < 15) {
      return "IBAN trop court";
    }
    if (!RegExp(r'^[A-Z]{2}\d{2}').hasMatch(cleaned)) {
      return "Format IBAN invalide (doit commencer par 2 lettres + 2 chiffres)";
    }

    // Vérification que le reste ne contient que des caractères alphanumériques
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleaned)) {
      return "L'IBAN ne doit contenir que des lettres et des chiffres";
    }

    // Vérification longueur par pays
    final countryCode = cleaned.substring(0, 2);
    final expectedLength = _ibanLengths[countryCode];
    if (expectedLength == null) {
      return "Code pays IBAN non reconnu ($countryCode)";
    }
    if (cleaned.length != expectedLength) {
      return "L'IBAN $countryCode doit contenir $expectedLength caractères "
          "(${cleaned.length} fournis)";
    }

    // Vérification MOD-97-10 (ISO 7064)
    if (!_ibanMod97Check(cleaned)) {
      return "IBAN invalide (clé de contrôle incorrecte)";
    }

    return null;
  }

  /// Valide un IBAN obligatoire
  static String? validateIbanRequired(String? value) {
    if (value == null || value.trim().isEmpty) return "IBAN requis";
    return validateIban(value);
  }

  /// Algorithme MOD-97-10 (ISO 7064) pour la validation IBAN.
  ///
  /// 1. Déplace les 4 premiers caractères à la fin
  /// 2. Convertit les lettres en chiffres (A=10, B=11, ..., Z=35)
  /// 3. Calcule le modulo 97 du nombre résultant
  /// 4. Le résultat doit être égal à 1
  static bool _ibanMod97Check(String iban) {
    // Réarrangement : BBAN + pays + clé
    final rearranged = iban.substring(4) + iban.substring(0, 4);

    // Conversion lettres → chiffres
    final StringBuffer numericStr = StringBuffer();
    for (int i = 0; i < rearranged.length; i++) {
      final code = rearranged.codeUnitAt(i);
      if (code >= 65 && code <= 90) {
        // A-Z → 10-35
        numericStr.write(code - 55);
      } else {
        numericStr.write(rearranged[i]);
      }
    }

    // Calcul modulo 97 par segments (le nombre peut être très grand)
    final digits = numericStr.toString();
    int remainder = 0;
    for (int i = 0; i < digits.length; i++) {
      remainder = (remainder * 10 + (digits.codeUnitAt(i) - 48)) % 97;
    }

    return remainder == 1;
  }
}
