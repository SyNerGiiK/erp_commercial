import 'dart:math';
import 'package:decimal/decimal.dart';
import 'enums/entreprise_enums.dart';

/// Configuration URSSAF Universelle - Tous types d'entreprises França 2026
/// Couvre: Micro-Entrepreneur, TNS, Assimilé Salarié, Dividendes IS
class UrssafConfig {
  // ==========================================
  // CONSTANTES OFFICIELLES 2026
  // ==========================================

  static final Decimal pass2026 = Decimal.parse('48060'); // Plafond Annuel SS
  static final Decimal smicMensuel2026 = Decimal.parse('1801'); // Brut

  // === Taux MICRO-ENTREPRENEUR Standards ===
  static final Decimal tauxMicroVenteStd = Decimal.parse('12.3');
  static final Decimal tauxMicroServiceBICStd = Decimal.parse('21.2');
  static final Decimal tauxMicroServiceBNCStd = Decimal.parse('25.6'); // 2026
  static final Decimal tauxMicroLiberalCIPAVStd = Decimal.parse('23.2');
  static final Decimal tauxMicroMeublesStd = Decimal.parse('6.0');

  // === Taux ACRE Année 1 (50% réduction) ===
  static final Decimal tauxMicroVenteAcre = Decimal.parse('6.2');
  static final Decimal tauxMicroServiceBICAcre = Decimal.parse('10.6');
  static final Decimal tauxMicroServiceBNCAcre = Decimal.parse('13.1'); // 2026
  static final Decimal tauxMicroLiberalCIPAVAcre = Decimal.parse('11.6');
  static final Decimal tauxMicroMeublesAcre = Decimal.parse('3.0');

  // ==========================================
  // IDENTIFIANTS
  // ==========================================

  final String? id;
  final String? userId;

  // ==========================================
  // ACRE (Micro-Entrepreneur uniquement)
  // ==========================================

  /// ACRE activée (micro-entrepreneur)
  final bool accreActive;

  /// Année ACRE (1, 2, 3, 4+)
  /// An 1: -50%, An 2: -25%, An 3: -10%, An 4+: 0%
  final int accreAnnee;

  // ==========================================
  // MICRO-ENTREPRENEUR
  // ==========================================

  // Taux Cotisations
  final Decimal tauxMicroVente; // Vente marchandises (12.3%)
  final Decimal tauxMicroServiceBIC; // Services BIC (21.2%)
  final Decimal tauxMicroServiceBNC; // Services BNC SSI (25.6% en 2026)
  final Decimal tauxMicroLiberalCIPAV; // Libéral CIPAV (23.2%)
  final Decimal tauxMicroMeubles; // Meublés tourisme (6.0%)

  // Formation Professionnelle (CFP)
  final Decimal tauxCfpMicroVente; // 0.1%
  final Decimal tauxCfpMicroService; // 0.3%
  final Decimal tauxCfpMicroLiberal; // 0.2%

  // Plafonds CA
  final Decimal plafondCaMicroVente; // 188 700€
  final Decimal plafondCaMicroService; // 77 700€

  // Seuils TVA
  final Decimal seuilTvaMicroVente; // 91 900€
  final Decimal seuilTvaMicroService; // 36 800€

  // ==========================================
  // TNS - Travailleur Non Salarié
  // ==========================================

  // Abattement 26% (réforme 2025/2026)
  final Decimal abattementTNS; // 26%
  final Decimal abattementMinTNS; // 1.76% PASS
  final Decimal abattementMaxTNS; // 130% PASS

  // Maladie-Maternité (progressif 0% à 6.5%)
  final Decimal tauxMaladieTNSMin; // 0%
  final Decimal tauxMaladieTNSMax; // 6.5%

  // Indemnités Journalières
  final Decimal tauxIJTNS; // 0.85%

  // Retraite de Base
  final Decimal tauxRetraiteBaseTNST1; // 17.75% (dans PASS)
  final Decimal tauxRetraiteBaseTNST2; // 0.60% (au-delà PASS)

  // Retraite Complémentaire
  final Decimal tauxRetraiteCompTNST1; // 7% (1ère tranche 41 136€)
  final Decimal tauxRetraiteCompTNST2; // 8% (2ème tranche 206 680€)

