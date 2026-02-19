import 'dart:convert';
import 'dart:developer' as developer;
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;

import '../models/urssaf_model.dart';
import '../models/enums/entreprise_enums.dart';

/// Résultat d'une synchronisation avec l'API URSSAF Publicodes.
class UrssafSyncResult {
  final bool success;
  final UrssafConfig? config;
  final String? errorMessage;
  final DateTime syncedAt;

  const UrssafSyncResult({
    required this.success,
    this.config,
    this.errorMessage,
    required this.syncedAt,
  });
}

/// Service de synchronisation des taux URSSAF via l'API Publicodes officielle.
///
/// Endpoint : https://mon-entreprise.urssaf.fr/api/v1/evaluate
///
/// Appelle l'API avec la situation de l'entrepreneur et récupère les taux
/// réels (cotisations sociales, CFP, TFC, versement libératoire, plafonds).
class UrssafSyncService {
  static const String _apiUrl =
      'https://mon-entreprise.urssaf.fr/api/v1/evaluate';

  /// Client HTTP injectable pour les tests
  final http.Client _client;

  UrssafSyncService({http.Client? client}) : _client = client ?? http.Client();

  /// Synchronise les taux depuis l'API URSSAF Publicodes.
  ///
  /// Construit une situation Publicodes à partir de [currentConfig]
  /// (statut, type activité, CA fictif), appelle l'API, et retourne
  /// un [UrssafSyncResult] contenant la config mise à jour.
  Future<UrssafSyncResult> syncFromApi(UrssafConfig currentConfig) async {
    final now = DateTime.now();

    try {
      final situation = _buildSituation(currentConfig);
      final expressions = _buildExpressions(currentConfig);

      final response = await _client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'situation': situation,
          'expressions': expressions,
        }),
      );

      if (response.statusCode != 200) {
        return UrssafSyncResult(
          success: false,
          errorMessage: 'Erreur API URSSAF (HTTP ${response.statusCode})',
          syncedAt: now,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data.containsKey('situationError')) {
        return UrssafSyncResult(
          success: false,
          errorMessage: 'Erreur situation: ${data['situationError']}',
          syncedAt: now,
        );
      }

      final evaluate = data['evaluate'] as List<dynamic>;
      final updatedConfig = _parseResponse(
        evaluate,
        expressions,
        currentConfig,
        now,
      );

      return UrssafSyncResult(
        success: true,
        config: updatedConfig,
        syncedAt: now,
      );
    } catch (e, s) {
      developer.log(
        '🔴 UrssafSyncService: Échec synchronisation',
        error: e,
        stackTrace: s,
      );
      return UrssafSyncResult(
        success: false,
        errorMessage: 'Erreur réseau: ${e.toString()}',
        syncedAt: now,
      );
    }
  }

  /// Construit la situation Publicodes selon le profil de l'entrepreneur.
  Map<String, String> _buildSituation(UrssafConfig config) {
    final situation = <String, String>{
      "entreprise . catégorie juridique": "'EI'",
      "entreprise . catégorie juridique . EI . auto-entrepreneur": "oui",
      "dirigeant . auto-entrepreneur . impôt . versement libératoire":
          config.versementLiberatoire ? "oui" : "non",
      "dirigeant . exonérations . ACRE": config.accreActive ? "oui" : "non",
      "établissement . commune": "'75056'",
    };

    // Nature d'activité
    switch (config.statut) {
      case StatutEntrepreneur.artisan:
        situation["entreprise . activité"] = "'artisanale'";
        situation["entreprise . activité . nature"] = "'artisanale'";
        break;
      case StatutEntrepreneur.commercant:
        situation["entreprise . activité"] = "'commerciale'";
        situation["entreprise . activité . nature"] = "'commerciale'";
        break;
      case StatutEntrepreneur.liberal:
        situation["entreprise . activité"] = "'libérale'";
        situation["entreprise . activité . nature"] = "'libérale'";
        break;
    }

    // CA fictif (nécessaire pour que l'API calcule les taux)
    // On utilise des montants représentatifs pour obtenir les bons taux
    switch (config.typeActivite) {
      case TypeActiviteMicro.bicVente:
        situation[
                "entreprise . chiffre d'affaires . vente restauration hébergement"] =
            "50000.0 €/an";
        situation["dirigeant . auto-entrepreneur . chiffre d'affaires"] =
            "50000.0 €/an";
        break;
      case TypeActiviteMicro.bicPrestation:
        situation["entreprise . chiffre d'affaires . service BIC"] =
            "50000.0 €/an";
        situation["dirigeant . auto-entrepreneur . chiffre d'affaires"] =
            "50000.0 €/an";
        break;
      case TypeActiviteMicro.bncPrestation:
        situation["entreprise . chiffre d'affaires . service BNC"] =
            "50000.0 €/an";
        situation["dirigeant . auto-entrepreneur . chiffre d'affaires"] =
            "50000.0 €/an";
        break;
      case TypeActiviteMicro.mixte:
        situation[
                "entreprise . chiffre d'affaires . vente restauration hébergement"] =
            "30000.0 €/an";
        situation["entreprise . chiffre d'affaires . service BIC"] =
            "50000.0 €/an";
        situation["dirigeant . auto-entrepreneur . chiffre d'affaires"] =
            "80000.0 €/an";
        break;
    }

    return situation;
  }

  /// Construit la liste d'expressions à évaluer.
  List<String> _buildExpressions(UrssafConfig config) {
    return [
      // [0] Taux cotisations vente
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . taux",
      // [1] Taux cotisations service BIC
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . taux",
      // [2] Taux cotisations service BNC
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BNC . taux",
      // [3] CFP total
      "dirigeant . auto-entrepreneur . cotisations et contributions . CFP",
      // [4] TFC total
      "dirigeant . auto-entrepreneur . cotisations et contributions . TFC",
      // [5] TFC métiers taux service
      "dirigeant . auto-entrepreneur . cotisations et contributions . TFC . métiers . taux service",
      // [6] TFC métiers taux vente
      "dirigeant . auto-entrepreneur . cotisations et contributions . TFC . métiers . taux vente",
      // [7] Plafond micro total (vente)
      "entreprise . chiffre d'affaires . seuil micro . total",
      // [8] Plafond micro libérale (service)
      "entreprise . chiffre d'affaires . seuil micro . libérale",
      // [9] VL plafond RFR
      "dirigeant . auto-entrepreneur . impôt . versement libératoire . plafond",
      // [10] VL montant
      "dirigeant . auto-entrepreneur . impôt . versement libératoire . montant",
      // [11] Revenu net
      "dirigeant . auto-entrepreneur . revenu net",
      // [12] Revenu net après impôt
      "dirigeant . auto-entrepreneur . revenu net . après impôt",
      // [13] Revenu imposable
      "dirigeant . auto-entrepreneur . impôt . revenu imposable",
      // Sous-répartition BIC service
      // [14] Maladie-maternité
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . maladie-maternité",
      // [15] Retraite de base
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . retraite de base",
      // [16] Retraite complémentaire
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . retraite complémentaire",
      // [17] Invalidité-décès
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . invalidité-décès",
      // [18] Autres contributions (CSG/CRDS)
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . autres contributions",
      // Sous-répartition Vente
      // [19] Maladie-maternité
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . maladie-maternité",
      // [20] Retraite de base
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . retraite de base",
      // [21] Retraite complémentaire
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . retraite complémentaire",
      // [22] Invalidité-décès
      "dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . invalidité-décès",
    ];
  }

  /// Parse la réponse API et met à jour la config.
  UrssafConfig _parseResponse(
    List<dynamic> evaluate,
    List<String> expressions,
    UrssafConfig currentConfig,
    DateTime syncTime,
  ) {
    Decimal? tauxVente;
    Decimal? tauxBIC;
    Decimal? tauxBNC;
    Decimal? tauxTfcService;
    Decimal? tauxTfcVente;
    Decimal? plafondMicroVente;
    Decimal? plafondMicroService;
    Decimal? plafondVlRfr;

    for (int i = 0; i < evaluate.length && i < expressions.length; i++) {
      final entry = evaluate[i] as Map<String, dynamic>;
      final nodeValue = entry['nodeValue'];
      if (nodeValue == null || nodeValue is bool) continue;

      final value = _extractDecimal(nodeValue);
      if (value == null) continue;

      switch (i) {
        case 0: // Taux vente
          tauxVente = value;
          break;
        case 1: // Taux BIC
          tauxBIC = value;
          break;
        case 2: // Taux BNC
          tauxBNC = value;
          break;
        case 5: // TFC métiers taux service
          tauxTfcService = value;
          break;
        case 6: // TFC métiers taux vente
          tauxTfcVente = value;
          break;
        case 7: // Plafond micro total
          plafondMicroVente = value;
          break;
        case 8: // Plafond micro libérale
          plafondMicroService = value;
          break;
        case 9: // Plafond VL RFR
          plafondVlRfr = value;
          break;
      }
    }

    return currentConfig.copyWith(
      tauxMicroVente: tauxVente ?? currentConfig.tauxMicroVente,
      tauxMicroPrestationBIC: tauxBIC ?? currentConfig.tauxMicroPrestationBIC,
      tauxMicroPrestationBNC: tauxBNC ?? currentConfig.tauxMicroPrestationBNC,
      tauxTfcService: tauxTfcService ?? currentConfig.tauxTfcService,
      tauxTfcVente: tauxTfcVente ?? currentConfig.tauxTfcVente,
      plafondCaMicroVente:
          plafondMicroVente ?? currentConfig.plafondCaMicroVente,
      plafondCaMicroService:
          plafondMicroService ?? currentConfig.plafondCaMicroService,
      plafondVlRfr: plafondVlRfr ?? currentConfig.plafondVlRfr,
      lastSyncedAt: syncTime,
      sourceApi: true,
    );
  }

  /// Extrait un Decimal depuis une valeur API (num ou String).
  Decimal? _extractDecimal(dynamic value) {
    if (value is num) {
      return Decimal.parse(value.toString());
    }
    if (value is String) {
      return Decimal.tryParse(value);
    }
    return null;
  }

  /// Simule un scénario VL vs IR pour comparaison.
  ///
  /// Retourne une Map avec les revenus nets dans les deux cas,
  /// basée sur les données de l'API Publicodes.
  ///
  /// [caVente], [caPrestaBIC], [caPrestaBNC]: CA par catégorie
  /// [config]: UrssafConfig courante
  Future<VlVsIrSimulation?> simulerVlVsIr({
    required Decimal caVente,
    required Decimal caPrestaBIC,
    required Decimal caPrestaBNC,
    required UrssafConfig config,
  }) async {
    final totalCA = caVente + caPrestaBIC + caPrestaBNC;
    if (totalCA == Decimal.zero) return null;

    try {
      // Scénario SANS VL
      final resultSansVl = await _evaluateScenario(
        config: config.copyWith(versementLiberatoire: false),
        caVente: caVente,
        caPrestaBIC: caPrestaBIC,
        caPrestaBNC: caPrestaBNC,
      );

      // Scénario AVEC VL
      final resultAvecVl = await _evaluateScenario(
        config: config.copyWith(versementLiberatoire: true),
        caVente: caVente,
        caPrestaBIC: caPrestaBIC,
        caPrestaBNC: caPrestaBNC,
      );

      if (resultSansVl == null || resultAvecVl == null) return null;

      return VlVsIrSimulation(
        revenuNetSansVl: resultSansVl['revenuNet'] ?? Decimal.zero,
        revenuNetApresIrSansVl:
            resultSansVl['revenuNetApresImpot'] ?? Decimal.zero,
        revenuImposableSansVl: resultSansVl['revenuImposable'] ?? Decimal.zero,
        revenuNetAvecVl: resultAvecVl['revenuNet'] ?? Decimal.zero,
        revenuNetApresIrAvecVl:
            resultAvecVl['revenuNetApresImpot'] ?? Decimal.zero,
        montantVl: resultAvecVl['montantVl'] ?? Decimal.zero,
        plafondVlRfr: resultAvecVl['plafondVlRfr'] ?? Decimal.zero,
        caTotal: totalCA,
      );
    } catch (e, s) {
      developer.log(
        '🔴 UrssafSyncService: Échec simulation VL vs IR',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  /// Appelle l'API pour un scénario spécifique et retourne les KPI revenus.
  Future<Map<String, Decimal>?> _evaluateScenario({
    required UrssafConfig config,
    required Decimal caVente,
    required Decimal caPrestaBIC,
    required Decimal caPrestaBNC,
  }) async {
    final situation = _buildSituation(config);

    // Override le CA avec les vrais montants
    if (caVente > Decimal.zero) {
      situation[
              "entreprise . chiffre d'affaires . vente restauration hébergement"] =
          "${caVente.toDouble()} €/an";
    }
    if (caPrestaBIC > Decimal.zero) {
      situation["entreprise . chiffre d'affaires . service BIC"] =
          "${caPrestaBIC.toDouble()} €/an";
    }
    if (caPrestaBNC > Decimal.zero) {
      situation["entreprise . chiffre d'affaires . service BNC"] =
          "${caPrestaBNC.toDouble()} €/an";
    }

    final total = caVente + caPrestaBIC + caPrestaBNC;
    situation["dirigeant . auto-entrepreneur . chiffre d'affaires"] =
        "${total.toDouble()} €/an";

    final expressions = [
      "dirigeant . auto-entrepreneur . revenu net",
      "dirigeant . auto-entrepreneur . revenu net . après impôt",
      "dirigeant . auto-entrepreneur . impôt . revenu imposable",
      "dirigeant . auto-entrepreneur . impôt . versement libératoire . montant",
      "dirigeant . auto-entrepreneur . impôt . versement libératoire . plafond",
    ];

    final response = await _client.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'situation': situation,
        'expressions': expressions,
      }),
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.containsKey('situationError')) return null;

    final evaluate = data['evaluate'] as List<dynamic>;
    final result = <String, Decimal>{};

    for (int i = 0; i < evaluate.length && i < expressions.length; i++) {
      final entry = evaluate[i] as Map<String, dynamic>;
      final v = _extractDecimal(entry['nodeValue']);
      if (v == null) continue;

      switch (i) {
        case 0:
          result['revenuNet'] = v;
          break;
        case 1:
          result['revenuNetApresImpot'] = v;
          break;
        case 2:
          result['revenuImposable'] = v;
          break;
        case 3:
          result['montantVl'] = v;
          break;
        case 4:
          result['plafondVlRfr'] = v;
          break;
      }
    }

    return result;
  }
}

