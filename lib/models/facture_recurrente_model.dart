import 'package:decimal/decimal.dart';

/// Ligne d'une facture récurrente (template)
class LigneFactureRecurrente {
  final String? id;
  final String description;
  final Decimal quantite;
  final Decimal prixUnitaire;
  final Decimal totalLigne;
  final String typeActivite;
  final String unite;
  final Decimal tauxTva;
  final int ordre;

  LigneFactureRecurrente({
    this.id,
    required this.description,
    required this.quantite,
    required this.prixUnitaire,
    required this.totalLigne,
    this.typeActivite = 'service',
    this.unite = 'u',
    Decimal? tauxTva,
    this.ordre = 0,
  }) : tauxTva = tauxTva ?? Decimal.fromInt(20);

  factory LigneFactureRecurrente.fromMap(Map<String, dynamic> map) {
    return LigneFactureRecurrente(
      id: map['id'],
      description: map['description'] ?? '',
      quantite: Decimal.parse((map['quantite'] ?? 0).toString()),
      prixUnitaire: Decimal.parse((map['prix_unitaire'] ?? 0).toString()),
      totalLigne: Decimal.parse((map['total_ligne'] ?? 0).toString()),
      typeActivite: map['type_activite'] ?? 'service',
      unite: map['unite'] ?? 'u',
      tauxTva: Decimal.parse((map['taux_tva'] ?? 20).toString()),
      ordre: map['ordre'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'quantite': quantite.toString(),
      'prix_unitaire': prixUnitaire.toString(),
      'total_ligne': totalLigne.toString(),
      'type_activite': typeActivite,
      'unite': unite,
      'taux_tva': tauxTva.toString(),
      'ordre': ordre,
    };
  }

  LigneFactureRecurrente copyWith({
    String? id,
    String? description,
    Decimal? quantite,
    Decimal? prixUnitaire,
    Decimal? totalLigne,
    String? typeActivite,
    String? unite,
    Decimal? tauxTva,
    int? ordre,
  }) {
    return LigneFactureRecurrente(
      id: id ?? this.id,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      totalLigne: totalLigne ?? this.totalLigne,
      typeActivite: typeActivite ?? this.typeActivite,
      unite: unite ?? this.unite,
      tauxTva: tauxTva ?? this.tauxTva,
      ordre: ordre ?? this.ordre,
    );
  }
}

/// Fréquence de récurrence
enum FrequenceRecurrence {
  hebdomadaire,
  mensuelle,
  trimestrielle,
  annuelle;

  String get label {
    switch (this) {
      case FrequenceRecurrence.hebdomadaire:
        return 'Hebdomadaire';
      case FrequenceRecurrence.mensuelle:
        return 'Mensuelle';
      case FrequenceRecurrence.trimestrielle:
        return 'Trimestrielle';
      case FrequenceRecurrence.annuelle:
        return 'Annuelle';
    }
  }

  String get dbValue => name;

  static FrequenceRecurrence fromString(String value) {
    return FrequenceRecurrence.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FrequenceRecurrence.mensuelle,
    );
  }
}

/// Modèle de facture récurrente (template + planning)
class FactureRecurrente {
  final String? id;
  final String? userId;
  final String clientId;
  final String objet;
  final FrequenceRecurrence frequence;
  final DateTime prochaineEmission;
  final int jourEmission;
  final bool estActive;
  final Decimal totalHt;
  final Decimal totalTva;
  final Decimal totalTtc;
  final Decimal remiseTaux;
  final String conditionsReglement;
  final String? notesPubliques;
  final String devise;
  final int nbFacturesGenerees;
  final DateTime? derniereGeneration;
  final DateTime? dateFin;
  final List<LigneFactureRecurrente> lignes;

