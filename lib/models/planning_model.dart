class PlanningEvent {
  final String? id;
  final String? userId;
  final String titre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? clientId;
  final String type; // 'chantier', 'rdv', 'facture_echeance', 'devis_fin'
  final String? description;
  final bool isManual;

  PlanningEvent({
    this.id,
    this.userId,
    required this.titre,
    required this.dateDebut,
    required this.dateFin,
    this.clientId,
    this.type = 'chantier',
    this.description,
    this.isManual = true,
  });

  factory PlanningEvent.fromMap(Map<String, dynamic> map) {
    return PlanningEvent(
      id: map['id'],
      userId: map['user_id'],
      titre: map['titre'] ?? '',
      dateDebut: DateTime.parse(map['date_debut']),
      dateFin: DateTime.parse(map['date_fin']),
      clientId: map['client_id'],
      type: map['type'] ?? 'chantier',
      description: map['description'],
      isManual: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'titre': titre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'client_id': clientId,
      'type': type,
      'description': description,
    };
  }

  PlanningEvent copyWith({
    String? id,
    String? userId,
    String? titre,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? clientId,
    String? type,
    String? description,
    bool? isManual,
  }) {
    return PlanningEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      description: description ?? this.description,
      isManual: isManual ?? this.isManual,
    );
  }
}
