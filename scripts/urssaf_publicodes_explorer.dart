#!/usr/bin/env dart
// ignore_for_file: avoid_print
// ==========================================================================
// PHASE 1 — Script d'exploration de l'API URSSAF Publicodes
// ==========================================================================
//
// Ce script autonome interroge l'API officielle URSSAF "mon-entreprise.fr"
// (moteur de calcul Publicodes) pour extraire tous les taux, seuils et
// cotisations applicables à un Micro-Entrepreneur Artisan mixte
// (prestation de services BIC + vente de marchandises).
//
// Usage :
//   dart run scripts/urssaf_publicodes_explorer.dart
//
// Le résultat complet est affiché en console ET sauvegardé dans
//   scripts/output/urssaf_publicodes_response.json
//
// Prérequis :
//   - Le package http doit être dans pubspec.yaml (déjà présent)
//   - Connexion internet
//
// Documentation API :
//   https://mon-entreprise.urssaf.fr/d%C3%A9veloppeur/api
//   https://publi.codes/
// ==========================================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// CONFIGURATION
// ─────────────────────────────────────────────────────────────────────────────

/// Endpoint officiel de l'API Publicodes Mon-Entreprise URSSAF
const String apiUrl = 'https://mon-entreprise.urssaf.fr/api/v1/evaluate';

/// Timeout pour la requête HTTP
const Duration httpTimeout = Duration(seconds: 30);

// ─────────────────────────────────────────────────────────────────────────────
// SITUATION : Micro-Entrepreneur Artisan Mixte (BIC Prestations + Vente)
// ─────────────────────────────────────────────────────────────────────────────