  // Invalidité-Décès
  final Decimal tauxInvaliditeDecesTNS; // 1.30%

  // Allocations Familiales (progressif 0% à 3.10%)
  final Decimal tauxAllocFamTNSMin; // 0%
  final Decimal tauxAllocFamTNSMax; // 3.10%

  // CSG-CRDS (non réductible ACRE)
  final Decimal tauxCsgCrdsTNS; // 9.70%

  // Formation Professionnelle
  final Decimal tauxCfpArtisan; // 0.29%
  final Decimal tauxCfpCommercant; // 0.25%

  // ==========================================
  // ASSIMILÉ SALARIÉ (SASU, SAS, Gérant Min)
  // ==========================================

  // === Cotisations SALARIALES ===

  // Vieillesse
  final Decimal tauxVieillesseSalT1; // 6.90% (plafonnée)
  final Decimal tauxVieillesseSalT2; // 0.40% (déplafonnée)

  // Retraite Complémentaire
  final Decimal tauxRetraiteCompSalT1; // 3.15% (T1 < PASS)
  final Decimal tauxRetraiteCompSalT2; // 8.64% (T2 < 8 PASS)

  // APEC
  final Decimal tauxAPECSal; // 0.024%

  // CSG-CRDS
  final Decimal tauxCSGDeductible; // 6.80%
  final Decimal tauxCSGNonDeductible; // 2.40%
  final Decimal tauxCRDS; // 0.50%

  // === Cotisations PATRONALES ===

  // Maladie
  final Decimal tauxMaladiePatronal1; // 7% (≤ 2.5 SMIC)
  final Decimal tauxMaladiePatronal2; // 13% (> 2.5 SMIC)

  // Vieillesse
  final Decimal tauxVieillessePatT1; // 8.55% (plafonnée)
  final Decimal tauxVieillessePatT2; // 2.11% (déplafonnée, hausse 2026)

  // Allocations Familiales
  final Decimal tauxAllocFamPatronal1; // 3.45% (< 3.5 SMIC)
  final Decimal tauxAllocFamPatronal2; // 5.25% (≥ 3.5 SMIC)

  // Chômage
  final Decimal tauxChomagePatronal; // 4.05%

  // Retraite Complémentaire
  final Decimal tauxRetraiteCompPatT1; // 4.72%
  final Decimal tauxRetraiteCompPatT2; // 12.95%

  // APEC Patronal
  final Decimal tauxAPECPat; // 0.036%

  // Accident du Travail (variable selon activité)
  final Decimal tauxAccidentTravail; // 0.5% à 5% (défaut 1%)

  // Réduction Générale (ex-Fillon)
  final Decimal tauxReductionMax50; // 39.81% (< 50 salariés)
  final Decimal tauxReductionMax50Plus; // 40.21% (≥ 50 salariés)

  // ==========================================
  // DIVIDENDES (Sociétés à l'IS)
  // ==========================================

  // CSG-CRDS sur dividendes
  final Decimal tauxCSGDividendes; // 10.6% (hausse 2026)

  // Prélèvement Forfaitaire Unique (Flat Tax)
  final Decimal tauxPFU_IR; // 12.8%
  final Decimal tauxPFU_Total; // 30% (17.2% + 12.8%)

  // Impôt sur les Sociétés
  final Decimal tauxIS_Reduit; // 15% (≤ 42 500€)
  final Decimal tauxIS_Normal; // 25%

  // ==========================================
  // CONSTRUCTEUR
  // ==========================================

