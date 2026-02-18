import 'package:decimal/decimal.dart';

/// Modèle de suivi du temps d'activité
class TempsActivite {
  final String? id;
  final String? userId;
  final String? clientId;
  final String projet;
  final String description;
  final DateTime dateActivite;
  final int dureeMinutes;
  final Decimal tauxHoraire;
  final bool estFacturable;
  final bool estFacture;
  final String? factureId;

  /// Montant calculé = (durée en heures) × taux horaire
  Decimal get montant {
    if (dureeMinutes <= 0 || tauxHoraire <= Decimal.zero) return Decimal.zero;
    final heures = Decimal.parse(dureeMinutes.toString()) / Decimal.fromInt(60);
    return (heures.toDecimal(scaleOnInfinitePrecision: 10) * tauxHoraire);
  }

  /// Durée formatée (ex: "2h30")
  String get dureeFormatee {
    final h = dureeMinutes ~/ 60;
    final m = dureeMinutes % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  TempsActivite({
    this.id,
    this.userId,
    this.clientId,
    this.projet = '',
    required this.description,
    required this.dateActivite,
    required this.dureeMinutes,
    Decimal? tauxHoraire,
    this.estFacturable = true,
    this.estFacture = false,
    this.factureId,
  }) : tauxHoraire = tauxHoraire ?? Decimal.zero;

  factory TempsActivite.fromMap(Map<String, dynamic> map) {
    return TempsActivite(
      id: map['id'],
      userId: map['user_id'],
      clientId: map['client_id'],
      projet: map['projet'] ?? '',
      description: map['description'] ?? '',
      dateActivite: DateTime.parse(map['date_activite']),
      dureeMinutes: map['duree_minutes'] ?? 0,
      tauxHoraire: Decimal.parse((map['taux_horaire'] ?? 0).toString()),
      estFacturable: map['est_facturable'] ?? true,
      estFacture: map['est_facture'] ?? false,
      factureId: map['facture_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'client_id': clientId,
      'projet': projet,
      'description': description,
      'date_activite': dateActivite.toIso8601String(),
      'duree_minutes': dureeMinutes,
      'taux_horaire': tauxHoraire.toString(),
      'est_facturable': estFacturable,
      'est_facture': estFacture,
      'facture_id': factureId,
    };
  }

  TempsActivite copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? projet,
    String? description,
    DateTime? dateActivite,
    int? dureeMinutes,
    Decimal? tauxHoraire,
    bool? estFacturable,
    bool? estFacture,
    String? factureId,
  }) {
    return TempsActivite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      projet: projet ?? this.projet,
      description: description ?? this.description,
      dateActivite: dateActivite ?? this.dateActivite,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      tauxHoraire: tauxHoraire ?? this.tauxHoraire,
      estFacturable: estFacturable ?? this.estFacturable,
      estFacture: estFacture ?? this.estFacture,
      factureId: factureId ?? this.factureId,
    );
  }
}
