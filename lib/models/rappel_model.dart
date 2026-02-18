/// Modèle de rappel / échéance
class Rappel {
  final String? id;
  final String? userId;
  final String titre;
  final String? description;
  final TypeRappel typeRappel;
  final DateTime dateEcheance;
  final bool estComplete;
  final bool estRecurrent;
  final String? frequenceRecurrence; // mensuelle, trimestrielle, annuelle
  final PrioriteRappel priorite;
  final String? entiteLieeId;
  final String? entiteLieeType;

  /// Jours restants avant l'échéance (négatif = en retard)
  int get joursRestants => dateEcheance.difference(DateTime.now()).inDays;

  /// L'échéance est-elle passée ?
  bool get estEnRetard => !estComplete && joursRestants < 0;

  /// L'échéance est-elle proche (< 7 jours) ?
  bool get estProche =>
      !estComplete && joursRestants >= 0 && joursRestants <= 7;

  Rappel({
    this.id,
    this.userId,
    required this.titre,
    this.description,
    this.typeRappel = TypeRappel.custom,
    required this.dateEcheance,
    this.estComplete = false,
    this.estRecurrent = false,
    this.frequenceRecurrence,
    this.priorite = PrioriteRappel.normale,
    this.entiteLieeId,
    this.entiteLieeType,
  });

  factory Rappel.fromMap(Map<String, dynamic> map) {
    return Rappel(
      id: map['id'],
      userId: map['user_id'],
      titre: map['titre'] ?? '',
      description: map['description'],
      typeRappel: TypeRappel.fromString(map['type_rappel'] ?? 'custom'),
      dateEcheance: DateTime.parse(map['date_echeance']),
      estComplete: map['est_complete'] ?? false,
      estRecurrent: map['est_recurrent'] ?? false,
      frequenceRecurrence: map['frequence_recurrence'],
      priorite: PrioriteRappel.fromString(map['priorite'] ?? 'normale'),
      entiteLieeId: map['entite_liee_id'],
      entiteLieeType: map['entite_liee_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'titre': titre,
      'description': description,
      'type_rappel': typeRappel.dbValue,
      'date_echeance': dateEcheance.toIso8601String(),
      'est_complete': estComplete,
      'est_recurrent': estRecurrent,
      'frequence_recurrence': frequenceRecurrence,
      'priorite': priorite.dbValue,
      'entite_liee_id': entiteLieeId,
      'entite_liee_type': entiteLieeType,
    };
  }

  Rappel copyWith({
    String? id,
    String? userId,
    String? titre,
    String? description,
    TypeRappel? typeRappel,
    DateTime? dateEcheance,
    bool? estComplete,
    bool? estRecurrent,
    String? frequenceRecurrence,
    PrioriteRappel? priorite,
    String? entiteLieeId,
    String? entiteLieeType,
  }) {
    return Rappel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      typeRappel: typeRappel ?? this.typeRappel,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      estComplete: estComplete ?? this.estComplete,
      estRecurrent: estRecurrent ?? this.estRecurrent,
      frequenceRecurrence: frequenceRecurrence ?? this.frequenceRecurrence,
      priorite: priorite ?? this.priorite,
      entiteLieeId: entiteLieeId ?? this.entiteLieeId,
      entiteLieeType: entiteLieeType ?? this.entiteLieeType,
    );
  }
}

/// Types de rappels possibles
enum TypeRappel {
  urssaf,
  cfe,
  tva,
  impots,
  custom,
  echeanceFacture,
  finDevis;

  String get dbValue {
    switch (this) {
      case TypeRappel.urssaf:
        return 'urssaf';
      case TypeRappel.cfe:
        return 'cfe';
      case TypeRappel.tva:
        return 'tva';
      case TypeRappel.impots:
        return 'impots';
      case TypeRappel.custom:
        return 'custom';
      case TypeRappel.echeanceFacture:
        return 'echeance_facture';
      case TypeRappel.finDevis:
        return 'fin_devis';
    }
  }

  String get label {
    switch (this) {
      case TypeRappel.urssaf:
        return 'URSSAF';
      case TypeRappel.cfe:
        return 'CFE';
      case TypeRappel.tva:
        return 'TVA';
      case TypeRappel.impots:
        return 'Impôts';
      case TypeRappel.custom:
        return 'Personnalisé';
      case TypeRappel.echeanceFacture:
        return 'Échéance facture';
      case TypeRappel.finDevis:
        return 'Fin validité devis';
    }
  }

  String get icon {
    switch (this) {
      case TypeRappel.urssaf:
        return '🏛️';
      case TypeRappel.cfe:
        return '🏢';
      case TypeRappel.tva:
        return '📊';
      case TypeRappel.impots:
        return '📋';
      case TypeRappel.custom:
        return '🔔';
      case TypeRappel.echeanceFacture:
        return '💰';
      case TypeRappel.finDevis:
        return '📝';
    }
  }

  static TypeRappel fromString(String value) {
    switch (value) {
      case 'urssaf':
        return TypeRappel.urssaf;
      case 'cfe':
        return TypeRappel.cfe;
      case 'tva':
        return TypeRappel.tva;
      case 'impots':
        return TypeRappel.impots;
      case 'echeance_facture':
        return TypeRappel.echeanceFacture;
      case 'fin_devis':
        return TypeRappel.finDevis;
      default:
        return TypeRappel.custom;
    }
  }
}

/// Priorité d'un rappel
enum PrioriteRappel {
  basse,
  normale,
  haute,
  urgente;

  String get dbValue => name;

  String get label {
    switch (this) {
      case PrioriteRappel.basse:
        return 'Basse';
      case PrioriteRappel.normale:
        return 'Normale';
      case PrioriteRappel.haute:
        return 'Haute';
      case PrioriteRappel.urgente:
        return 'Urgente';
    }
  }

  static PrioriteRappel fromString(String value) {
    return PrioriteRappel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PrioriteRappel.normale,
    );
  }
}