  UrssafConfig({
    this.id,
    this.userId,
    // ACRE
    this.accreActive = false,
    this.accreAnnee = 1,
    // Micro-Entrepreneur
    Decimal? tauxMicroVente,
    Decimal? tauxMicroServiceBIC,
    Decimal? tauxMicroServiceBNC,
    Decimal? tauxMicroLiberalCIPAV,
    Decimal? tauxMicroMeubles,
    Decimal? tauxCfpMicroVente,
    Decimal? tauxCfpMicroService,
    Decimal? tauxCfpMicroLiberal,
    Decimal? plafondCaMicroVente,
    Decimal? plafondCaMicroService,
    Decimal? seuilTvaMicroVente,
    Decimal? seuilTvaMicroService,
    // TNS
    Decimal? abattementTNS,
    Decimal? abattementMinTNS,
    Decimal? abattementMaxTNS,
    Decimal? tauxMaladieTNSMin,
    Decimal? tauxMaladieTNSMax,
    Decimal? tauxIJTNS,
    Decimal? tauxRetraiteBaseTNST1,
    Decimal? tauxRetraiteBaseTNST2,
    Decimal? tauxRetraiteCompTNST1,
    Decimal? tauxRetraiteCompTNST2,
    Decimal? tauxInvaliditeDecesTNS,
    Decimal? tauxAllocFamTNSMin,
    Decimal? tauxAllocFamTNSMax,
    Decimal? tauxCsgCrdsTNS,
    Decimal? tauxCfpArtisan,
    Decimal? tauxCfpCommercant,
    // Assimilé Salarié
    Decimal? tauxVieillesseSalT1,
    Decimal? tauxVieillesseSalT2,
    Decimal? tauxRetraiteCompSalT1,
    Decimal? tauxRetraiteCompSalT2,
    Decimal? tauxAPECSal,
    Decimal? tauxCSGDeductible,
    Decimal? tauxCSGNonDeductible,
    Decimal? tauxCRDS,
    Decimal? tauxMaladiePatronal1,
    Decimal? tauxMaladiePatronal2,
    Decimal? tauxVieillessePatT1,
    Decimal? tauxVieillessePatT2,
    Decimal? tauxAllocFamPatronal1,
    Decimal? tauxAllocFamPatronal2,
    Decimal? tauxChomagePatronal,
    Decimal? tauxRetraiteCompPatT1,
    Decimal? tauxRetraiteCompPatT2,
    Decimal? tauxAPECPat,
    Decimal? tauxAccidentTravail,
    Decimal? tauxReductionMax50,
    Decimal? tauxReductionMax50Plus,
    // Dividendes
    Decimal? tauxCSGDividendes,
    Decimal? tauxPFU_IR,
    Decimal? tauxPFU_Total,
    Decimal? tauxIS_Reduit,
    Decimal? tauxIS_Normal,
  })  : // Micro
        tauxMicroVente = tauxMicroVente ?? tauxMicroVenteStd,
        tauxMicroServiceBIC = tauxMicroServiceBIC ?? tauxMicroServiceBICStd,
        tauxMicroServiceBNC = tauxMicroServiceBNC ?? tauxMicroServiceBNCStd,
        tauxMicroLiberalCIPAV =
            tauxMicroLiberalCIPAV ?? tauxMicroLiberalCIPAVStd,
        tauxMicroMeubles = tauxMicroMeubles ?? tauxMicroMeublesStd,
        tauxCfpMicroVente = tauxCfpMicroVente ?? Decimal.parse('0.1'),
        tauxCfpMicroService = tauxCfpMicroService ?? Decimal.parse('0.3'),
        tauxCfpMicroLiberal = tauxCfpMicroLiberal ?? Decimal.parse('0.2'),
        plafondCaMicroVente = plafondCaMicroVente ?? Decimal.parse('188700'),
        plafondCaMicroService = plafondCaMicroService ?? Decimal.parse('77700'),
        seuilTvaMicroVente = seuilTvaMicroVente ?? Decimal.parse('91900'),
        seuilTvaMicroService = seuilTvaMicroService ?? Decimal.parse('36800'),
        // TNS
        abattementTNS = abattementTNS ?? Decimal.parse('26'),
        abattementMinTNS = abattementMinTNS ?? Decimal.parse('1.76'),
        abattementMaxTNS = abattementMaxTNS ?? Decimal.parse('130'),
        tauxMaladieTNSMin = tauxMaladieTNSMin ?? Decimal.zero,
        tauxMaladieTNSMax = tauxMaladieTNSMax ?? Decimal.parse('6.5'),
        tauxIJTNS = tauxIJTNS ?? Decimal.parse('0.85'),
        tauxRetraiteBaseTNST1 = tauxRetraiteBaseTNST1 ?? Decimal.parse('17.75'),
        tauxRetraiteBaseTNST2 = tauxRetraiteBaseTNST2 ?? Decimal.parse('0.60'),
        tauxRetraiteCompTNST1 = tauxRetraiteCompTNST1 ?? Decimal.parse('7.0'),
        tauxRetraiteCompTNST2 = tauxRetraiteCompTNST2 ?? Decimal.parse('8.0'),
        tauxInvaliditeDecesTNS =
            tauxInvaliditeDecesTNS ?? Decimal.parse('1.30'),
        tauxAllocFamTNSMin = tauxAllocFamTNSMin ?? Decimal.zero,
        tauxAllocFamTNSMax = tauxAllocFamTNSMax ?? Decimal.parse('3.10'),
        tauxCsgCrdsTNS = tauxCsgCrdsTNS ?? Decimal.parse('9.70'),
        tauxCfpArtisan = tauxCfpArtisan ?? Decimal.parse('0.29'),
        tauxCfpCommercant = tauxCfpCommercant ?? Decimal.parse('0.25'),
        // Assimilé Salarié
        tauxVieillesseSalT1 = tauxVieillesseSalT1 ?? Decimal.parse('6.90'),
        tauxVieillesseSalT2 = tauxVieillesseSalT2 ?? Decimal.parse('0.40'),
        tauxRetraiteCompSalT1 = tauxRetraiteCompSalT1 ?? Decimal.parse('3.15'),
        tauxRetraiteCompSalT2 = tauxRetraiteCompSalT2 ?? Decimal.parse('8.64'),
        tauxAPECSal = tauxAPECSal ?? Decimal.parse('0.024'),
        tauxCSGDeductible = tauxCSGDeductible ?? Decimal.parse('6.80'),
        tauxCSGNonDeductible = tauxCSGNonDeductible ?? Decimal.parse('2.40'),
        tauxCRDS = tauxCRDS ?? Decimal.parse('0.50'),
        tauxMaladiePatronal1 = tauxMaladiePatronal1 ?? Decimal.parse('7.0'),
        tauxMaladiePatronal2 = tauxMaladiePatronal2 ?? Decimal.parse('13.0'),
        tauxVieillessePatT1 = tauxVieillessePatT1 ?? Decimal.parse('8.55'),
        tauxVieillessePatT2 = tauxVieillessePatT2 ?? Decimal.parse('2.11'),
        tauxAllocFamPatronal1 = tauxAllocFamPatronal1 ?? Decimal.parse('3.45'),
        tauxAllocFamPatronal2 = tauxAllocFamPatronal2 ?? Decimal.parse('5.25'),
        tauxChomagePatronal = tauxChomagePatronal ?? Decimal.parse('4.05'),
        tauxRetraiteCompPatT1 = tauxRetraiteCompPatT1 ?? Decimal.parse('4.72'),
        tauxRetraiteCompPatT2 = tauxRetraiteCompPatT2 ?? Decimal.parse('12.95'),
        tauxAPECPat = tauxAPECPat ?? Decimal.parse('0.036'),
        tauxAccidentTravail = tauxAccidentTravail ?? Decimal.parse('1.0'),
        tauxReductionMax50 = tauxReductionMax50 ?? Decimal.parse('39.81'),
        tauxReductionMax50Plus =
            tauxReductionMax50Plus ?? Decimal.parse('40.21'),
        // Dividendes
        tauxCSGDividendes = tauxCSGDividendes ?? Decimal.parse('10.6'),
        tauxPFU_IR = tauxPFU_IR ?? Decimal.parse('12.8'),
        tauxPFU_Total = tauxPFU_Total ?? Decimal.parse('30.0'),
        tauxIS_Reduit = tauxIS_Reduit ?? Decimal.parse('15.0'),
        tauxIS_Normal = tauxIS_Normal ?? Decimal.parse('25.0');

