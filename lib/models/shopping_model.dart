import 'package:decimal/decimal.dart';

class ShoppingItem {
  final String? id;
  final String? userId;
  final String designation;
  final Decimal quantite;
  final Decimal prixUnitaire;
  final String unite;
  final bool estAchete;

  ShoppingItem({
    this.id,
    this.userId,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    this.unite = 'u',
    this.estAchete = false,
  });

  Decimal get totalLigne => quantite * prixUnitaire;

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      userId: map['user_id'],
      designation: map['designation'] ?? '',
      quantite: Decimal.parse((map['quantite'] ?? 0).toString()),
      prixUnitaire: Decimal.parse((map['prix_unitaire'] ?? 0).toString()),
      unite: map['unite'] ?? 'u',
      estAchete: map['est_achete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'designation': designation,
      'quantite': quantite.toString(),
      'prix_unitaire': prixUnitaire.toString(),
      'unite': unite,
      'est_achete': estAchete,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? designation,
    Decimal? quantite,
    Decimal? prixUnitaire,
    String? unite,
    bool? estAchete,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designation: designation ?? this.designation,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      unite: unite ?? this.unite,
      estAchete: estAchete ?? this.estAchete,
    );
  }
}
