enum TypeEntreprise {
  microEntrepreneur, // EI au régime micro-social
  entrepriseIndividuelle, // TNS (régime réel)
  eurl, // TNS
  sasu, // Assimilé Salarié
  sas, // Assimilé Salarié
  autre
}

extension TypeEntrepriseExtension on TypeEntreprise {
  bool get isMicroEntrepreneur => this == TypeEntreprise.microEntrepreneur;

  bool get isTNS =>
      this == TypeEntreprise.entrepriseIndividuelle ||
      this == TypeEntreprise.eurl;

  bool get isAssimileSalarie =>
      this == TypeEntreprise.sasu || this == TypeEntreprise.sas;

  String get label {
    switch (this) {
      case TypeEntreprise.microEntrepreneur:
        return "Micro-Entrepreneur";
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

// === PDF THEME ===
enum PdfTheme { moderne, classique, minimaliste }

extension PdfThemeExtension on PdfTheme {
  String get label {
    switch (this) {
      case PdfTheme.moderne:
        return "Moderne";
      case PdfTheme.classique:
        return "Classique";
      case PdfTheme.minimaliste:
        return "Minimaliste";
    }
  }

  String get description {
    switch (this) {
      case PdfTheme.moderne:
        return "Couleurs de l'entreprise, en-têtes graphiques";
      case PdfTheme.classique:
        return "Formel, police Serif, encadrés fins, Noir & Blanc";
      case PdfTheme.minimaliste:
        return "Épuré, sans bordures, alignements stricts";
    }
  }
}

// === MODE FACTURATION ===
enum ModeFacturation { global, detaille }

extension ModeFacturationExtension on ModeFacturation {
  String get label {
    switch (this) {
      case ModeFacturation.global:
        return "Global";
      case ModeFacturation.detaille:
        return "Détaillé";
    }
  }

  String get description {
    switch (this) {
      case ModeFacturation.global:
        return "Vente + Service groupés dans le même devis";
      case ModeFacturation.detaille:
        return "Séparation fine par type d'activité";
    }
  }
}

// === PDF DESIGN SYSTEM (V2) ===
enum PdfFontPairing { modern, luxury, classic, tech }

extension PdfFontPairingExtension on PdfFontPairing {
  String get dbValue => name;

  String get label {
    switch (this) {
      case PdfFontPairing.modern:
        return "Moderne (Inter/Roboto)";
      case PdfFontPairing.luxury:
        return "Luxe (Playfair/Lato)";
      case PdfFontPairing.classic:
        return "Classique (Merriweather)";
      case PdfFontPairing.tech:
        return "Tech (Roboto Mono)";
    }
  }
}

enum PdfTableStyle { minimal, zebra, solid, rounded, filledHeader }

extension PdfTableStyleExtension on PdfTableStyle {
  String get dbValue {
    if (this == PdfTableStyle.filledHeader) return 'filled_header';
    return name;
  }

  String get label {
    switch (this) {
      case PdfTableStyle.minimal:
        return "Minimaliste (Sans bordures)";
      case PdfTableStyle.zebra:
        return "Zébré (Lignes alternées)";
      case PdfTableStyle.solid:
        return "Solide (Grille complète)";
      case PdfTableStyle.rounded:
        return "Arrondi (Bords adoucis)";
      case PdfTableStyle.filledHeader:
        return "En-tête Coloré";
    }
  }

  static PdfTableStyle fromDbValue(String? val) {
    if (val == 'filled_header') return PdfTableStyle.filledHeader;
    return PdfTableStyle.values
        .firstWhere((e) => e.name == val, orElse: () => PdfTableStyle.minimal);
  }
}

enum PdfLayoutVariant { standard, elegant, rightAligned }

extension PdfLayoutVariantExtension on PdfLayoutVariant {
  String get dbValue {
    if (this == PdfLayoutVariant.rightAligned) return 'right_aligned';
    return name;
  }

  String get label {
    switch (this) {
      case PdfLayoutVariant.standard:
        return "Standard";
      case PdfLayoutVariant.elegant:
        return "Élégant (Centré)";
      case PdfLayoutVariant.rightAligned:
        return "Aligné à droite";
    }
  }

  static PdfLayoutVariant fromDbValue(String? val) {
    if (val == 'right_aligned') return PdfLayoutVariant.rightAligned;
    return PdfLayoutVariant.values.firstWhere((e) => e.name == val,
        orElse: () => PdfLayoutVariant.standard);
  }
}
