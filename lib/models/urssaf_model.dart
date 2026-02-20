import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'enums/entreprise_enums.dart';

// Enums spécifiques au régime Micro sont maintenant dans entreprise_enums.dart

class UrssafConfig {
  final String? id;
  final String userId;
  final bool accreActive;
  final int accreAnnee;

  // Configuration Micro
  final StatutEntrepreneur statut;
  final TypeActiviteMicro typeActivite;
  final bool versementLiberatoire;

  // Taux Micro-Social (2026)
  final Decimal tauxMicroVente; // 12.3%
  final Decimal tauxMicroPrestationBIC; // 21.2%
  final Decimal tauxMicroPrestationBNC; // 25.6% (API Publicodes 2026)

  // Taux Formation Pro (CFP)
  // Artisan: 0.3%, Commerçant: 0.1%, Libéral: 0.2%
  final Decimal tauxCfpVente;
  final Decimal tauxCfpPrestation;
  final Decimal tauxCfpLiberal;

  // Taux TFC — Taxe pour Frais de Chambre (Artisans/Commerçants)
  // Métiers service: 0.48%, Métiers vente: 0.22%, Commerce: 0% par défaut
  final Decimal tauxTfcService;
  final Decimal tauxTfcVente;

  // Plafond Versement Libératoire (RFR N-2 par part de quotient familial)
  final Decimal plafondVlRfr; // 29315 €/an (source: API Publicodes 2026)

  // Sync API metadata
  final DateTime? lastSyncedAt;
  final bool sourceApi; // true si les taux proviennent d'une sync API

  // Aliases for backward compatibility
  Decimal get tauxMicroServiceBIC => tauxMicroPrestationBIC;
  Decimal get tauxMicroServiceBNC => tauxMicroPrestationBNC;

  // Totaux des plafonds (2026)
  final Decimal plafondCaMicroVente; // 188700
  final Decimal plafondCaMicroService; // 77700
  final Decimal seuilTvaMicroVente; // 91900 (Base)
  final Decimal seuilTvaMicroVenteMaj; // 101000 (Majoré)
  final Decimal seuilTvaMicroService; // 36800 (Base)
  final Decimal seuilTvaMicroServiceMaj; // 39100 (Majoré)

  // Constantes Taux Standard 2026 (source: API URSSAF Publicodes 2026-02-19)
  static final Decimal standardTauxMicroVente = Decimal.parse('12.3');
  static final Decimal standardTauxMicroBIC = Decimal.parse('21.2');
  static final Decimal standardTauxMicroBNC =
      Decimal.parse('25.6'); // Corrigé via API Publicodes (était 24.6)

  // Constantes TFC Standard 2026 (source: API URSSAF Publicodes)
  static final Decimal standardTauxTfcService = Decimal.parse('0.48');
  static final Decimal standardTauxTfcVente = Decimal.parse('0.22');

  // Taux ACRE — réduction 50% sur cotisations sociales (4 premiers trimestres)
  static final Decimal tauxReductionAcre = Decimal.parse('0.5');

  // Plafond VL RFR (source: API Publicodes)
  static final Decimal standardPlafondVlRfr = Decimal.parse('29315');

  // Taux Libératoire
  static final Decimal libVente = Decimal.parse('1.0');
  static final Decimal libBIC = Decimal.parse('1.7');
  static final Decimal libBNC = Decimal.parse('2.2');

