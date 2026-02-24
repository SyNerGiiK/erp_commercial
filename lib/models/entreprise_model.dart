import 'package:decimal/decimal.dart';
import 'enums/entreprise_enums.dart';

class ProfilEntreprise {
  final String? id;
  final String? userId;
  final String nomEntreprise;
  final String nomGerant;
  final String adresse;
  final String codePostal;
  final String ville;
  final String siret;
  final String email;
  final String? telephone;
  final String? iban;
  final String? bic;
  final FrequenceCotisation frequenceCotisation;

  // CHANGEMENT MAJEUR : Stockage par URL (Cloud) et non Base64 (RAM)
  final String? logoUrl;
  final String? signatureUrl;

  final String? mentionsLegales;

  // === SYSTÈME FISCAL UNIVERSEL ===
  /// Type d'entreprise (micro, TNS, assimilé salarié, etc.)
  final TypeEntreprise typeEntreprise;

  /// Régime fiscal (optionnel, déduit du type si non spécifié)
  final RegimeFiscal? regimeFiscal;

  /// Caisse de retraite (pour professions libérales)
  final CaisseRetraite caisseRetraite;

  /// Assujettissement à la TVA
  final bool tvaApplicable;
  final String? numeroTvaIntra;

  /// Thème PDF sélectionné
  final PdfTheme pdfTheme;

  /// Couleur primaire personnalisée pour les PDF (hex sans #, ex: '1E5572')
  /// Si null, la couleur par défaut du thème est utilisée
  final String? pdfPrimaryColor;

  /// URL du logo footer (ex: certification, label qualité)
  final String? logoFooterUrl;

  /// Mode de facturation (global vs détaillé)
  final ModeFacturation modeFacturation;

  /// Mode discret (masquer le résumé financier dans l'éditeur)
  final bool modeDiscret;

  /// Taux de pénalités de retard (défaut : taux directeur BCE + 10 = 11.62% en 2025)
  final Decimal tauxPenalitesRetard;

  /// Escompte applicable en cas de paiement anticipé
  final bool escompteApplicable;

  /// L'entreprise est-elle immatriculée au RCS/RM ?
  /// Si false ET micro-entrepreneur → mention "Dispensé d'immatriculation" sur PDF
  final bool estImmatricule;

  /// Utilisateur Administrateur (God Mode)
  final bool isAdmin;

  ProfilEntreprise({
    this.id,
    this.userId,
    required this.nomEntreprise,
    required this.nomGerant,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.siret,
    required this.email,
    this.telephone,
    this.iban,
    this.bic,
    this.frequenceCotisation = FrequenceCotisation.mensuelle,
    this.logoUrl,
    this.signatureUrl,
    this.mentionsLegales,
    this.typeEntreprise = TypeEntreprise.microEntrepreneur,
    this.regimeFiscal,
    this.caisseRetraite = CaisseRetraite.ssi,
    this.tvaApplicable = false,
    this.numeroTvaIntra,
    this.pdfTheme = PdfTheme.moderne,
    this.pdfPrimaryColor,
    this.logoFooterUrl,
    this.modeFacturation = ModeFacturation.global,
    this.modeDiscret = false,
    Decimal? tauxPenalitesRetard,
    this.escompteApplicable = false,
    this.estImmatricule = false,
    this.isAdmin = false,
  }) : tauxPenalitesRetard = tauxPenalitesRetard ?? Decimal.parse('11.62');

  factory ProfilEntreprise.fromMap(Map<String, dynamic> map) {
    return ProfilEntreprise(
      id: map['id'],
      userId: map['user_id'],
      nomEntreprise: map['nom_entreprise'] ?? '',
      nomGerant: map['nom_gerant'] ?? '',
      adresse: map['adresse'] ?? '',
      codePostal: map['code_postal'] ?? '',
      ville: map['ville'] ?? '',
      siret: map['siret'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'],
      iban: map['iban'],
      bic: map['bic'],
      frequenceCotisation:
          FrequenceCotisationExtension.fromDbValue(map['frequence_cotisation']),
      logoUrl: map['logo_url'],
      signatureUrl: map['signature_url'],
      mentionsLegales: map['mentions_legales'],
      typeEntreprise: _parseTypeEntreprise(map['type_entreprise']),
      regimeFiscal: _parseRegimeFiscal(map['regime_fiscal']),
      caisseRetraite: _parseCaisseRetraite(map['caisse_retraite']),
      tvaApplicable: map['tva_applicable'] ?? false,
      numeroTvaIntra: map['numero_tva_intra'],
      pdfTheme: _parsePdfTheme(map['pdf_theme']),
      pdfPrimaryColor: map['pdf_primary_color'],
      logoFooterUrl: map['logo_footer_url'],
      modeFacturation: _parseModeFacturation(map['mode_facturation']),
      modeDiscret: map['mode_discret'] ?? false,
      tauxPenalitesRetard: Decimal.parse(
        (map['taux_penalites_retard'] ?? '11.62').toString(),
      ),
      escompteApplicable: map['escompte_applicable'] ?? false,
      estImmatricule: map['est_immatricule'] ?? false,
      isAdmin: map['is_admin'] ?? false,
    );
  }

  static TypeEntreprise _parseTypeEntreprise(dynamic value) {
    if (value == null) return TypeEntreprise.microEntrepreneur;
    // Backward compat : anciennes variantes micro → microEntrepreneur
    if ([
      'microEntrepreneurVente',
      'microEntrepreneurService',
      'microEntrepreneurMixte'
    ].contains(value)) {
      return TypeEntreprise.microEntrepreneur;
    }
    try {
      return TypeEntreprise.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TypeEntreprise.microEntrepreneur,
      );
    } catch (_) {
      return TypeEntreprise.microEntrepreneur;
    }
  }

