import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Résultat de la résolution d'une entité juridique à partir d'un SIRET.
class SiretLookupResult {
  /// La recherche a-t-elle abouti ?
  final bool found;

  /// Raison sociale / Nom de l'entreprise
  final String? nomEntreprise;

  /// Adresse (numéro + voie)
  final String? adresse;

  /// Code postal
  final String? codePostal;

  /// Ville / Commune
  final String? ville;

  /// Numéro SIREN (9 premiers chiffres du SIRET)
  final String? siren;

  /// Numéro de TVA intracommunautaire (calculé depuis le SIREN pour la France)
  final String? tvaIntra;

  /// Forme juridique (ex: "Entrepreneur individuel")
  final String? formeJuridique;

  /// Code APE / NAF
  final String? codeApe;

  /// Message d'erreur en cas d'échec
  final String? error;

  const SiretLookupResult({
    required this.found,
    this.nomEntreprise,
    this.adresse,
    this.codePostal,
    this.ville,
    this.siren,
    this.tvaIntra,
    this.formeJuridique,
    this.codeApe,
    this.error,
  });

  factory SiretLookupResult.notFound(String message) {
    return SiretLookupResult(found: false, error: message);
  }
}

/// Service d'auto-complétion d'entités juridiques à partir d'un SIRET.
///
/// Utilise l'API publique Sirene de l'INSEE (api.insee.fr) ou Recherche-Entreprises
/// (recherche-entreprises.api.gouv.fr) qui est gratuite et sans clé API.
///
/// Flux : SIRET saisi → requête API → remplissage automatique des champs
/// (Nom, Adresse, Code Postal, Ville) dans les formulaires Client ou Entreprise.
class AutoFillService {
  /// API Recherche Entreprises (gouv.fr) — gratuite, sans authentification
  static const String _searchApiBase =
      'https://recherche-entreprises.api.gouv.fr';

  /// Client HTTP injectable pour les tests
  final http.Client _client;

  AutoFillService({http.Client? client}) : _client = client ?? http.Client();

