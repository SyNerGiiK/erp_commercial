import 'package:decimal/decimal.dart';

class Paiement {
  final String? id;
  final String factureId;
  final Decimal montant;
  final DateTime datePaiement;
  final String typePaiement;
  final String commentaire;
  final bool isAcompte;

  Paiement({
    this.id,
    required this.factureId,
    required this.montant,
    required this.datePaiement,
    this.typePaiement = 'virement',
    this.commentaire = '',
    this.isAcompte = false,
  });

  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      factureId: map['facture_id'],
      montant: Decimal.parse((map['montant'] ?? 0).toString()),
      datePaiement: DateTime.parse(map['date_paiement']),
      typePaiement: map['type_paiement'] ?? 'virement',
      commentaire: map['commentaire'] ?? '',
      isAcompte: map['is_acompte'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'facture_id': factureId,
      'montant': montant.toString(),
      'date_paiement': datePaiement.toIso8601String(),
      'type_paiement': typePaiement,
      'commentaire': commentaire,
      'is_acompte': isAcompte,
    };
  }

  Paiement copyWith({
    String? id,
    String? factureId,
    Decimal? montant,
    DateTime? datePaiement,
    String? typePaiement,
    String? commentaire,
    bool? isAcompte,
  }) {
    return Paiement(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      montant: montant ?? this.montant,
      datePaiement: datePaiement ?? this.datePaiement,
      typePaiement: typePaiement ?? this.typePaiement,
      commentaire: commentaire ?? this.commentaire,
      isAcompte: isAcompte ?? this.isAcompte,
    );
  }
}