  // ==========================================
  // MÉTHODES CALCULÉES - MICRO-ENTREPRENEUR
  // ==========================================

  /// Taux micro effectif après ACRE (si applicable)
  Decimal getTauxMicroEffectif(Decimal tauxBase) {
    if (!accreActive) return tauxBase;

    final reductionPct = switch (accreAnnee) {
      1 => Decimal.fromInt(50), // -50%
      2 => Decimal.fromInt(25), // -25%
      3 => Decimal.fromInt(10), // -10%
      _ => Decimal.zero, // 0%
    };

    final reduction = (reductionPct / Decimal.fromInt(100)).toDecimal();
    final facteurReduction = Decimal.one - reduction;
    final resultat = tauxBase * facteurReduction;
    return resultat;
  }

  /// Calcul cotisations micro-entrepreneur (CA × taux)
  Decimal calculerCotisationsMicro(Decimal ca, TypeEntreprise type) {
    Decimal tauxBase;
    Decimal cfp;

    switch (type) {
      case TypeEntreprise.microEntrepreneurVente:
        tauxBase = tauxMicroVente;
        cfp = tauxCfpMicroVente;
        break;
      case TypeEntreprise.microEntrepreneurServiceBIC:
        tauxBase = tauxMicroServiceBIC;
        cfp = tauxCfpMicroService;
        break;
      case TypeEntreprise.microEntrepreneurServiceBNC:
        tauxBase = tauxMicroServiceBNC;
        cfp = tauxCfpMicroService;
        break;
      case TypeEntreprise.microEntrepreneurLiberalCIPAV:
        tauxBase = tauxMicroLiberalCIPAV;
        cfp = tauxCfpMicroLiberal;
        break;
      case TypeEntreprise.microEntrepreneurMeubles:
        tauxBase = tauxMicroMeubles;
        cfp = tauxCfpMicroVente;
        break;
      default:
        return Decimal.zero;
    }

    final tauxEffectif = getTauxMicroEffectif(tauxBase);
    final totalTaux = tauxEffectif + cfp;

    return (ca * totalTaux / Decimal.fromInt(100)).toDecimal();
  }