  /// Recherche une entreprise par son SIRET (14 chiffres).
  ///
  /// Utilise l'API Recherche-Entreprises (gratuite, pas de clé API).
  /// Retourne un [SiretLookupResult] avec les informations de l'établissement.
  ///
  /// En cas d'erreur réseau ou API, retourne un résultat avec [error] renseigné.
  Future<SiretLookupResult> lookupBySiret(String siret) async {
    final cleaned = siret.replaceAll(RegExp(r'\s'), '');

    if (!RegExp(r'^\d{14}$').hasMatch(cleaned)) {
      return SiretLookupResult.notFound(
          'Le SIRET doit contenir exactement 14 chiffres');
    }

    try {
      final url =
          Uri.parse('$_searchApiBase/search?q=$cleaned&page=1&per_page=1');
      final response = await _client.get(url, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseSearchResult(data, cleaned);
      } else {
        return SiretLookupResult.notFound(
          'Erreur API (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      developer.log('❌ AutoFill SIRET error: $e');
      return SiretLookupResult.notFound(
        'Service indisponible. Vérifiez votre connexion.',
      );
    }
  }

  /// Recherche textuelle d'entreprises (par nom, SIREN, etc.)
  ///
  /// Utile pour un champ de recherche autocomplete.
  /// Retourne une liste de résultats (max [limit]).
  Future<List<SiretLookupResult>> searchEntreprises(
    String query, {
    int limit = 5,
  }) async {
    if (query.trim().length < 3) return [];

    try {
      final encoded = Uri.encodeComponent(query.trim());
      final url =
          Uri.parse('$_searchApiBase/search?q=$encoded&page=1&per_page=$limit');
      final response = await _client.get(url, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseSearchResults(data);
      }
      return [];
    } catch (e) {
      developer.log('❌ AutoFill search error: $e');
      return [];
    }
  }

  /// Parse le résultat de l'API Recherche-Entreprises pour un SIRET exact.
  SiretLookupResult _parseSearchResult(
      Map<String, dynamic> data, String siret) {
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) {
      return SiretLookupResult.notFound('SIRET non trouvé : $siret');
    }

    final siren = siret.substring(0, 9);

    // Cherche l'établissement correspondant au SIRET complet
    for (final entreprise in results) {
      final matchingEtablissements =
          entreprise['matching_etablissements'] as List?;
      final siege = entreprise['siege'] as Map<String, dynamic>?;

      // Tente de trouver l'établissement exact
      Map<String, dynamic>? etablissement;
      if (matchingEtablissements != null && matchingEtablissements.isNotEmpty) {
        for (final etab in matchingEtablissements) {
          if (etab['siret'] == siret) {
            etablissement = etab as Map<String, dynamic>;
            break;
          }
        }
        etablissement ??= matchingEtablissements.first as Map<String, dynamic>;
      }
      etablissement ??= siege;

      if (etablissement == null) continue;

      final nom = _extractNom(entreprise);
      final adresse = _buildAdresse(etablissement);
      final codePostal = etablissement['code_postal']?.toString();
      final ville = etablissement['libelle_commune']?.toString();
      final codeApe = entreprise['activite_principale']?.toString();
      final nature = entreprise['nature_juridique']?.toString();

      return SiretLookupResult(
        found: true,
        nomEntreprise: nom,
        adresse: adresse,
        codePostal: codePostal,
        ville: ville,
        siren: siren,
        tvaIntra: _calculateTvaIntra(siren),
        formeJuridique: nature,
        codeApe: codeApe,
      );
    }

    return SiretLookupResult.notFound('SIRET non trouvé dans les résultats');
  }

  /// Parse plusieurs résultats de recherche
  List<SiretLookupResult> _parseSearchResults(Map<String, dynamic> data) {
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) return [];

    return results.map((entreprise) {
      final siege = entreprise['siege'] as Map<String, dynamic>?;
      final siren = entreprise['siren']?.toString() ?? '';

      return SiretLookupResult(
        found: true,
        nomEntreprise: _extractNom(entreprise),
        adresse: siege != null ? _buildAdresse(siege) : null,
        codePostal: siege?['code_postal']?.toString(),
        ville: siege?['libelle_commune']?.toString(),
        siren: siren,
        tvaIntra: siren.length == 9 ? _calculateTvaIntra(siren) : null,
        formeJuridique: entreprise['nature_juridique']?.toString(),
        codeApe: entreprise['activite_principale']?.toString(),
      );
    }).toList();
  }

  /// Extrait le nom principal d'une entreprise de l'API
  String? _extractNom(Map<String, dynamic> entreprise) {
    // Priorité : nom_complet > nom_raison_sociale > denomination
    return entreprise['nom_complet']?.toString() ??
        entreprise['nom_raison_sociale']?.toString();
  }

  /// Construit l'adresse complète depuis un établissement
  String? _buildAdresse(Map<String, dynamic> etablissement) {
    final parts = <String>[];
    final numero = etablissement['numero_voie']?.toString();
    final typeVoie = etablissement['type_voie']?.toString();
    final libelleVoie = etablissement['libelle_voie']?.toString();

    if (numero != null && numero.isNotEmpty) parts.add(numero);
    if (typeVoie != null && typeVoie.isNotEmpty) parts.add(typeVoie);
    if (libelleVoie != null && libelleVoie.isNotEmpty) parts.add(libelleVoie);

    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  /// Calcule le numéro de TVA intracommunautaire français depuis un SIREN.
  ///
  /// Formule : FR + clé TVA + SIREN
  /// Clé TVA = (12 + 3 * (SIREN % 97)) % 97
  static String? _calculateTvaIntra(String siren) {
    if (siren.length != 9) return null;
    try {
      final sirenInt = int.parse(siren);
      final cle = (12 + 3 * (sirenInt % 97)) % 97;
      return 'FR${cle.toString().padLeft(2, '0')}$siren';
    } catch (_) {
      return null;
    }
  }

  /// Libère les ressources HTTP
  void dispose() {
    _client.close();
  }
}
