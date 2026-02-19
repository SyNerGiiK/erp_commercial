import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Résultat de la validation TVA intracommunautaire via VIES.
class ViesValidationResult {
  /// Le numéro de TVA est-il valide et actif ?
  final bool isValid;

  /// Nom de l'entreprise retourné par VIES (peut être '---' si non disponible)
  final String? name;

  /// Adresse retournée par VIES (peut être '---' si non disponible)
  final String? address;

  /// Code pays (2 lettres ISO)
  final String countryCode;

  /// Numéro de TVA (sans le code pays)
  final String vatNumber;

  /// Message d'erreur en cas d'échec réseau ou API
  final String? error;

  const ViesValidationResult({
    required this.isValid,
    this.name,
    this.address,
    required this.countryCode,
    required this.vatNumber,
    this.error,
  });

  /// Résultat d'erreur réseau/API
  factory ViesValidationResult.error(String message,
      {String countryCode = '', String vatNumber = ''}) {
    return ViesValidationResult(
      isValid: false,
      countryCode: countryCode,
      vatNumber: vatNumber,
      error: message,
    );
  }
}

/// Service de validation des numéros de TVA intracommunautaire
/// via l'API VIES (VAT Information Exchange System) de la Commission Européenne.
///
/// API REST officielle : https://ec.europa.eu/taxation_customs/vies/rest-api/
/// Aucune authentification requise. Requêtes stateless.
class TvaValidatorService {
  static const String _baseUrl =
      'https://ec.europa.eu/taxation_customs/vies/rest-api/ms';

  /// Client HTTP injectable pour les tests
  final http.Client _client;

  TvaValidatorService({http.Client? client})
      : _client = client ?? http.Client();

  /// Valide un numéro de TVA intracommunautaire en temps réel via VIES.
  ///
  /// [tvaNumber] : numéro complet (ex: "FR12345678901")
  /// Retourne un [ViesValidationResult] avec le statut de validité,
  /// le nom et l'adresse de l'entreprise si disponibles.
  ///
  /// En cas d'erreur réseau ou API indisponible, retourne un résultat
  /// avec [error] renseigné — ne lève jamais d'exception.
  Future<ViesValidationResult> validateVatNumber(String tvaNumber) async {
    final cleaned = tvaNumber.replaceAll(RegExp(r'\s'), '').toUpperCase();

    if (cleaned.length < 4) {
      return ViesValidationResult.error(
        'Numéro de TVA trop court',
        countryCode: '',
        vatNumber: cleaned,
      );
    }

    final countryCode = cleaned.substring(0, 2);
    final vatNumber = cleaned.substring(2);

    // Vérification que le code pays est bien 2 lettres
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(countryCode)) {
      return ViesValidationResult.error(
        'Code pays invalide : $countryCode',
        countryCode: countryCode,
        vatNumber: vatNumber,
      );
    }

    try {
      final url = Uri.parse('$_baseUrl/$countryCode/vat/$vatNumber');
      final response = await _client.get(url, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final isValid = data['isValid'] == true;

        return ViesValidationResult(
          isValid: isValid,
          name: _cleanViesField(data['name']),
          address: _cleanViesField(data['address']),
          countryCode: countryCode,
          vatNumber: vatNumber,
        );
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        return ViesValidationResult(
          isValid: false,
          countryCode: countryCode,
          vatNumber: vatNumber,
          error: 'Numéro de TVA non trouvé',
        );
      } else {
        return ViesValidationResult.error(
          'Erreur API VIES (HTTP ${response.statusCode})',
          countryCode: countryCode,
          vatNumber: vatNumber,
        );
      }
    } catch (e) {
      developer.log('❌ VIES API error: $e');
      return ViesValidationResult.error(
        'Service VIES indisponible. Vérifiez votre connexion.',
        countryCode: countryCode,
        vatNumber: vatNumber,
      );
    }
  }

  /// Nettoie un champ VIES (enlève '---' qui signifie non disponible)
  static String? _cleanViesField(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == '---') return null;
    return str;
  }

  /// Libère les ressources HTTP
  void dispose() {
    _client.close();
  }
}