  // ==========================================
  // MÉTHODES CALCULÉES - TNS
  // ==========================================

  /// Calcul abattement TNS 26% (min/max)
  Decimal calculerAbattementTNS(Decimal revenuBrut) {
    final abattementCalcule = revenuBrut * abattementTNS / Decimal.fromInt(100);
    final abattementMin = pass2026 * abattementMinTNS / Decimal.fromInt(100);
    final abattementMax = pass2026 * abattementMaxTNS / Decimal.fromInt(100);

    if (abattementCalcule < abattementMin) return abattementMin.toDecimal();
    if (abattementCalcule > abattementMax) return abattementMax.toDecimal();
    return abattementCalcule.toDecimal();
  }

  /// Calcul cotisations TNS totales (simplifié)
  /// NOTE: Calcul réel nécessite progressivité maladie/alloc fam
  Decimal calculerCotisationsTNS(Decimal revenuBrut) {
    final abattement = calculerAbattementTNS(revenuBrut);
    final assiette = revenuBrut - abattement;

    // Indemnités Journalières
    final ij = min(assiette, pass2026) * tauxIJTNS / Decimal.fromInt(100);

    // Retraite Base
    final retraiteBaseT1 =
        min(assiette, pass2026) * tauxRetraiteBaseTNST1 / Decimal.fromInt(100);
    final retraiteBaseT2 = max(Decimal.zero, assiette - pass2026) *
        tauxRetraiteBaseTNST2 /
        Decimal.fromInt(100);

    // Retraite Complémentaire (tranche 1: 41k€, tranche 2: 206k€)
    final plafondCompT1 = Decimal.parse('41136');
    final plafondCompT2 = Decimal.parse('206680');
    final retraiteCompT1 = min(assiette, plafondCompT1) *
        tauxRetraiteCompTNST1 /
        Decimal.fromInt(100);
    final retraiteCompT2 =
        min(max(Decimal.zero, assiette - plafondCompT1), plafondCompT2) *
            tauxRetraiteCompTNST2 /
            Decimal.fromInt(100);

    // Invalidité-Décès
    final invalidite =
        min(assiette, pass2026) * tauxInvaliditeDecesTNS / Decimal.fromInt(100);

    // CSG-CRDS (sur revenu + cotisations)
    final csgCrds = assiette * tauxCsgCrdsTNS / Decimal.fromInt(100);

    return (ij +
            retraiteBaseT1 +
            retraiteBaseT2 +
            retraiteCompT1 +
            retraiteCompT2 +
            invalidite +
            csgCrds)
        .toDecimal();
  }

  // ==========================================
  // HELPER: Min/Max Decimal
  // ==========================================

  Decimal min(Decimal a, Decimal b) => a < b ? a : b;
  Decimal max(Decimal a, Decimal b) => a > b ? a : b;

  // ==========================================
  // FROM MAP
  // ==========================================