  FactureRecurrente({
    this.id,
    this.userId,
    required this.clientId,
    required this.objet,
    this.frequence = FrequenceRecurrence.mensuelle,
    required this.prochaineEmission,
    this.jourEmission = 1,
    this.estActive = true,
    required this.totalHt,
    Decimal? totalTva,
    Decimal? totalTtc,
    required this.remiseTaux,
    this.conditionsReglement = '',
    this.notesPubliques,
    this.devise = 'EUR',
    this.nbFacturesGenerees = 0,
    this.derniereGeneration,
    this.dateFin,
    this.lignes = const [],
  })  : totalTva = totalTva ?? Decimal.zero,
        totalTtc = totalTtc ?? totalHt;

  factory FactureRecurrente.fromMap(Map<String, dynamic> map) {
    return FactureRecurrente(
      id: map['id'],
      userId: map['user_id'],
      clientId: map['client_id'],
      objet: map['objet'] ?? '',
      frequence:
          FrequenceRecurrence.fromString(map['frequence'] ?? 'mensuelle'),
      prochaineEmission: DateTime.parse(map['prochaine_emission']),
      jourEmission: map['jour_emission'] ?? 1,
      estActive: map['est_active'] ?? true,
      totalHt: Decimal.parse((map['total_ht'] ?? 0).toString()),
      totalTva: Decimal.parse((map['total_tva'] ?? 0).toString()),
      totalTtc: Decimal.parse((map['total_ttc'] ?? 0).toString()),
      remiseTaux: Decimal.parse((map['remise_taux'] ?? 0).toString()),
      conditionsReglement: map['conditions_reglement'] ?? '',
      notesPubliques: map['notes_publiques'],
      devise: map['devise'] ?? 'EUR',
      nbFacturesGenerees: map['nb_factures_generees'] ?? 0,
      derniereGeneration: map['derniere_generation'] != null
          ? DateTime.parse(map['derniere_generation'])
          : null,
      dateFin: map['date_fin'] != null ? DateTime.parse(map['date_fin']) : null,
      lignes: (map['lignes_facture_recurrente'] as List<dynamic>?)
              ?.map((e) => LigneFactureRecurrente.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'client_id': clientId,
      'objet': objet,
      'frequence': frequence.dbValue,
      'prochaine_emission': prochaineEmission.toIso8601String(),
      'jour_emission': jourEmission,
      'est_active': estActive,
      'total_ht': totalHt.toString(),
      'total_tva': totalTva.toString(),
      'total_ttc': totalTtc.toString(),
      'remise_taux': remiseTaux.toString(),
      'conditions_reglement': conditionsReglement,
      'notes_publiques': notesPubliques,
      'devise': devise,
      'nb_factures_generees': nbFacturesGenerees,
      'derniere_generation': derniereGeneration?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'lignes_facture_recurrente': lignes.map((e) => e.toMap()).toList(),
    };
  }

  FactureRecurrente copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? objet,
    FrequenceRecurrence? frequence,
    DateTime? prochaineEmission,
    int? jourEmission,
    bool? estActive,
    Decimal? totalHt,
    Decimal? totalTva,
    Decimal? totalTtc,
    Decimal? remiseTaux,
    String? conditionsReglement,
    String? notesPubliques,
    String? devise,
    int? nbFacturesGenerees,
    DateTime? derniereGeneration,
    DateTime? dateFin,
    List<LigneFactureRecurrente>? lignes,
  }) {
    return FactureRecurrente(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      objet: objet ?? this.objet,
      frequence: frequence ?? this.frequence,
      prochaineEmission: prochaineEmission ?? this.prochaineEmission,
      jourEmission: jourEmission ?? this.jourEmission,
      estActive: estActive ?? this.estActive,
      totalHt: totalHt ?? this.totalHt,
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      remiseTaux: remiseTaux ?? this.remiseTaux,
      conditionsReglement: conditionsReglement ?? this.conditionsReglement,
      notesPubliques: notesPubliques ?? this.notesPubliques,
      devise: devise ?? this.devise,
      nbFacturesGenerees: nbFacturesGenerees ?? this.nbFacturesGenerees,
      derniereGeneration: derniereGeneration ?? this.derniereGeneration,
      dateFin: dateFin ?? this.dateFin,
      lignes: lignes ?? this.lignes,
    );
  }
}
