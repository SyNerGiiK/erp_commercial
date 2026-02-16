enum TypeEntreprise {
  microEntrepreneurVente,
  microEntrepreneurService,
  entrepriseIndividuelle, // TNS
  sasu, // Assimilé Salarié
  eurl, // TNS
  sas, // Assimilé Salarié
  autre
}

extension TypeEntrepriseExtension on TypeEntreprise {
  bool get isMicroEntrepreneur =>
      this == TypeEntreprise.microEntrepreneurVente ||
      this == TypeEntreprise.microEntrepreneurService;

  bool get isTNS =>
      this == TypeEntreprise.entrepriseIndividuelle ||
      this == TypeEntreprise.eurl;

  bool get isAssimileSalarie =>
      this == TypeEntreprise.sasu || this == TypeEntreprise.sas;

  String get label {
    switch (this) {
      case TypeEntreprise.microEntrepreneurVente:
        return "Micro-Entrepreneur (Vente)";
      case TypeEntreprise.microEntrepreneurService:
        return "Micro-Entrepreneur (Service)";
      case TypeEntreprise.entrepriseIndividuelle:
        return "Entreprise Individuelle";
      case TypeEntreprise.sasu:
        return "SASU";
      case TypeEntreprise.eurl:
        return "EURL";
      case TypeEntreprise.sas:
        return "SAS";
      case TypeEntreprise.autre:
        return "Autre";
    }
  }
}

// NOUVEAUX ENUMS POUR LA MICRO-ENTREPRISE (2026)
enum StatutEntrepreneur { artisan, commercant, liberal }

extension StatutEntrepreneurExtension on StatutEntrepreneur {
  String get label {
    switch (this) {
      case StatutEntrepreneur.artisan:
        return "Artisan";
      case StatutEntrepreneur.commercant:
        return "Commerçant";
      case StatutEntrepreneur.liberal:
        return "Profession Libérale";
    }
  }
}

enum TypeActiviteMicro { bicVente, bicPrestation, bncPrestation, mixte }

extension TypeActiviteMicroExtension on TypeActiviteMicro {
  String get label {
    switch (this) {
      case TypeActiviteMicro.bicVente:
        return "Vente de marchandises (BIC)";
      case TypeActiviteMicro.bicPrestation:
        return "Prestation de services (BIC)";
      case TypeActiviteMicro.bncPrestation:
        return "Prestation de services (BNC)";
      case TypeActiviteMicro.mixte:
        return "Mixte (Vente + Prestation)";
    }
  }
}

// ENUMS RESTAURES
enum FrequenceCotisation { mensuelle, trimestrielle }

extension FrequenceCotisationExtension on FrequenceCotisation {
  String get dbValue =>
      this == FrequenceCotisation.mensuelle ? 'mensuelle' : 'trimestrielle';

  String get label =>
      this == FrequenceCotisation.mensuelle ? 'Mensuelle' : 'Trimestrielle';

  static FrequenceCotisation fromDbValue(String? value) {
    if (value == 'trimestrielle') return FrequenceCotisation.trimestrielle;
    return FrequenceCotisation.mensuelle;
  }
}

enum RegimeFiscal { micro, reelSimplifie, reelNormal }

extension RegimeFiscalExtension on RegimeFiscal {
  String get label {
    switch (this) {
      case RegimeFiscal.micro:
        return "Micro-Entreprise";
      case RegimeFiscal.reelSimplifie:
        return "Réel Simplifié";
      case RegimeFiscal.reelNormal:
        return "Réel Normal";
    }
  }
}

enum CaisseRetraite { ssi, cipav, irpAuto, klesia, malakoff, other }

extension CaisseRetraiteExtension on CaisseRetraite {
  String get label {
    switch (this) {
      case CaisseRetraite.ssi:
        return "SSI (Sécu Indépendants)";
      case CaisseRetraite.cipav:
        return "CIPAV";
      default:
        return name.toUpperCase();
    }
  }
}
