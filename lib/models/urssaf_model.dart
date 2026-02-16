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
  final Decimal tauxMicroPrestationBNC; // 24.6% (User specific)

  // Taux Formation Pro (CFP)
  // Artisan: 0.3%, Commerçant: 0.1%, Libéral: 0.2%
  final Decimal tauxCfpVente;
  final Decimal tauxCfpPrestation;
  final Decimal tauxCfpLiberal;

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

  // Constantes Taux Standard 2026
  static final Decimal standardTauxMicroVente = Decimal.parse('12.3');
  static final Decimal standardTauxMicroBIC = Decimal.parse('21.2');
  static final Decimal standardTauxMicroBNC =
      Decimal.parse('24.6'); // User request

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

    // 2. CFP
    Decimal cfpVente =
        (caVente * tauxCfpVente / Decimal.fromInt(100)).toDecimal();
    Decimal cfpBIC =
        (caPrestaBIC * tauxCfpPrestation / Decimal.fromInt(100)).toDecimal();
    Decimal cfpBNC =
        (caPrestaBNC * tauxCfpLiberal / Decimal.fromInt(100)).toDecimal();

    // 3. Libératoire (si actif)
    Decimal libV = Decimal.zero;
    Decimal libBICVal = Decimal.zero;
    Decimal libBNCVal = Decimal.zero;

    if (versementLiberatoire) {
      libV = (caVente * libVente / Decimal.fromInt(100)).toDecimal();
      libBICVal = (caPrestaBIC * libBIC / Decimal.fromInt(100)).toDecimal();
      libBNCVal = (caPrestaBNC * libBNC / Decimal.fromInt(100)).toDecimal();
    }

    return {
      'social': socialVente + socialBIC + socialBNC,
      'cfp': cfpVente + cfpBIC + cfpBNC,
      'liberatoire': libV + libBICVal + libBNCVal,
      'total': (socialVente + socialBIC + socialBNC) +
          (cfpVente + cfpBIC + cfpBNC) +
          (libV + libBICVal + libBNCVal),
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