  static RegimeFiscal? _parseRegimeFiscal(dynamic value) {
    if (value == null) return null;
    try {
      return RegimeFiscal.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  static CaisseRetraite _parseCaisseRetraite(dynamic value) {
    if (value == null) return CaisseRetraite.ssi;
    try {
      return CaisseRetraite.values.firstWhere(
        (e) => e.name == value,
        orElse: () => CaisseRetraite.ssi,
      );
    } catch (_) {
      return CaisseRetraite.ssi;
    }
  }

  static PdfTheme _parsePdfTheme(dynamic value) {
    if (value == null) return PdfTheme.moderne;
    try {
      return PdfTheme.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PdfTheme.moderne,
      );
    } catch (_) {
      return PdfTheme.moderne;
    }
  }

  static ModeFacturation _parseModeFacturation(dynamic value) {
    if (value == null) return ModeFacturation.global;
    try {
      return ModeFacturation.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ModeFacturation.global,
      );
    } catch (_) {
      return ModeFacturation.global;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nom_entreprise': nomEntreprise,
      'nom_gerant': nomGerant,
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'siret': siret,
      'email': email,
      'telephone': telephone,
      'iban': iban,
      'bic': bic,
      'frequence_cotisation': frequenceCotisation.dbValue,
      'logo_url': logoUrl,
      'signature_url': signatureUrl,
      'mentions_legales': mentionsLegales,
      'type_entreprise': typeEntreprise.name,
      'regime_fiscal': regimeFiscal?.name,
      'caisse_retraite': caisseRetraite.name,
      'tva_applicable': tvaApplicable,
      'numero_tva_intra': numeroTvaIntra,
      'pdf_theme': pdfTheme.name,
      'pdf_primary_color': pdfPrimaryColor,
      'logo_footer_url': logoFooterUrl,
      'mode_facturation': modeFacturation.name,
      'mode_discret': modeDiscret,
      'taux_penalites_retard': tauxPenalitesRetard,
      'escompte_applicable': escompteApplicable,
      'est_immatricule': estImmatricule,
      'is_admin': isAdmin,
    };
  }

  ProfilEntreprise copyWith({
    String? id,
    String? userId,
    String? nomEntreprise,
    String? nomGerant,
    String? adresse,
    String? codePostal,
    String? ville,
    String? siret,
    String? email,
    String? telephone,
    String? iban,
    String? bic,
    FrequenceCotisation? frequenceCotisation,
    String? logoUrl,
    String? signatureUrl,
    String? mentionsLegales,
    TypeEntreprise? typeEntreprise,
    RegimeFiscal? regimeFiscal,
    CaisseRetraite? caisseRetraite,
    bool? tvaApplicable,
    String? numeroTvaIntra,
    PdfTheme? pdfTheme,
    String? pdfPrimaryColor,
    String? logoFooterUrl,
    ModeFacturation? modeFacturation,
    bool? modeDiscret,
    Decimal? tauxPenalitesRetard,
    bool? escompteApplicable,
    bool? estImmatricule,
    bool? isAdmin,
  }) {
    return ProfilEntreprise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      nomGerant: nomGerant ?? this.nomGerant,
      adresse: adresse ?? this.adresse,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      siret: siret ?? this.siret,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      iban: iban ?? this.iban,
      bic: bic ?? this.bic,
      frequenceCotisation: frequenceCotisation ?? this.frequenceCotisation,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      mentionsLegales: mentionsLegales ?? this.mentionsLegales,
      typeEntreprise: typeEntreprise ?? this.typeEntreprise,
      regimeFiscal: regimeFiscal ?? this.regimeFiscal,
      caisseRetraite: caisseRetraite ?? this.caisseRetraite,
      tvaApplicable: tvaApplicable ?? this.tvaApplicable,
      numeroTvaIntra: numeroTvaIntra ?? this.numeroTvaIntra,
      pdfTheme: pdfTheme ?? this.pdfTheme,
      pdfPrimaryColor: pdfPrimaryColor ?? this.pdfPrimaryColor,
      logoFooterUrl: logoFooterUrl ?? this.logoFooterUrl,
      modeFacturation: modeFacturation ?? this.modeFacturation,
      modeDiscret: modeDiscret ?? this.modeDiscret,
      tauxPenalitesRetard: tauxPenalitesRetard ?? this.tauxPenalitesRetard,
      escompteApplicable: escompteApplicable ?? this.escompteApplicable,
      estImmatricule: estImmatricule ?? this.estImmatricule,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