  UrssafConfig({
    this.id,
    required this.userId,
    this.accreActive = false,
    this.accreAnnee = 1,
    this.statut = StatutEntrepreneur.artisan,
    this.typeActivite = TypeActiviteMicro.mixte,
    this.versementLiberatoire = false,
    Decimal? tauxMicroVente,
    Decimal? tauxMicroPrestationBIC,
    Decimal? tauxMicroPrestationBNC,
    Decimal? tauxCfpVente,
    Decimal? tauxCfpPrestation,
    Decimal? tauxCfpLiberal,
    Decimal? tauxTfcService,
    Decimal? tauxTfcVente,
    Decimal? plafondVlRfr,
    this.lastSyncedAt,
    this.sourceApi = false,
    Decimal? plafondCaMicroVente,
    Decimal? plafondCaMicroService,
    Decimal? seuilTvaMicroVente,
    Decimal? seuilTvaMicroVenteMaj,
    Decimal? seuilTvaMicroService,
    Decimal? seuilTvaMicroServiceMaj,
  })  : tauxMicroVente = tauxMicroVente ?? standardTauxMicroVente,
        tauxMicroPrestationBIC = tauxMicroPrestationBIC ?? standardTauxMicroBIC,
        tauxMicroPrestationBNC = tauxMicroPrestationBNC ?? standardTauxMicroBNC,
        // CFP Defaults based on Artisan (0.3) if null
        tauxCfpVente = tauxCfpVente ?? Decimal.parse('0.3'),
        tauxCfpPrestation = tauxCfpPrestation ?? Decimal.parse('0.3'),
        tauxCfpLiberal = tauxCfpLiberal ?? Decimal.parse('0.2'),
        // TFC Defaults 2026 (Artisan métiers)
        tauxTfcService = tauxTfcService ?? standardTauxTfcService,
        tauxTfcVente = tauxTfcVente ?? standardTauxTfcVente,
        // Plafond VL RFR
        plafondVlRfr = plafondVlRfr ?? standardPlafondVlRfr,
        // Plafonds Defaults 2026
        plafondCaMicroVente = plafondCaMicroVente ?? Decimal.parse('188700'),
        plafondCaMicroService = plafondCaMicroService ?? Decimal.parse('77700'),
        seuilTvaMicroVente = seuilTvaMicroVente ?? Decimal.parse('91900'),
        seuilTvaMicroVenteMaj =
            seuilTvaMicroVenteMaj ?? Decimal.parse('101000'),
        seuilTvaMicroService = seuilTvaMicroService ?? Decimal.parse('36800'),
        seuilTvaMicroServiceMaj =
            seuilTvaMicroServiceMaj ?? Decimal.parse('39100');

  // --- CALCULS ---

  Map<String, Decimal> calculerCotisations(
      Decimal caVente, Decimal caPrestaBIC, Decimal caPrestaBNC) {
    // 1. Cotisations Sociales
    Decimal socialVente =
        (caVente * tauxMicroVente / Decimal.fromInt(100)).toDecimal();
    Decimal socialBIC =
        (caPrestaBIC * tauxMicroPrestationBIC / Decimal.fromInt(100))
            .toDecimal();
    Decimal socialBNC =
        (caPrestaBNC * tauxMicroPrestationBNC / Decimal.fromInt(100))
            .toDecimal();

    // ACRE : réduction de 50% sur les cotisations sociales uniquement
    if (accreActive) {
      socialVente = socialVente * tauxReductionAcre;
      socialBIC = socialBIC * tauxReductionAcre;
      socialBNC = socialBNC * tauxReductionAcre;
    }

    // 2. CFP
    Decimal cfpVente =
        (caVente * tauxCfpVente / Decimal.fromInt(100)).toDecimal();
    Decimal cfpBIC =
        (caPrestaBIC * tauxCfpPrestation / Decimal.fromInt(100)).toDecimal();
    Decimal cfpBNC =
        (caPrestaBNC * tauxCfpLiberal / Decimal.fromInt(100)).toDecimal();

    // 3. TFC (Taxe pour Frais de Chambre — artisans/commerçants uniquement)
    // Les professions libérales ne sont PAS assujetties à la TFC
    Decimal tfcServiceVal = Decimal.zero;
    Decimal tfcVenteVal = Decimal.zero;
    if (statut != StatutEntrepreneur.liberal) {
      tfcServiceVal =
          (caPrestaBIC * tauxTfcService / Decimal.fromInt(100)).toDecimal();
      tfcVenteVal = (caVente * tauxTfcVente / Decimal.fromInt(100)).toDecimal();
    }

    // 4. Libératoire (si actif)
    Decimal libV = Decimal.zero;
    Decimal libBICVal = Decimal.zero;
    Decimal libBNCVal = Decimal.zero;

    if (versementLiberatoire) {
      libV = (caVente * libVente / Decimal.fromInt(100)).toDecimal();
      libBICVal = (caPrestaBIC * libBIC / Decimal.fromInt(100)).toDecimal();
      libBNCVal = (caPrestaBNC * libBNC / Decimal.fromInt(100)).toDecimal();
    }

    final totalTfc = tfcServiceVal + tfcVenteVal;

    return {
      'social': socialVente + socialBIC + socialBNC,
      'cfp': cfpVente + cfpBIC + cfpBNC,
      'tfc': totalTfc,
      'liberatoire': libV + libBICVal + libBNCVal,
      'total': (socialVente + socialBIC + socialBNC) +
          (cfpVente + cfpBIC + cfpBNC) +
          totalTfc +
          (libV + libBICVal + libBNCVal),
    };
  }

