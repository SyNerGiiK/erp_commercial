import 'package:decimal/decimal.dart';

class UrssafConfig {
  static final Decimal tauxPrestationStandard = Decimal.parse('21.2');
  static final Decimal tauxVenteStandard = Decimal.parse('12.3');
  static final Decimal tauxPrestationAcre = Decimal.parse('10.6');
  static final Decimal tauxVenteAcre = Decimal.parse('6.2');

  final String? id;
  final String? userId;
  final bool accreActive;
  final String typeEntreprise;

  final Decimal tauxPrestation;
  final Decimal tauxVente;
  final Decimal tauxImpotService;
  final Decimal tauxImpotVente;
  final Decimal tauxCfpService;
  final Decimal tauxCfpVente;
  final Decimal tauxTfcService;
  final Decimal tauxTfcVente;

  final Decimal plafondCaService;
  final Decimal plafondCaVente;
  final Decimal seuilTvaService;
  final Decimal seuilTvaVente;

  UrssafConfig({
    this.id,
    this.userId,
    this.accreActive = false,
    this.typeEntreprise = 'autre',
    Decimal? tauxPrestation,
    Decimal? tauxVente,
    Decimal? tauxImpotService,
    Decimal? tauxImpotVente,
    Decimal? tauxCfpService,
    Decimal? tauxCfpVente,
    Decimal? tauxTfcService,
    Decimal? tauxTfcVente,
    Decimal? plafondCaService,
    Decimal? plafondCaVente,
    Decimal? seuilTvaService,
    Decimal? seuilTvaVente,
  })  : tauxPrestation = tauxPrestation ?? Decimal.parse('21.2'),
        tauxVente = tauxVente ?? Decimal.parse('12.3'),
        tauxImpotService = tauxImpotService ?? Decimal.parse('1.7'),
        tauxImpotVente = tauxImpotVente ?? Decimal.parse('1.0'),
        tauxCfpService = tauxCfpService ?? Decimal.parse('0.3'),
        tauxCfpVente = tauxCfpVente ?? Decimal.parse('0.1'),
        tauxTfcService = tauxTfcService ?? Decimal.zero,
        tauxTfcVente = tauxTfcVente ?? Decimal.zero,
        plafondCaService = plafondCaService ?? Decimal.parse('77700'),
        plafondCaVente = plafondCaVente ?? Decimal.parse('188700'),
        seuilTvaService = seuilTvaService ?? Decimal.parse('36800'),
        seuilTvaVente = seuilTvaVente ?? Decimal.parse('91900');

  factory UrssafConfig.fromMap(Map<String, dynamic> map) {
    return UrssafConfig(
      id: map['id'],
      userId: map['user_id'],
      accreActive: map['accre_active'] ?? false,
      typeEntreprise: map['type_entreprise'] ?? 'autre',
      tauxPrestation:
          Decimal.parse((map['taux_prestation'] ?? 21.2).toString()),
      tauxVente: Decimal.parse((map['taux_vente'] ?? 12.3).toString()),
      tauxImpotService:
          Decimal.parse((map['taux_impot_service'] ?? 1.7).toString()),
      tauxImpotVente:
          Decimal.parse((map['taux_impot_vente'] ?? 1.0).toString()),
      tauxCfpService:
          Decimal.parse((map['taux_cfp_service'] ?? 0.3).toString()),
      tauxCfpVente: Decimal.parse((map['taux_cfp_vente'] ?? 0.1).toString()),
      tauxTfcService: Decimal.parse((map['taux_tfc_service'] ?? 0).toString()),
      tauxTfcVente: Decimal.parse((map['taux_tfc_vente'] ?? 0).toString()),
      plafondCaService:
          Decimal.parse((map['plafond_ca_service'] ?? 77700).toString()),
      plafondCaVente:
          Decimal.parse((map['plafond_ca_vente'] ?? 188700).toString()),
      seuilTvaService:
          Decimal.parse((map['seuil_tva_service'] ?? 36800).toString()),
      seuilTvaVente:
          Decimal.parse((map['seuil_tva_vente'] ?? 91900).toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'accre_active': accreActive,
      'type_entreprise': typeEntreprise,
      'taux_prestation': tauxPrestation.toString(),
      'taux_vente': tauxVente.toString(),
      'taux_impot_service': tauxImpotService.toString(),
      'taux_impot_vente': tauxImpotVente.toString(),
      'taux_cfp_service': tauxCfpService.toString(),
      'taux_cfp_vente': tauxCfpVente.toString(),
      'taux_tfc_service': tauxTfcService.toString(),
      'taux_tfc_vente': tauxTfcVente.toString(),
      'plafond_ca_service': plafondCaService.toString(),
      'plafond_ca_vente': plafondCaVente.toString(),
      'seuil_tva_service': seuilTvaService.toString(),
      'seuil_tva_vente': seuilTvaVente.toString(),
    };
  }

  UrssafConfig copyWith({
    String? id,
    String? userId,
    bool? accreActive,
    String? typeEntreprise,
    Decimal? tauxPrestation,
    Decimal? tauxVente,
    Decimal? tauxImpotService,
    Decimal? tauxImpotVente,
    Decimal? tauxCfpService,
    Decimal? tauxCfpVente,
    Decimal? tauxTfcService,
    Decimal? tauxTfcVente,
    Decimal? plafondCaService,
    Decimal? plafondCaVente,
    Decimal? seuilTvaService,
    Decimal? seuilTvaVente,
  }) {
    return UrssafConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accreActive: accreActive ?? this.accreActive,
      typeEntreprise: typeEntreprise ?? this.typeEntreprise,
      tauxPrestation: tauxPrestation ?? this.tauxPrestation,
      tauxVente: tauxVente ?? this.tauxVente,
      tauxImpotService: tauxImpotService ?? this.tauxImpotService,
      tauxImpotVente: tauxImpotVente ?? this.tauxImpotVente,
      tauxCfpService: tauxCfpService ?? this.tauxCfpService,
      tauxCfpVente: tauxCfpVente ?? this.tauxCfpVente,
      tauxTfcService: tauxTfcService ?? this.tauxTfcService,
      tauxTfcVente: tauxTfcVente ?? this.tauxTfcVente,
      plafondCaService: plafondCaService ?? this.plafondCaService,
      plafondCaVente: plafondCaVente ?? this.plafondCaVente,
      seuilTvaService: seuilTvaService ?? this.seuilTvaService,
      seuilTvaVente: seuilTvaVente ?? this.seuilTvaVente,
    );
  }
}
