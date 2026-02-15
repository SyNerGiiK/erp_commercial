import 'package:flutter/material.dart';

/// Types d'entreprises supportés par l'ERP
/// Couvre tous les régimes fiscaux français 2026
enum TypeEntreprise {
  // ==========================================
  // MICRO-ENTREPRENEUR (Auto-Entrepreneur)
  // ==========================================

  /// Micro-entrepreneur - Achat/Revente marchandises (BIC)
  /// Taux standard: 12.3% + CFP 0.1%
  /// Plafond CA: 188 700€
  microEntrepreneurVente,

  /// Micro-entrepreneur - Prestations de services commerciales/artisanales (BIC)
  /// Taux standard: 21.2% + CFP 0.3%
  /// Plafond CA: 77 700€
  microEntrepreneurServiceBIC,

  /// Micro-entrepreneur - Prestations de services BNC (SSI)
  /// Taux standard: 25.6% (2026) + CFP 0.2%
  /// Plafond CA: 77 700€
  microEntrepreneurServiceBNC,

  /// Micro-entrepreneur - Professions libérales CIPAV (BNC)
  /// Taux standard: 23.2% + CFP 0.2%
  /// Plafond CA: 77 700€
  microEntrepreneurLiberalCIPAV,

  /// Micro-entrepreneur - Location meublés de tourisme classés
  /// Taux standard: 6.0% + CFP 0.1%
  microEntrepreneurMeubles,

  // ==========================================
  // TNS - Travailleur Non Salarié
  // ==========================================

  /// EURL ou SARL avec gérant majoritaire (TNS - SSI)
  /// Cotisations: ~45% du revenu net
  /// Assiette: Revenu professionnel - abattement 26%
  eurlSarlGerantMajoritaire,

  /// Entreprise Individuelle (EI) - Régime réel
  /// Cotisations TNS SSI: ~45%
  entrepriseIndividuelle,

  /// EIRL - Entrepreneur Individuel à Responsabilité Limitée (TNS)
  /// Cotisations SSI: ~45%
  eirlTNS,

  // ==========================================
  // ASSIMILÉ SALARIÉ - Régime Général
  // ==========================================

  /// SASU ou SAS - Président (Assimilé salarié)
  /// Charges totales: ~80% du salaire net
  /// Protection sociale complète
  sasuSasPresident,

  /// SARL - Gérant minoritaire ou égalitaire (Assimilé salarié)
  /// Charges: ~80% du net
  sarlGerantMinoritaire,

  // ==========================================
  // SOCIÉTÉS À L'IS (Impôt sur les Sociétés)
  // ==========================================

  /// SARL à l'IS (choix mixte selon gérant)
  /// Gérant majoritaire: TNS
  /// Gérant minoritaire: Assimilé salarié
  sarlIS,

  /// SAS à l'IS
  /// Président: Assimilé salarié
  sasIS,

  /// SASU à l'IS
  /// Président: Assimilé salarié
  sasuIS,

  /// EURL à l'IS
  /// Gérant associé unique: TNS
  eurlIS,

  // ==========================================
  // PROFESSIONS LIBÉRALES
  // ==========================================

  /// Profession libérale - CIPAV (Déclaratif contrôlé)
  /// Ex: Architecte, géomètre, consultant
  professionLiberaleCIPAV,

  /// Profession libérale - SSI (Déclaratif contrôlé)
  /// Ex: Certains thérapeutes, formateurs
  professionLiberaleSSI,

  /// Profession libérale - Caisse spécifique
  /// Ex: Médecin (CARMF), Avocat (CNBF), Expert-comptable (CAVEC)
  professionLiberaleCaisseSpecifique,

  // ==========================================
  // AUTRES
  // ==========================================

  /// Association loi 1901 (régime particulier)
  association,

  /// Autre type non répertorié
  autre,
}

/// Extension pour obtenir le libellé français
extension TypeEntrepriseExtension on TypeEntreprise {
  String get label {
    switch (this) {
      case TypeEntreprise.microEntrepreneurVente:
        return "Micro-Entrepreneur - Vente Marchandises";
      case TypeEntreprise.microEntrepreneurServiceBIC:
        return "Micro-Entrepreneur - Services BIC";
      case TypeEntreprise.microEntrepreneurServiceBNC:
        return "Micro-Entrepreneur - Services BNC (SSI)";
      case TypeEntreprise.microEntrepreneurLiberalCIPAV:
        return "Micro-Entrepreneur - Libéral CIPAV";
      case TypeEntreprise.microEntrepreneurMeubles:
        return "Micro-Entrepreneur - Meublés Tourisme";
      case TypeEntreprise.eurlSarlGerantMajoritaire:
        return "EURL/SARL - Gérant Majoritaire (TNS)";
      case TypeEntreprise.entrepriseIndividuelle:
        return "Entreprise Individuelle (EI)";
      case TypeEntreprise.eirlTNS:
        return "EIRL - TNS";
      case TypeEntreprise.sasuSasPresident:
        return "SASU/SAS - Président";
      case TypeEntreprise.sarlGerantMinoritaire:
        return "SARL - Gérant Minoritaire";
      case TypeEntreprise.sarlIS:
        return "SARL à l'IS";
      case TypeEntreprise.sasIS:
        return "SAS à l'IS";
      case TypeEntreprise.sasuIS:
        return "SASU à l'IS";
      case TypeEntreprise.eurlIS:
        return "EURL à l'IS";
      case TypeEntreprise.professionLiberaleCIPAV:
        return "Profession Libérale - CIPAV";
      case TypeEntreprise.professionLiberaleSSI:
        return "Profession Libérale - SSI";
      case TypeEntreprise.professionLiberaleCaisseSpecifique:
        return "Profession Libérale - Caisse Spécifique";
      case TypeEntreprise.association:
        return "Association Loi 1901";
      case TypeEntreprise.autre:
        return "Autre";
    }
  }

