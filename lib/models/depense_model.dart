import 'package:decimal/decimal.dart';

class Depense {
  final String? id;
  final String? userId;
  final String titre;
  final Decimal montant;
  final DateTime date;
  final String categorie;
  final String? fournisseur;
  final String? devisId;

  Depense({
    this.id,
    this.userId,
    required this.titre,
    required this.montant,
    required this.date,
    this.categorie = 'autre',
    this.fournisseur,
    this.devisId,
  });

  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'],
      userId: map['user_id'],
      titre: map['titre'] ?? '',
      montant: Decimal.parse((map['montant'] ?? 0).toString()),
      date: DateTime.parse(map['date']),
      categorie: map['categorie'] ?? 'autre',
      fournisseur: map['fournisseur'],
      devisId: map['devis_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'titre': titre,
      'montant': montant.toString(),
      'date': date.toIso8601String(),
      'categorie': categorie,
      'fournisseur': fournisseur,
      'devis_id': devisId,
    };
  }

  Depense copyWith({
    String? id,
    String? userId,
    String? titre,
    Decimal? montant,
    DateTime? date,
    String? categorie,
    String? fournisseur,
    String? devisId,
  }) {
    return Depense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      montant: montant ?? this.montant,
      date: date ?? this.date,
      categorie: categorie ?? this.categorie,
      fournisseur: fournisseur ?? this.fournisseur,
      devisId: devisId ?? this.devisId,
    );
  }
}