  /// Calcule la sous-répartition détaillée des cotisations sociales.
  /// Retourne les montants par branche (maladie, retraite, etc.)
  /// basés sur les pourcentages officiels de l'API URSSAF Publicodes.
  Map<String, Decimal> calculerRepartition(
      Decimal caVente, Decimal caPrestaBIC, Decimal caPrestaBNC) {
    final totalCA = caVente + caPrestaBIC + caPrestaBNC;
    if (totalCA == Decimal.zero) return {};

    // Répartition BIC Service (sur taux 21.2%)
    // Source API: maladie 2.13%, retraite base 9.22%, complémentaire 4.19%,
    //            invalidité-décès 0.67%, autres contributions (CSG/CRDS) 5.00%
    final rBicMaladie = Decimal.parse('2.13');
    final rBicRetraiteBase = Decimal.parse('9.22');
    final rBicRetraiteCompl = Decimal.parse('4.19');
    final rBicInvalidite = Decimal.parse('0.67');
    final rBicAutres = Decimal.parse('5.01'); // ajusté pour coller à 21.22

    // Répartition Vente (sur taux 12.3%)
    // Source API: maladie 1.24%, retraite base 5.36%, complémentaire 2.44%,
    //            invalidité-décès 0.39%, autres contributions 3.09%
    final rVenteMaladie = Decimal.parse('1.24');
    final rVenteRetraiteBase = Decimal.parse('5.36');
    final rVenteRetraiteCompl = Decimal.parse('2.44');
    final rVenteInvalidite = Decimal.parse('0.39');
    final rVenteAutres = Decimal.parse('2.87');

    Decimal calc(Decimal ca, Decimal taux) =>
        (ca * taux / Decimal.fromInt(100)).toDecimal();

    final maladie =
        calc(caPrestaBIC, rBicMaladie) + calc(caVente, rVenteMaladie);
    final retraiteBase =
        calc(caPrestaBIC, rBicRetraiteBase) + calc(caVente, rVenteRetraiteBase);
    final retraiteCompl = calc(caPrestaBIC, rBicRetraiteCompl) +
        calc(caVente, rVenteRetraiteCompl);
    final invalidite =
        calc(caPrestaBIC, rBicInvalidite) + calc(caVente, rVenteInvalidite);
    final csgCrds = calc(caPrestaBIC, rBicAutres) + calc(caVente, rVenteAutres);

    // BNC : taux forfaitaire 25.6% — répartition non détaillée par l'API
    // On regroupe en "cotisations BNC" si applicable
    final socialBNC =
        (caPrestaBNC * tauxMicroPrestationBNC / Decimal.fromInt(100))
            .toDecimal();

    // ACRE : réduction de 50% sur toutes les branches sociales
    if (accreActive) {
      return {
        'maladie': maladie * tauxReductionAcre,
        'retraite_base': retraiteBase * tauxReductionAcre,
        'retraite_complementaire': retraiteCompl * tauxReductionAcre,
        'invalidite_deces': invalidite * tauxReductionAcre,
        'csg_crds': csgCrds * tauxReductionAcre,
        if (socialBNC > Decimal.zero)
          'cotisations_bnc': socialBNC * tauxReductionAcre,
      };
    }

    return {
      'maladie': maladie,
      'retraite_base': retraiteBase,
      'retraite_complementaire': retraiteCompl,
      'invalidite_deces': invalidite,
      'csg_crds': csgCrds,
      if (socialBNC > Decimal.zero) 'cotisations_bnc': socialBNC,
    };
  }

  // --- CALCULS TNS (Travailleur Non Salarié — EI/EURL régime réel) ---

  // Taux TNS 2025 provisoires (source: URSSAF.fr barème indicatif)
  static final Decimal _tnsTauxMaladie = Decimal.parse('6.50');
  static final Decimal _tnsTauxAllocFamiliales = Decimal.parse('3.10');
  static final Decimal _tnsTauxRetraiteBase = Decimal.parse('17.75');
  static final Decimal _tnsTauxRetraiteCompl = Decimal.parse('7.00');
  static final Decimal _tnsTauxInvaliditeDeces = Decimal.parse('1.30');
  static final Decimal _tnsTauxCsgCrds = Decimal.parse('9.70');
  static final Decimal _tnsTauxCfp = Decimal.parse('0.25');