  factory UrssafConfig.fromMap(Map<String, dynamic> map) {
    return UrssafConfig(
      id: map['id'],
      userId: map['user_id'],
      accreActive: map['accre_active'] ?? false,
      accreAnnee: map['accre_annee'] ?? 1,
      // Micro
      tauxMicroVente: _parseDecimal(map['taux_micro_vente'], tauxMicroVenteStd),
      tauxMicroServiceBIC:
          _parseDecimal(map['taux_micro_service_bic'], tauxMicroServiceBICStd),
      tauxMicroServiceBNC:
          _parseDecimal(map['taux_micro_service_bnc'], tauxMicroServiceBNCStd),
      tauxMicroLiberalCIPAV: _parseDecimal(
          map['taux_micro_liberal_cipav'], tauxMicroLiberalCIPAVStd),
      tauxMicroMeubles:
          _parseDecimal(map['taux_micro_meubles'], tauxMicroMeublesStd),
      tauxCfpMicroVente:
          _parseDecimal(map['taux_cfp_micro_vente'], Decimal.parse('0.1')),
      tauxCfpMicroService:
          _parseDecimal(map['taux_cfp_micro_service'], Decimal.parse('0.3')),
      tauxCfpMicroLiberal:
          _parseDecimal(map['taux_cfp_micro_liberal'], Decimal.parse('0.2')),
      plafondCaMicroVente:
          _parseDecimal(map['plafond_ca_micro_vente'], Decimal.parse('188700')),
      plafondCaMicroService: _parseDecimal(
          map['plafond_ca_micro_service'], Decimal.parse('77700')),
      seuilTvaMicroVente:
          _parseDecimal(map['seuil_tva_micro_vente'], Decimal.parse('91900')),
      seuilTvaMicroService:
          _parseDecimal(map['seuil_tva_micro_service'], Decimal.parse('36800')),
      // TNS
      abattementTNS: _parseDecimal(map['abattement_tns'], Decimal.parse('26')),
      abattementMinTNS:
          _parseDecimal(map['abattement_min_tns'], Decimal.parse('1.76')),
      abattementMaxTNS:
          _parseDecimal(map['abattement_max_tns'], Decimal.parse('130')),
      tauxMaladieTNSMin:
          _parseDecimal(map['taux_maladie_tns_min'], Decimal.zero),
      tauxMaladieTNSMax:
          _parseDecimal(map['taux_maladie_tns_max'], Decimal.parse('6.5')),
      tauxIJTNS: _parseDecimal(map['taux_ij_tns'], Decimal.parse('0.85')),
      tauxRetraiteBaseTNST1: _parseDecimal(
          map['taux_retraite_base_tns_t1'], Decimal.parse('17.75')),
      tauxRetraiteBaseTNST2: _parseDecimal(
          map['taux_retraite_base_tns_t2'], Decimal.parse('0.60')),
      tauxRetraiteCompTNST1:
          _parseDecimal(map['taux_retraite_comp_tns_t1'], Decimal.parse('7.0')),
      tauxRetraiteCompTNST2:
          _parseDecimal(map['taux_retraite_comp_tns_t2'], Decimal.parse('8.0')),
      tauxInvaliditeDecesTNS: _parseDecimal(
          map['taux_invalidite_deces_tns'], Decimal.parse('1.30')),
      tauxAllocFamTNSMin:
          _parseDecimal(map['taux_alloc_fam_tns_min'], Decimal.zero),
      tauxAllocFamTNSMax:
          _parseDecimal(map['taux_alloc_fam_tns_max'], Decimal.parse('3.10')),
      tauxCsgCrdsTNS:
          _parseDecimal(map['taux_csg_crds_tns'], Decimal.parse('9.70')),
      tauxCfpArtisan:
          _parseDecimal(map['taux_cfp_artisan'], Decimal.parse('0.29')),
      tauxCfpCommercant:
          _parseDecimal(map['taux_cfp_commercant'], Decimal.parse('0.25')),
      // Assimilé Salarié
      tauxVieillesseSalT1:
          _parseDecimal(map['taux_vieillesse_sal_t1'], Decimal.parse('6.90')),
      tauxVieillesseSalT2:
          _parseDecimal(map['taux_vieillesse_sal_t2'], Decimal.parse('0.40')),
      tauxRetraiteCompSalT1: _parseDecimal(
          map['taux_retraite_comp_sal_t1'], Decimal.parse('3.15')),
      tauxRetraiteCompSalT2: _parseDecimal(
          map['taux_retraite_comp_sal_t2'], Decimal.parse('8.64')),
      tauxAPECSal: _parseDecimal(map['taux_apec_sal'], Decimal.parse('0.024')),
      tauxCSGDeductible:
          _parseDecimal(map['taux_csg_deductible'], Decimal.parse('6.80')),
      tauxCSGNonDeductible:
          _parseDecimal(map['taux_csg_non_deductible'], Decimal.parse('2.40')),
      tauxCRDS: _parseDecimal(map['taux_crds'], Decimal.parse('0.50')),
      tauxMaladiePatronal1:
          _parseDecimal(map['taux_maladie_patronal1'], Decimal.parse('7.0')),
      tauxMaladiePatronal2:
          _parseDecimal(map['taux_maladie_patronal2'], Decimal.parse('13.0')),
      tauxVieillessePatT1:
          _parseDecimal(map['taux_vieillesse_pat_t1'], Decimal.parse('8.55')),
      tauxVieillessePatT2:
          _parseDecimal(map['taux_vieillesse_pat_t2'], Decimal.parse('2.11')),
      tauxAllocFamPatronal1:
          _parseDecimal(map['taux_alloc_fam_patronal1'], Decimal.parse('3.45')),
      tauxAllocFamPatronal2:
          _parseDecimal(map['taux_alloc_fam_patronal2'], Decimal.parse('5.25')),
      tauxChomagePatronal:
          _parseDecimal(map['taux_chomage_patronal'], Decimal.parse('4.05')),
      tauxRetraiteCompPatT1: _parseDecimal(
          map['taux_retraite_comp_pat_t1'], Decimal.parse('4.72')),
      tauxRetraiteCompPatT2: _parseDecimal(
          map['taux_retraite_comp_pat_t2'], Decimal.parse('12.95')),
      tauxAPECPat: _parseDecimal(map['taux_apec_pat'], Decimal.parse('0.036')),
      tauxAccidentTravail:
          _parseDecimal(map['taux_accident_travail'], Decimal.parse('1.0')),
      tauxReductionMax50:
          _parseDecimal(map['taux_reduction_max50'], Decimal.parse('39.81')),
      tauxReductionMax50Plus: _parseDecimal(
          map['taux_reduction_max50plus'], Decimal.parse('40.21')),
      // Dividendes
      tauxCSGDividendes:
          _parseDecimal(map['taux_csg_dividendes'], Decimal.parse('10.6')),
      tauxPFU_IR: _parseDecimal(map['taux_pfu_ir'], Decimal.parse('12.8')),
      tauxPFU_Total:
          _parseDecimal(map['taux_pfu_total'], Decimal.parse('30.0')),
      tauxIS_Reduit:
          _parseDecimal(map['taux_is_reduit'], Decimal.parse('15.0')),
      tauxIS_Normal:
          _parseDecimal(map['taux_is_normal'], Decimal.parse('25.0')),
    );
  }

