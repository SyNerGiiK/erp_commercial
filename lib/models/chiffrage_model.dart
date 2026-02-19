import 'package:decimal/decimal.dart';

/// Type de coût interne pour le suivi d'avancement
enum TypeChiffrage { materiel, mainDoeuvre }

extension TypeChiffrageExtension on TypeChiffrage {
  String get dbValue {
    switch (this) {
      case TypeChiffrage.materiel:
        return 'materiel';
      case TypeChiffrage.mainDoeuvre:
        return 'main_doeuvre';
    }
  }

  String get label {
    switch (this) {
      case TypeChiffrage.materiel:
        return 'Matériel / Fourniture';
      case TypeChiffrage.mainDoeuvre:
        return "Main d'œuvre";
    }
  }

  String get shortLabel {
    switch (this) {
      case TypeChiffrage.materiel:
        return 'MAT';
      case TypeChiffrage.mainDoeuvre:
        return 'MO';
    }
  }

  IconLabel get iconInfo {
    switch (this) {
      case TypeChiffrage.materiel:
        return const IconLabel('inventory_2', 'Matériel');
      case TypeChiffrage.mainDoeuvre:
        return const IconLabel('engineering', 'Main d\'œuvre');
    }
  }

  static TypeChiffrage fromDbValue(String? value) {
    switch (value) {
      case 'main_doeuvre':
        return TypeChiffrage.mainDoeuvre;
      case 'materiel':
      default:
        return TypeChiffrage.materiel;
    }
  }
}

/// Aide pour les icônes (évite d'importer Flutter dans le modèle)
class IconLabel {
  final String iconName;
  final String label;
  const IconLabel(this.iconName, this.label);
}

class LigneChiffrage {
  final String? id;
  final String? userId;
  final String? devisId;
  final String? factureId;
  final String designation;
  final Decimal quantite;
  final String unite;
  final Decimal prixAchatUnitaire;
  final Decimal prixVenteUnitaire;

  // === Nouveaux champs : Progress Billing ===
  final String? linkedLigneDevisId;
  final TypeChiffrage typeChiffrage;
  final bool estAchete;
  final Decimal avancementMo;
  final Decimal prixVenteInterne;

  LigneChiffrage({
    this.id,
    this.userId,
    this.devisId,
    this.factureId,
    required this.designation,
    required this.quantite,
    this.unite = 'u',
    required this.prixAchatUnitaire,
    Decimal? prixVenteUnitaire,
    this.linkedLigneDevisId,
    this.typeChiffrage = TypeChiffrage.materiel,
    this.estAchete = false,
    Decimal? avancementMo,
    Decimal? prixVenteInterne,
  })  : prixVenteUnitaire = prixVenteUnitaire ?? Decimal.zero,
        avancementMo = avancementMo ?? Decimal.zero,
        prixVenteInterne = prixVenteInterne ?? Decimal.zero;

  // Calculs dynamiques
  Decimal get totalAchat => quantite * prixAchatUnitaire;
  Decimal get totalVente => quantite * prixVenteUnitaire;

  /// Valeur réalisée pour le calcul d'avancement de la ligne parente.
  /// - Matériel : 100% si acheté, 0% sinon (binaire)
  /// - Main d'œuvre : proportionnel à avancementMo
  Decimal get valeurRealisee {
    if (typeChiffrage == TypeChiffrage.materiel) {
      return estAchete ? prixVenteInterne : Decimal.zero;
    } else {
      // MO : prixVenteInterne * (avancementMo / 100)
      if (avancementMo == Decimal.zero) return Decimal.zero;
      return ((prixVenteInterne * avancementMo) / Decimal.fromInt(100))
          .toDecimal();
    }
  }

  /// Pourcentage d'avancement individuel de cette ligne de chiffrage
  Decimal get avancementPourcent {
    if (typeChiffrage == TypeChiffrage.materiel) {
      return estAchete ? Decimal.fromInt(100) : Decimal.zero;
    }
    return avancementMo;
  }

  factory LigneChiffrage.fromMap(Map<String, dynamic> map) {
    return LigneChiffrage(
      id: map['id'],
      userId: map['user_id'],
      devisId: map['devis_id'],
      factureId: map['facture_id'],
      designation: map['designation'] ?? '',
      quantite: Decimal.parse((map['quantite'] ?? 1).toString()),
      unite: map['unite'] ?? 'u',
      prixAchatUnitaire:
          Decimal.parse((map['prix_achat_unitaire'] ?? 0).toString()),
      prixVenteUnitaire:
          Decimal.parse((map['prix_vente_unitaire'] ?? 0).toString()),
      linkedLigneDevisId: map['linked_ligne_devis_id'],
      typeChiffrage: TypeChiffrageExtension.fromDbValue(map['type_chiffrage']),
      estAchete: map['est_achete'] ?? false,
      avancementMo: Decimal.parse((map['avancement_mo'] ?? 0).toString()),
      prixVenteInterne:
          Decimal.parse((map['prix_vente_interne'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'devis_id': devisId,
      'facture_id': factureId,
      'designation': designation,
      'quantite': quantite.toString(),
      'unite': unite,
      'prix_achat_unitaire': prixAchatUnitaire.toString(),
      'prix_vente_unitaire': prixVenteUnitaire.toString(),
      'linked_ligne_devis_id': linkedLigneDevisId,
      'type_chiffrage': typeChiffrage.dbValue,
      'est_achete': estAchete,
      'avancement_mo': avancementMo.toString(),
      'prix_vente_interne': prixVenteInterne.toString(),
    };
  }

  LigneChiffrage copyWith({
    String? id,
    String? userId,
    String? devisId,
    String? factureId,
    String? designation,
    Decimal? quantite,
    String? unite,
    Decimal? prixAchatUnitaire,
    Decimal? prixVenteUnitaire,
    String? linkedLigneDevisId,
    TypeChiffrage? typeChiffrage,
    bool? estAchete,
    Decimal? avancementMo,
    Decimal? prixVenteInterne,
  }) {
    return LigneChiffrage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      devisId: devisId ?? this.devisId,
      factureId: factureId ?? this.factureId,
      designation: designation ?? this.designation,
      quantite: quantite ?? this.quantite,
      unite: unite ?? this.unite,
      prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
      prixVenteUnitaire: prixVenteUnitaire ?? this.prixVenteUnitaire,
      linkedLigneDevisId: linkedLigneDevisId ?? this.linkedLigneDevisId,
      typeChiffrage: typeChiffrage ?? this.typeChiffrage,
      estAchete: estAchete ?? this.estAchete,
      avancementMo: avancementMo ?? this.avancementMo,
      prixVenteInterne: prixVenteInterne ?? this.prixVenteInterne,
    );
  }
}
