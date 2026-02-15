import 'package:decimal/decimal.dart';

class Article {
  final String? id;
  final String? userId;
  final String designation;
  final Decimal prixUnitaire;
  final Decimal prixAchat;
  final String unite;
  final String typeActivite; // 'service' ou 'vente'
  final Decimal tauxTva;

  Article({
    this.id,
    this.userId,
    required this.designation,
    required this.prixUnitaire,
    required this.prixAchat,
    this.unite = 'u',
    this.typeActivite = 'service',
    required this.tauxTva,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      userId: map['user_id'],
      designation: map['designation'] ?? '',
      prixUnitaire: Decimal.parse((map['prix_unitaire'] ?? 0).toString()),
      prixAchat: Decimal.parse((map['prix_achat'] ?? 0).toString()),
      unite: map['unite'] ?? 'u',
      typeActivite: map['type_activite'] ?? 'service',
      tauxTva: Decimal.parse((map['taux_tva'] ?? 20.0).toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'designation': designation,
      'prix_unitaire': prixUnitaire.toString(),
      'prix_achat': prixAchat.toString(),
      'unite': unite,
      'type_activite': typeActivite,
      'taux_tva': tauxTva.toString(),
    };
  }

  Article copyWith({
    String? id,
    String? userId,
    String? designation,
    Decimal? prixUnitaire,
    Decimal? prixAchat,
    String? unite,
    String? typeActivite,
    Decimal? tauxTva,
  }) {
    return Article(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designation: designation ?? this.designation,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      prixAchat: prixAchat ?? this.prixAchat,
      unite: unite ?? this.unite,
      typeActivite: typeActivite ?? this.typeActivite,
      tauxTva: tauxTva ?? this.tauxTva,
    );
  }
}