/// Construit l'objet "situation" décrivant le profil de l'entrepreneur.
///
/// Ce profil correspond aux cas d'usage principaux de notre ERP :
/// - Micro-entrepreneur
/// - Artisan (CMA applicable)
/// - Activité mixte : prestation de services BIC + vente de marchandises
/// - Avec et sans versement libératoire de l'impôt sur le revenu
///
/// Les montants de CA sont des valeurs de test pour vérifier les calculs.
///
/// IMPORTANT : Les noms de clés situation ont été validés contre
/// l'endpoint /api/v1/rules le 2026-02-19.
Map<String, dynamic> buildSituation({
  double caPrestation = 50000, // CA annuel prestations de services
  double caVente = 30000, // CA annuel vente de marchandises
  bool versementLiberatoire = false,
}) {
  return {
    // ── Identité juridique ──
    'entreprise . catégorie juridique': "'EI'",
    'entreprise . catégorie juridique . EI . auto-entrepreneur': 'oui',

    // ── Activités ──
    // Activité principale : prestation de services artisanale (BIC)
    'entreprise . activité': "'artisanale'",
    'entreprise . activité . nature': "'artisanale'",

    // ── Chiffre d'affaires ──
    // Le CA total auto-entrepreneur
    'dirigeant . auto-entrepreneur . chiffre d\'affaires':
        '${caPrestation + caVente} €/an',

    // Ventilation du CA par type d'activité
    // ATTENTION : les clés correctes sont "service BIC" et non "prestations de services . BIC"
    'entreprise . chiffre d\'affaires . vente restauration hébergement':
        '$caVente €/an',
    'entreprise . chiffre d\'affaires . service BIC': '$caPrestation €/an',

    // ── Versement libératoire ──
    'dirigeant . auto-entrepreneur . impôt . versement libératoire':
        versementLiberatoire ? 'oui' : 'non',

    // ── ACRE ──
    'dirigeant . exonérations . ACRE': 'non',

    // ── Domiciliation ──
    'établissement . commune': "'75056'", // Paris (code INSEE)
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPRESSIONS : Toutes les variables pertinentes pour notre ERP
// ─────────────────────────────────────────────────────────────────────────────

/// Liste exhaustive des expressions Publicodes à évaluer.
///
/// Organisées par catégorie pour faciliter l'audit Phase 2.
/// VALIDÉ contre /api/v1/rules le 2026-02-19.
List<String> get expressions => [
      // ══════════════════════════════════════════════════════════════════════
      // 1. COTISATIONS SOCIALES — Montants globaux
      // ══════════════════════════════════════════════════════════════════════

      // Total cotisations + contributions
      'dirigeant . auto-entrepreneur . cotisations et contributions',

      // Cotisations sociales uniquement (sans CFP, TFC)
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations',

      // ══════════════════════════════════════════════════════════════════════
      // 2. TAUX PAR TYPE D'ACTIVITÉ — Le cœur de notre audit
      // ══════════════════════════════════════════════════════════════════════

      // Taux micro-social Vente de marchandises (notre 12.3%)
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . taux',

      // Taux micro-social Prestation de services BIC (notre 21.2%)
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . taux',

      // Taux micro-social Prestation de services BNC (notre 24.6%)
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BNC . taux',

      // Taux BNC CIPAV (si applicable)
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BNC Cipav . taux',

      // ══════════════════════════════════════════════════════════════════════
      // 3. RÉPARTITION DÉTAILLÉE DES COTISATIONS (pour transparence UI)
      // ══════════════════════════════════════════════════════════════════════

      // Répartition pour service BIC
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . maladie-maternité',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . retraite de base',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . retraite complémentaire',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . invalidité-décès',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . service BIC . répartition . autres contributions',

      // Répartition pour vente
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . maladie-maternité',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . retraite de base',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . retraite complémentaire',
      'dirigeant . auto-entrepreneur . cotisations et contributions . cotisations . vente restauration hébergement . répartition . invalidité-décès',

      // ══════════════════════════════════════════════════════════════════════
      // 4. CONTRIBUTIONS — CFP, Taxe CMA (TFC)
      // ══════════════════════════════════════════════════════════════════════

      // Contribution à la Formation Professionnelle (CFP)
      // Artisan: 0.3%, Commerçant: 0.1%, Libéral: 0.2%
      'dirigeant . auto-entrepreneur . cotisations et contributions . CFP',

      // Taxe pour frais de Chambre (TFC) — CMA pour artisans
      'dirigeant . auto-entrepreneur . cotisations et contributions . TFC',
      'dirigeant . auto-entrepreneur . cotisations et contributions . TFC . commerce',
      'dirigeant . auto-entrepreneur . cotisations et contributions . TFC . métiers',
      'dirigeant . auto-entrepreneur . cotisations et contributions . TFC . métiers . taux service',
      'dirigeant . auto-entrepreneur . cotisations et contributions . TFC . métiers . taux vente',

      // ══════════════════════════════════════════════════════════════════════
      // 5. IMPÔT SUR LE REVENU — Versement libératoire
      // ══════════════════════════════════════════════════════════════════════

      'dirigeant . auto-entrepreneur . impôt',
      'dirigeant . auto-entrepreneur . impôt . versement libératoire . montant',
      'dirigeant . auto-entrepreneur . impôt . versement libératoire . plafond',
      'dirigeant . auto-entrepreneur . impôt . revenu imposable',

      // ══════════════════════════════════════════════════════════════════════
      // 6. REVENU NET — Après charges et après impôt
      // ══════════════════════════════════════════════════════════════════════

      'dirigeant . auto-entrepreneur . revenu net',
      'dirigeant . auto-entrepreneur . revenu net . après impôt',

      // ══════════════════════════════════════════════════════════════════════
      // 7. SEUILS TVA — Franchise de TVA (Art. 293 B CGI)
      // ══════════════════════════════════════════════════════════════════════

      // Franchise de TVA globale
      'entreprise . TVA . franchise de TVA',

      // ══════════════════════════════════════════════════════════════════════
      // 8. PLAFONDS MICRO-ENTREPRISE — Seuils CA maximum
      // ══════════════════════════════════════════════════════════════════════

      'entreprise . chiffre d\'affaires . seuil micro',
      'entreprise . chiffre d\'affaires . seuil micro . total',
      'entreprise . chiffre d\'affaires . seuil micro . libérale',
      'entreprise . chiffre d\'affaires . seuil micro . dépassé',

      // ══════════════════════════════════════════════════════════════════════
      // 9. ACRE — Taux réduits pour comparaison
      // ══════════════════════════════════════════════════════════════════════

      'dirigeant . auto-entrepreneur . Acre',
      'dirigeant . auto-entrepreneur . Acre . taux Acre',
      'dirigeant . auto-entrepreneur . Acre . taux service BIC',
      'dirigeant . auto-entrepreneur . Acre . taux service BNC',
      'dirigeant . auto-entrepreneur . Acre . taux vente restauration hébergement',
      'dirigeant . auto-entrepreneur . Acre . taux CIPAV',
      'dirigeant . auto-entrepreneur . éligible à l\'ACRE',

      // ══════════════════════════════════════════════════════════════════════
      // 10. DROM — Taux spéciaux Outre-Mer (pour référence)
      // ══════════════════════════════════════════════════════════════════════

      'dirigeant . auto-entrepreneur . DROM . taux service BIC',
      'dirigeant . auto-entrepreneur . DROM . taux service BNC',
      'dirigeant . auto-entrepreneur . DROM . taux vente restauration hébergement',

      // ══════════════════════════════════════════════════════════════════════
      // 11. VÉRIFICATION CA — Valeurs de situation retournées
      // ══════════════════════════════════════════════════════════════════════

      'dirigeant . auto-entrepreneur . chiffre d\'affaires',
      'entreprise . chiffre d\'affaires',
      'entreprise . chiffre d\'affaires . vente restauration hébergement',
      'entreprise . chiffre d\'affaires . service BIC',
      'entreprise . chiffre d\'affaires . service BNC',

      // ══════════════════════════════════════════════════════════════════════
      // 12. RETRAITE — Trimestres validés (info complémentaire)
      // ══════════════════════════════════════════════════════════════════════

      'protection sociale . retraite . base . cotisée . revenu auto-entrepreneur',
      'protection sociale . retraite . complémentaire . RCI . revenu cotisé auto-entrepreneur',

      // ══════════════════════════════════════════════════════════════════════
      // 13. MICRO-ENTREPRISE — Abattements et régime fiscal
      // ══════════════════════════════════════════════════════════════════════

      'entreprise . imposition . régime . micro-entreprise',
      'entreprise . imposition . régime . micro-entreprise . revenu abattu',
      'entreprise . imposition . régime . micro-entreprise . alerte seuil dépassés',
    ];

// ─────────────────────────────────────────────────────────────────────────────
// REQUÊTE API
// ─────────────────────────────────────────────────────────────────────────────

/// Exécute un appel POST vers l'API Publicodes et retourne la réponse décodée.
Future<Map<String, dynamic>?> callPublicodes({
  required Map<String, dynamic> situation,
  required List<String> expressionsList,
}) async {
  final payload = {
    'situation': situation,
    'expressions': expressionsList,
  };

  print('');
  print('══════════════════════════════════════════════════════════════');
  print('  🔗 Appel API : $apiUrl');
  print('══════════════════════════════════════════════════════════════');
  print('');
  print('📦 Payload envoyé :');
  print(const JsonEncoder.withIndent('  ').convert(payload));
  print('');

  try {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(httpTimeout);

    print('📡 Status HTTP : ${response.statusCode}');
    print('');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('❌ ERREUR HTTP ${response.statusCode}');
      print('   Body : ${response.body}');
      return null;
    }
  } on SocketException catch (e) {
    print('❌ ERREUR RÉSEAU : $e');
    return null;
  } on HttpException catch (e) {
    print('❌ ERREUR HTTP : $e');
    return null;
  } catch (e) {
    print('❌ ERREUR INATTENDUE : $e');
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMATAGE & AFFICHAGE
// ─────────────────────────────────────────────────────────────────────────────

/// Affiche le résultat structuré de l'API dans la console.
void printResults(Map<String, dynamic> response) {
  print('══════════════════════════════════════════════════════════════');
  print('  📊 RÉSULTATS API URSSAF PUBLICODES');
  print('══════════════════════════════════════════════════════════════');
  print('');

  // L'API retourne soit un objet "evaluate" soit directement les résultats
  final evaluate = response['evaluate'] ?? response;

  if (evaluate is List) {
    // Format : liste de résultats dans l'ordre des expressions
    for (int i = 0; i < evaluate.length; i++) {
      final result = evaluate[i];
      final expr = i < expressions.length ? expressions[i] : '???';
      _printSingleResult(expr, result);
    }
  } else if (evaluate is Map) {
    // Format : map expression → résultat
    evaluate.forEach((key, value) {
      _printSingleResult(key.toString(), value);
    });
  } else {
    print('⚠️ Format de réponse inattendu: ${evaluate.runtimeType}');
    print(const JsonEncoder.withIndent('  ').convert(response));
  }
}

void _printSingleResult(String expression, dynamic result) {
  if (result == null) {
    print('  ⚪ $expression');
    print('     → null (expression inconnue ou non applicable)');
    print('');
    return;
  }

  if (result is Map) {
    final nodeValue = result['nodeValue'];
    final unit = result['unit'];
    final missingVariables = result['missingVariables'];

    final unitStr = _formatUnit(unit);
    final valueStr = _formatValue(nodeValue, unitStr);

    // Icône selon le type
    String icon = '📌';
    if (unitStr.contains('%') || unitStr.contains('pourcent')) {
      icon = '📊';
    } else if (unitStr.contains('€')) {
      icon = '💰';
    } else if (nodeValue == true || nodeValue == false) {
      icon = nodeValue == true ? '✅' : '❌';
    }

    print('  $icon $expression');
    print('     → $valueStr');

    if (missingVariables != null &&
        missingVariables is Map &&
        missingVariables.isNotEmpty) {
      final topMissing = missingVariables.entries
          .take(3)
          .map((e) => '${e.key} (${e.value})')
          .join(', ');
      print('     ⚠️ Variables manquantes: $topMissing');
    }
  } else {
    print('  📌 $expression');
    print('     → $result');
  }
  print('');
}

String _formatUnit(dynamic unit) {
  if (unit == null) return '';
  if (unit is String) return unit;
  if (unit is Map) {
    final numerators = unit['numérateurs'] ?? unit['numerators'] ?? [];
    final denominators = unit['dénominateurs'] ?? unit['denominators'] ?? [];
    final numStr = (numerators as List).join('·');
    final denStr = (denominators as List).join('·');
    if (denStr.isNotEmpty) return '$numStr/$denStr';
    return numStr;
  }
  return unit.toString();
}

String _formatValue(dynamic nodeValue, String unitStr) {
  if (nodeValue == null) return 'non applicable';
  if (nodeValue is bool) return nodeValue ? 'oui' : 'non';
  if (nodeValue is num) {
    if (unitStr.contains('%') || unitStr.contains('pourcent')) {
      return '${nodeValue.toStringAsFixed(2)} %';
    }
    if (unitStr.contains('€')) {
      return '${nodeValue.toStringAsFixed(2)} €${unitStr.contains('/') ? ' /${unitStr.split('/').last}' : ''}';
    }
    return '${nodeValue.toStringAsFixed(4)} $unitStr'.trim();
  }
  if (nodeValue is String) return '"$nodeValue"';
  return nodeValue.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPARAISON AVEC NOS VALEURS INTERNES
// ─────────────────────────────────────────────────────────────────────────────

/// Compare les valeurs API avec nos constantes hardcodées dans UrssafConfig.
void printComparisonTable(Map<String, dynamic> response) {
  print('');
  print('══════════════════════════════════════════════════════════════');
  print('  🔍 COMPARAISON API vs VALEURS INTERNES (UrssafConfig)');
  print('══════════════════════════════════════════════════════════════');
  print('');
  print('  Notre ERP utilise actuellement ces valeurs hardcodées :');
  print('  ┌──────────────────────────────────────────────────────┐');
  print('  │ Taux micro-social Vente       :  12.3 %             │');
  print('  │ Taux micro-social BIC Presta  :  21.2 %             │');
  print('  │ Taux micro-social BNC Presta  :  24.6 %             │');
  print('  │ Versement libératoire Vente   :   1.0 %             │');
  print('  │ Versement libératoire BIC     :   1.7 %             │');
  print('  │ Versement libératoire BNC     :   2.2 %             │');
  print('  │ CFP Artisan                   :   0.3 %             │');
  print('  │ CFP Commerçant                :   0.1 %             │');
  print('  │ CFP Libéral                   :   0.2 %             │');
  print('  │ Plafond CA Vente              : 188 700 €           │');
  print('  │ Plafond CA Service            :  77 700 €           │');
  print('  │ Seuil TVA base Vente          :  91 900 €           │');
  print('  │ Seuil TVA majoré Vente        : 101 000 €           │');
  print('  │ Seuil TVA base Service        :  36 800 €           │');
  print('  │ Seuil TVA majoré Service      :  39 100 €           │');
  print('  └──────────────────────────────────────────────────────┘');
  print('');
  print('  → Comparez ces valeurs avec la réponse API ci-dessus');
  print('    pour identifier toute divergence.');
  print('');
}

// ─────────────────────────────────────────────────────────────────────────────
// SAUVEGARDE JSON
// ─────────────────────────────────────────────────────────────────────────────

/// Sauvegarde la réponse complète dans un fichier JSON.
Future<void> saveToFile(Map<String, dynamic> fullOutput) async {
  final outputDir = Directory('scripts/output');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  const filePath = 'scripts/output/urssaf_publicodes_response.json';
  final filePathTimestamped =
      'scripts/output/urssaf_publicodes_$timestamp.json';

  const encoder = JsonEncoder.withIndent('  ');
  final jsonStr = encoder.convert(fullOutput);

  // Fichier principal (écrasé à chaque exécution)
  await File(filePath).writeAsString(jsonStr);
  // Fichier horodaté (historique)
  await File(filePathTimestamped).writeAsString(jsonStr);

  print('');
  print('💾 Réponse sauvegardée :');
  print('   → $filePath');
  print('   → $filePathTimestamped');
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — ORCHESTRATION
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║  URSSAF PUBLICODES EXPLORER — Phase 1                      ║');
  print('║  ERP Artisan · Micro-Entrepreneur · Taux & Seuils 2026     ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');

  // ── Scénario 1 : SANS versement libératoire ──
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('  SCÉNARIO 1 : Artisan Mixte — SANS versement libératoire');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final situationSansVL = buildSituation(
    caPrestation: 50000,
    caVente: 30000,
    versementLiberatoire: false,
  );

  final response1 = await callPublicodes(
    situation: situationSansVL,
    expressionsList: expressions,
  );

  if (response1 != null) {
    printResults(response1);
  }

  // ── Scénario 2 : AVEC versement libératoire ──
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('  SCÉNARIO 2 : Artisan Mixte — AVEC versement libératoire');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final situationAvecVL = buildSituation(
    caPrestation: 50000,
    caVente: 30000,
    versementLiberatoire: true,
  );

  final response2 = await callPublicodes(
    situation: situationAvecVL,
    expressionsList: expressions,
  );

  if (response2 != null) {
    printResults(response2);
  }

  // ── Scénario 3 : Libéral BNC (pour comparaison taux BNC) ──
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('  SCÉNARIO 3 : Libéral (BNC) — pour vérification taux 24.6%');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final situationBNC = {
    'entreprise . catégorie juridique': "'EI'",
    'entreprise . catégorie juridique . EI . auto-entrepreneur': 'oui',
    'entreprise . activité': "'libérale'",
    'entreprise . activité . nature': "'libérale'",
    'dirigeant . auto-entrepreneur . chiffre d\'affaires': '50000 €/an',
    'entreprise . chiffre d\'affaires . service BNC': '50000 €/an',
    'dirigeant . auto-entrepreneur . impôt . versement libératoire': 'non',
    'dirigeant . exonérations . ACRE': 'non',
    'établissement . commune': "'75056'",
  };

  final response3 = await callPublicodes(
    situation: situationBNC,
    expressionsList: expressions,
  );

  if (response3 != null) {
    printResults(response3);
  }

  // ── Tableau comparatif ──
  printComparisonTable({});

  // ── Sauvegarde consolidée ──
  final fullOutput = {
    'metadata': {
      'generatedAt': DateTime.now().toIso8601String(),
      'apiEndpoint': apiUrl,
      'erpVersion': 'ERP Artisan 2026',
      'description':
          'Extraction exhaustive des taux et seuils URSSAF Publicodes pour Micro-Entrepreneur',
    },
    'scenarios': {
      'scenario_1_sans_versement_liberatoire': {
        'description':
            'Artisan Mixte (Prestation BIC 50k€ + Vente 30k€) — Sans VL',
        'situation': situationSansVL,
        'expressions': expressions,
        'response': response1,
      },
      'scenario_2_avec_versement_liberatoire': {
        'description':
            'Artisan Mixte (Prestation BIC 50k€ + Vente 30k€) — Avec VL',
        'situation': situationAvecVL,
        'expressions': expressions,
        'response': response2,
      },
      'scenario_3_liberal_bnc': {
        'description': 'Libéral BNC (50k€) — Vérification taux 24.6%',
        'situation': situationBNC,
        'expressions': expressions,
        'response': response3,
      },
    },
    'internal_reference_values': {
      'taux_micro_social': {
        'vente_marchandises': '12.3%',
        'prestation_BIC': '21.2%',
        'prestation_BNC': '24.6%',
      },
      'versement_liberatoire': {
        'vente': '1.0%',
        'BIC': '1.7%',
        'BNC': '2.2%',
      },
      'cfp': {
        'artisan': '0.3%',
        'commercant': '0.1%',
        'liberal': '0.2%',
      },
      'plafonds_ca': {
        'vente': '188700',
        'service': '77700',
      },
      'seuils_tva': {
        'base_vente': '91900',
        'majore_vente': '101000',
        'base_service': '36800',
        'majore_service': '39100',
      },
    },
  };

  await saveToFile(fullOutput);

  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║  ✅ EXTRACTION TERMINÉE                                     ║');
  print('║                                                              ║');
  print('║  Prochaine étape : analyser le JSON pour Phase 2 (Audit)    ║');
  print('║  → Comparer les taux API vs UrssafConfig hardcodés          ║');
  print('║  → Identifier les expressions manquantes ou divergentes      ║');
  print('║  → Refactorer le modèle pour stocker la source API          ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');
}