  static Decimal _parseDecimal(dynamic value, Decimal defaultValue) {
    if (value == null) return defaultValue;
    try {
      return Decimal.parse(value.toString());
    } catch (_) {
      return defaultValue;
    }
  }

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'accre_active': accreActive,
      'accre_annee': accreAnnee,
      // Micro
      'taux_micro_vente': tauxMicroVente.toString(),
      'taux_micro_service_bic': tauxMicroServiceBIC.toString(),
      'taux_micro_service_bnc': tauxMicroServiceBNC.toString(),
      'taux_micro_liberal_cipav': tauxMicroLiberalCIPAV.toString(),
      'taux_micro_meubles': tauxMicroMeubles.toString(),
      'taux_cfp_micro_vente': tauxCfpMicroVente.toString(),
      'taux_cfp_micro_service': tauxCfpMicroService.toString(),
      'taux_cfp_micro_liberal': tauxCfpMicroLiberal.toString(),
      'plafond_ca_micro_vente': plafondCaMicroVente.toString(),
      'plafond_ca_micro_service': plafondCaMicroService.toString(),
      'seuil_tva_micro_vente': seuilTvaMicroVente.toString(),
      'seuil_tva_micro_service': seuilTvaMicroService.toString(),
      //  TNS
      'abattement_tns': abattementTNS.toString(),
      'abattement_min_tns': abattementMinTNS.toString(),
      'abattement_max_tns': abattementMaxTNS.toString(),
      'taux_maladie_tns_min': tauxMaladieTNSMin.toString(),
      'taux_maladie_tns_max': tauxMaladieTNSMax.toString(),
      'taux_ij_tns': tauxIJTNS.toString(),
      'taux_retraite_base_tns_t1': tauxRetraiteBaseTNST1.toString(),
      'taux_retraite_base_tns_t2': tauxRetraiteBaseTNST2.toString(),
      'taux_retraite_comp_tns_t1': tauxRetraiteCompTNST1.toString(),
      'taux_retraite_comp_tns_t2': tauxRetraiteCompTNST2.toString(),
      'taux_invalidite_deces_tns': tauxInvaliditeDecesTNS.toString(),
      'taux_alloc_fam_tns_min': tauxAllocFamTNSMin.toString(),
      'taux_alloc_fam_tns_max': tauxAllocFamTNSMax.toString(),
      'taux_csg_crds_tns': tauxCsgCrdsTNS.toString(),
      'taux_cfp_artisan': tauxCfpArtisan.toString(),
      'taux_cfp_commercant': tauxCfpCommercant.toString(),
      // Assimilé Salarié
      'taux_vieillesse_sal_t1': tauxVieillesseSalT1.toString(),
      'taux_vieillesse_sal_t2': tauxVieillesseSalT2.toString(),
      'taux_retraite_comp_sal_t1': tauxRetraiteCompSalT1.toString(),
      'taux_retraite_comp_sal_t2': tauxRetraiteCompSalT2.toString(),
      'taux_apec_sal': tauxAPECSal.toString(),
      'taux_csg_deductible': tauxCSGDeductible.toString(),
      'taux_csg_non_deductible': tauxCSGNonDeductible.toString(),
      'taux_crds': tauxCRDS.toString(),
      'taux_maladie_patronal1': tauxMaladiePatronal1.toString(),
      'taux_maladie_patronal2': tauxMaladiePatronal2.toString(),
      'taux_vieillesse_pat_t1': tauxVieillessePatT1.toString(),
      'taux_vieillesse_pat_t2': tauxVieillessePatT2.toString(),
      'taux_alloc_fam_patronal1': tauxAllocFamPatronal1.toString(),
      'taux_alloc_fam_patronal2': tauxAllocFamPatronal2.toString(),
      'taux_chomage_patronal': tauxChomagePatronal.toString(),
      'taux_retraite_comp_pat_t1': tauxRetraiteCompPatT1.toString(),
      'taux_retraite_comp_pat_t2': tauxRetraiteCompPatT2.toString(),
      'taux_apec_pat': tauxAPECPat.toString(),
      'taux_accident_travail': tauxAccidentTravail.toString(),
      'taux_reduction_max50': tauxReductionMax50.toString(),
      'taux_reduction_max50plus': tauxReductionMax50Plus.toString(),
      // Dividendes
      'taux_csg_dividendes': tauxCSGDividendes.toString(),
      'taux_pfu_ir': tauxPFU_IR.toString(),
      'taux_pfu_total': tauxPFU_Total.toString(),
      'taux_is_reduit': tauxIS_Reduit.toString(),
      'taux_is_normal': tauxIS_Normal.toString(),
    };
  }

  // ==========================================
  // COPY WITH (partiel - simplification)
  // ==========================================

  UrssafConfig copyWith({
    String? id,
    String? userId,
    bool? accreActive,
    int? accreAnnee,
  }) {
    return UrssafConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accreActive: accreActive ?? this.accreActive,
      accreAnnee: accreAnnee ?? this.accreAnnee,
      // Conserver les autres valeurs inchangées
      tauxMicroVente: tauxMicroVente,
      tauxMicroServiceBIC: tauxMicroServiceBIC,
      tauxMicroServiceBNC: tauxMicroServiceBNC,
      tauxMicroLiberalCIPAV: tauxMicroLiberalCIPAV,
      tauxMicroMeubles: tauxMicroMeubles,
      // ... etc (simplifié pour la longu eur)
    );
  }
}
