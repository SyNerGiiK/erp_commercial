import 'package:decimal/decimal.dart';

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
  }) : prixVenteUnitaire = prixVenteUnitaire ?? Decimal.zero;

  // Calculs dynamiques
  Decimal get totalAchat => quantite * prixAchatUnitaire;
  Decimal get totalVente => quantite * prixVenteUnitaire;

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
    );
  }
}