/// Résultat de la simulation VL vs IR.
class VlVsIrSimulation {
  final Decimal revenuNetSansVl;
  final Decimal revenuNetApresIrSansVl;
  final Decimal revenuImposableSansVl;
  final Decimal revenuNetAvecVl;
  final Decimal revenuNetApresIrAvecVl;
  final Decimal montantVl;
  final Decimal plafondVlRfr;
  final Decimal caTotal;

  const VlVsIrSimulation({
    required this.revenuNetSansVl,
    required this.revenuNetApresIrSansVl,
    required this.revenuImposableSansVl,
    required this.revenuNetAvecVl,
    required this.revenuNetApresIrAvecVl,
    required this.montantVl,
    required this.plafondVlRfr,
    required this.caTotal,
  });

  /// Le VL est-il plus avantageux ?
  bool get vlPlusAvantageux => revenuNetApresIrAvecVl > revenuNetApresIrSansVl;

  /// Économie (ou surcoût) annuelle du VL vs IR classique
  Decimal get differenceAnnuelle =>
      revenuNetApresIrAvecVl - revenuNetApresIrSansVl;

  /// Taux d'imposition effectif avec VL
  Decimal get tauxEffectifVl {
    if (caTotal == Decimal.zero) return Decimal.zero;
    final impot = caTotal - revenuNetApresIrAvecVl;
    return ((impot * Decimal.fromInt(100)) / caTotal)
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Taux d'imposition effectif sans VL (IR classique)
  Decimal get tauxEffectifIr {
    if (caTotal == Decimal.zero) return Decimal.zero;
    final impot = caTotal - revenuNetApresIrSansVl;
    return ((impot * Decimal.fromInt(100)) / caTotal)
        .toDecimal(scaleOnInfinitePrecision: 2);
  }
}