  /// Calcule les cotisations TNS sur le bénéfice (EI/EURL régime réel).
  /// Le bénéfice = CA HT - dépenses réelles.
  /// Retourne une Map compatible avec le format de calculerCotisations (micro).
  Map<String, Decimal> calculerCotisationsTNS(Decimal benefice) {
    if (benefice <= Decimal.zero) {
      return {
        'social': Decimal.zero,
        'cfp': Decimal.zero,
        'tfc': Decimal.zero,
        'liberatoire': Decimal.zero,
        'total': Decimal.zero,
        'maladie': Decimal.zero,
        'allocations_familiales': Decimal.zero,
        'retraite_base': Decimal.zero,
        'retraite_complementaire': Decimal.zero,
        'invalidite_deces': Decimal.zero,
        'csg_crds': Decimal.zero,
      };
    }

    final cent = Decimal.fromInt(100);
    final maladie = (benefice * _tnsTauxMaladie / cent).toDecimal();
    final allocFamiliales =
        (benefice * _tnsTauxAllocFamiliales / cent).toDecimal();
    final retraiteBase = (benefice * _tnsTauxRetraiteBase / cent).toDecimal();
    final retraiteCompl = (benefice * _tnsTauxRetraiteCompl / cent).toDecimal();
    final invaliditeDeces =
        (benefice * _tnsTauxInvaliditeDeces / cent).toDecimal();
    final csgCrds = (benefice * _tnsTauxCsgCrds / cent).toDecimal();
    final cfp = (benefice * _tnsTauxCfp / cent).toDecimal();

    final social = maladie +
        allocFamiliales +
        retraiteBase +
        retraiteCompl +
        invaliditeDeces +
        csgCrds;
    final total = social + cfp;

    return {
      'social': social,
      'cfp': cfp,
      'tfc': Decimal.zero,
      'liberatoire': Decimal.zero,
      'total': total,
      'maladie': maladie,
      'allocations_familiales': allocFamiliales,
      'retraite_base': retraiteBase,
      'retraite_complementaire': retraiteCompl,
      'invalidite_deces': invaliditeDeces,
      'csg_crds': csgCrds,
    };
  }

  // Helper pour les jauges
  Decimal getPlafondMicro(bool isService) {
    return isService ? plafondCaMicroService : plafondCaMicroVente;
  }

  UrssafConfig copyWith({
    String? id,
    String? userId,
    bool? accreActive,
    int? accreAnnee,
    StatutEntrepreneur? statut,
    TypeActiviteMicro? typeActivite,
    bool? versementLiberatoire,
    Decimal? tauxMicroVente,
    Decimal? tauxMicroPrestationBIC,
    Decimal? tauxMicroPrestationBNC,
    Decimal? tauxCfpVente,
    Decimal? tauxCfpPrestation,
    Decimal? tauxCfpLiberal,
    Decimal? tauxTfcService,
    Decimal? tauxTfcVente,
    Decimal? plafondVlRfr,
    DateTime? lastSyncedAt,
    bool? sourceApi,
    Decimal? plafondCaMicroVente,
    Decimal? plafondCaMicroService,
    Decimal? seuilTvaMicroVente,
    Decimal? seuilTvaMicroVenteMaj,
    Decimal? seuilTvaMicroService,
    Decimal? seuilTvaMicroServiceMaj,
  }) {
    return UrssafConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accreActive: accreActive ?? this.accreActive,
      accreAnnee: accreAnnee ?? this.accreAnnee,
      statut: statut ?? this.statut,
      typeActivite: typeActivite ?? this.typeActivite,
      versementLiberatoire: versementLiberatoire ?? this.versementLiberatoire,
      tauxMicroVente: tauxMicroVente ?? this.tauxMicroVente,
      tauxMicroPrestationBIC:
          tauxMicroPrestationBIC ?? this.tauxMicroPrestationBIC,
      tauxMicroPrestationBNC:
          tauxMicroPrestationBNC ?? this.tauxMicroPrestationBNC,
      tauxCfpVente: tauxCfpVente ?? this.tauxCfpVente,
      tauxCfpPrestation: tauxCfpPrestation ?? this.tauxCfpPrestation,
      tauxCfpLiberal: tauxCfpLiberal ?? this.tauxCfpLiberal,
      tauxTfcService: tauxTfcService ?? this.tauxTfcService,
      tauxTfcVente: tauxTfcVente ?? this.tauxTfcVente,
      plafondVlRfr: plafondVlRfr ?? this.plafondVlRfr,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      sourceApi: sourceApi ?? this.sourceApi,
      plafondCaMicroVente: plafondCaMicroVente ?? this.plafondCaMicroVente,
      plafondCaMicroService:
          plafondCaMicroService ?? this.plafondCaMicroService,
      seuilTvaMicroVente: seuilTvaMicroVente ?? this.seuilTvaMicroVente,
      seuilTvaMicroVenteMaj:
          seuilTvaMicroVenteMaj ?? this.seuilTvaMicroVenteMaj,
      seuilTvaMicroService: seuilTvaMicroService ?? this.seuilTvaMicroService,
      seuilTvaMicroServiceMaj:
          seuilTvaMicroServiceMaj ?? this.seuilTvaMicroServiceMaj,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'accre_active': accreActive,
      'accre_annee': accreAnnee,
      'statut': statut.toString().split('.').last,
      'type_activite': typeActivite.toString().split('.').last,
      'versement_liberatoire': versementLiberatoire,
      'taux_micro_vente': tauxMicroVente.toString(),
      'taux_micro_prestation_bic': tauxMicroPrestationBIC.toString(),
      'taux_micro_prestation_bnc': tauxMicroPrestationBNC.toString(),
      'taux_cfp_vente': tauxCfpVente.toString(),
      'taux_cfp_prestation': tauxCfpPrestation.toString(),
      'taux_cfp_liberal': tauxCfpLiberal.toString(),
      'taux_tfc_service': tauxTfcService.toString(),
      'taux_tfc_vente': tauxTfcVente.toString(),
      'plafond_vl_rfr': plafondVlRfr.toString(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'source_api': sourceApi,
      'plafond_ca_micro_vente': plafondCaMicroVente.toString(),
      'plafond_ca_micro_service': plafondCaMicroService.toString(),
      'seuil_tva_micro_vente': seuilTvaMicroVente.toString(),
      'seuil_tva_micro_vente_maj': seuilTvaMicroVenteMaj.toString(),
      'seuil_tva_micro_service': seuilTvaMicroService.toString(),
      'seuil_tva_micro_service_maj': seuilTvaMicroServiceMaj.toString(),
    };
  }

