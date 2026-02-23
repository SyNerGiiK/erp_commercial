import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class CompanyDataService {
  // Free tier API endpoints
  static const String pappersApiUrl = 'https://api.pappers.fr/v2/entreprise';
  static const String banApiUrl = 'https://api-adresse.data.gouv.fr/search';
  static const String viesApiUrl =
      'https://ec.europa.eu/taxation_customs/vies/rest-api/ms';

  static Future<Map<String, dynamic>?> searchCompanyBySiret(
      String siret) async {
    try {
      final response = await http.get(Uri.parse(
          'https://recherche-entreprises.api.gouv.fr/search?q=$siret'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          return data['results'][0];
        }
      }
      return null;
    } catch (e) {
      developer.log("Erreur searchCompanyBySiret", error: e);
      return null;
    }
  }

  /// Recherche une adresse via la Base Adresse Nationale (BAN) gratuite
  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      final response = await http.get(
          Uri.parse('$banApiUrl/?q=${Uri.encodeComponent(query)}&limit=5'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        return features
            .map((f) => f['properties'] as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      developer.log("Erreur searchAddress", error: e);
      return [];
    }
  }

  /// Vérifie le numéro de TVA intracommunautaire via l'API VIES
  static Future<bool> verifyVatNumber(
      String countryCode, String vatNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$viesApiUrl/$countryCode/vat/$vatNumber'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isValid'] ?? false;
      }
      return false;
    } catch (e) {
      developer.log("Erreur verifyVatNumber", error: e);
      return false;
    }
  }
}