  /// Indique si ce type est un micro-entrepreneur
  bool get isMicroEntrepreneur {
    return [
      TypeEntreprise.microEntrepreneurVente,
      TypeEntreprise.microEntrepreneurServiceBIC,
      TypeEntreprise.microEntrepreneurServiceBNC,
      TypeEntreprise.microEntrepreneurLiberalCIPAV,
      TypeEntreprise.microEntrepreneurMeubles,
    ].contains(this);
  }

  /// Indique si ce type est un TNS
  bool get isTNS {
    return [
      TypeEntreprise.eurlSarlGerantMajoritaire,
      TypeEntreprise.entrepriseIndividuelle,
      TypeEntreprise.eirlTNS,
      TypeEntreprise.professionLiberaleCIPAV,
      TypeEntreprise.professionLiberaleSSI,
      TypeEntreprise.professionLiberaleCaisseSpecifique,
    ].contains(this);
  }

  /// Indique si ce type est un assimilé salarié
  bool get isAssimileSalarie {
    return [
      TypeEntreprise.sasuSasPresident,
      TypeEntreprise.sarlGerantMinoritaire,
    ].contains(this);
  }

  /// Indique si ce type peut avoir des dividendes
  bool get hasDividendes {
    return [
      TypeEntreprise.sarlIS,
      TypeEntreprise.sasIS,
      TypeEntreprise.sasuIS,
      TypeEntreprise.eurlIS,
    ].contains(this);
  }
}

/// Régimes fiscaux
enum RegimeFiscal {
  /// Régime micro-entreprise (forfaitaire)
  micro,

  /// Régime réel simplifié
  reelSimplifie,

  /// Régime réel normal
  reelNormal,

  /// Déclaratif contrôlé (BNC professions libérales)
  declaratifControle,
}

extension RegimeFiscalExtension on RegimeFiscal {
  String get label {
    switch (this) {
      case RegimeFiscal.micro:
        return "Micro-entreprise";
      case RegimeFiscal.reelSimplifie:
        return "Réel Simplifié";
      case RegimeFiscal.reelNormal:
        return "Réel Normal";
      case RegimeFiscal.declaratifControle:
        return "Déclaratif Contrôlé (BNC)";
    }
  }
}

/// Caisses de retraite pour professions libérales
enum CaisseRetraite {
  /// Sécurité Sociale des Indépendants (artisans, commerçants)
  ssi,

  /// Caisse Interprofessionnelle de Prévoyance et d'Assurance Vieillesse
  /// (architectes, géomètres, consultants...)
  cipav,

  /// Caisse Autonome de Retraite des Médecins de France
  carmf,

  /// Caisse Autonome de Retraite et de Prévoyance des Infirmiers
  carpimko,

  /// Caisse Nationale des Barreaux Français (avocats)
  cnbf,

  /// Caisse d'Assurance Vieillesse des Experts-Comptables
  cavec,

  /// Autre caisse spécifique
  autre,
}

extension CaisseRetraiteExtension on CaisseRetraite {
  String get label {
    switch (this) {
      case CaisseRetraite.ssi:
        return "SSI (Artisans, Commerçants)";
      case CaisseRetraite.cipav:
        return "CIPAV (Architectes, Consultants...)";
      case CaisseRetraite.carmf:
        return "CARMF (Médecins)";
      case CaisseRetraite.carpimko:
        return "CARPIMKO (Infirmiers, Kiné...)";
      case CaisseRetraite.cnbf:
        return "CNBF (Avocats)";
      case CaisseRetraite.cavec:
        return "CAVEC (Experts-Comptables)";
      case CaisseRetraite.autre:
        return "Autre caisse";
    }
  }
}

/// Type de ligne de chiffrage : matière ou service
enum TypeLigne {
  /// Matière première / Vente marchandise
  /// Taux micro: 12.3%
  /// Taux TNS/Assimilé: Selon marchandises
  matiere,

  /// Service / Prestation / Main d'œuvre
  /// Taux micro: 21.2% à 25.6%
  /// Taux TNS/Assimilé: ~45% à 80%
  service,
}

extension TypeLigneExtension on TypeLigne {
  String get label {
    switch (this) {
      case TypeLigne.matiere:
        return "Matière / Marchandise";
      case TypeLigne.service:
        return "Service / Prestation";
    }
  }

  IconData get icon {
    switch (this) {
      case TypeLigne.matiere:
        return Icons.inventory_2;
      case TypeLigne.service:
        return Icons.build;
    }
  }
}

/// Fréquence de déclaration et paiement des cotisations
enum FrequenceCotisation {
  /// Mensuelle (par défaut)
  mensuelle,

  /// Trimestrielle
  trimestrielle,
}

extension FrequenceCotisationExtension on FrequenceCotisation {
  String get label {
    switch (this) {
      case FrequenceCotisation.mensuelle:
        return "Mensuelle";
      case FrequenceCotisation.trimestrielle:
        return "Trimestrielle";
    }
  }

  /// Valeur stockée en base de données (rétrocompatibilité)
  String get dbValue {
    switch (this) {
      case FrequenceCotisation.mensuelle:
        return "mois";
      case FrequenceCotisation.trimestrielle:
        return "trimestre";
    }
  }

  static FrequenceCotisation fromDbValue(String? value) {
    if (value == "trimestre") return FrequenceCotisation.trimestrielle;
    return FrequenceCotisation.mensuelle;
  }
}
