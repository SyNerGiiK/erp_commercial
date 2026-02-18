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
}