  factory UrssafConfig.fromMap(Map<String, dynamic> map) {
    return UrssafConfig(
      id: map['id'],
      userId: map['user_id'],
      accreActive: map['accre_active'] ?? false,
      accreAnnee: map['accre_annee'] ?? 1,
      statut: _parseStatut(map['statut']),
      typeActivite: _parseActivite(map['type_activite']),
      versementLiberatoire: map['versement_liberatoire'] ?? false,
      tauxMicroVente:
          _parseDecimal(map['taux_micro_vente'], standardTauxMicroVente),
      tauxMicroPrestationBIC:
          _parseDecimal(map['taux_micro_prestation_bic'], standardTauxMicroBIC),
      tauxMicroPrestationBNC:
          _parseDecimal(map['taux_micro_prestation_bnc'], standardTauxMicroBNC),
      tauxCfpVente: _parseDecimal(map['taux_cfp_vente'], Decimal.parse('0.3')),
      tauxCfpPrestation:
          _parseDecimal(map['taux_cfp_prestation'], Decimal.parse('0.3')),
      tauxCfpLiberal:
          _parseDecimal(map['taux_cfp_liberal'], Decimal.parse('0.2')),
      tauxTfcService:
          _parseDecimal(map['taux_tfc_service'], standardTauxTfcService),
      tauxTfcVente: _parseDecimal(map['taux_tfc_vente'], standardTauxTfcVente),
      plafondVlRfr: _parseDecimal(map['plafond_vl_rfr'], standardPlafondVlRfr),
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.tryParse(map['last_synced_at'])
          : null,
      sourceApi: map['source_api'] ?? false,
      plafondCaMicroVente:
          _parseDecimal(map['plafond_ca_micro_vente'], Decimal.parse('188700')),
      plafondCaMicroService: _parseDecimal(
          map['plafond_ca_micro_service'], Decimal.parse('77700')),
      seuilTvaMicroVente:
          _parseDecimal(map['seuil_tva_micro_vente'], Decimal.parse('91900')),
      seuilTvaMicroVenteMaj: _parseDecimal(
          map['seuil_tva_micro_vente_maj'], Decimal.parse('101000')),
      seuilTvaMicroService:
          _parseDecimal(map['seuil_tva_micro_service'], Decimal.parse('36800')),
      seuilTvaMicroServiceMaj: _parseDecimal(
          map['seuil_tva_micro_service_maj'], Decimal.parse('39100')),
    );
  }

  static Decimal _parseDecimal(dynamic value, Decimal defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return Decimal.tryParse(value) ?? defaultValue;
    if (value is num) return Decimal.parse(value.toString());
    return defaultValue;
  }

  static StatutEntrepreneur _parseStatut(String? value) {
    if (value == null) return StatutEntrepreneur.artisan;
    return StatutEntrepreneur.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => StatutEntrepreneur.artisan,
    );
  }

  static TypeActiviteMicro _parseActivite(String? value) {
    if (value == null) return TypeActiviteMicro.mixte;
    return TypeActiviteMicro.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TypeActiviteMicro.mixte,
    );
  }
}
