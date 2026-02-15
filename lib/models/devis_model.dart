import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import 'chiffrage_model.dart';
import 'config_charges_model.dart';

class LigneDevis {
  final String? id;
  final String description;
  final Decimal quantite;
  final Decimal prixUnitaire;
  final Decimal totalLigne;
  final String typeActivite;
  final String unite;

  final String type;
  final int ordre;
  final bool estGras;
  final bool estItalique;
  final bool estSouligne;

  // Clé stable pour l'UI (Drag & Drop)
  final String uiKey;

  LigneDevis({
    this.id,
    required this.description,
    required this.quantite,
    required this.prixUnitaire,
    required this.totalLigne,
    this.typeActivite = 'service',
    this.unite = 'u',
    this.type = 'article',
    this.ordre = 0,
    this.estGras = false,
    this.estItalique = false,
    this.estSouligne = false,
    String? uiKey,
  }) : uiKey = uiKey ?? const Uuid().v4();

  factory LigneDevis.fromMap(Map<String, dynamic> map) {
    return LigneDevis(
      id: map['id'],
      description: map['description'] ?? '',
      quantite: Decimal.parse((map['quantite'] ?? 0).toString()),
      prixUnitaire: Decimal.parse((map['prix_unitaire'] ?? 0).toString()),
      totalLigne: Decimal.parse((map['total_ligne'] ?? 0).toString()),
      typeActivite: map['type_activite'] ?? 'service',
      unite: map['unite'] ?? 'u',
      type: map['type'] ?? 'article',
      ordre: map['ordre'] ?? 0,
      estGras: map['est_gras'] ?? false,
      estItalique: map['est_italique'] ?? false,
      estSouligne: map['est_souligne'] ?? false,
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
      'type': type,
      'ordre': ordre,
      'est_gras': estGras,
      'est_italique': estItalique,
      'est_souligne': estSouligne,
    };
  }

  LigneDevis copyWith({
    String? id,
    String? description,
    Decimal? quantite,
    Decimal? prixUnitaire,
    Decimal? totalLigne,
    String? typeActivite,
    String? unite,
    String? type,
    int? ordre,
    bool? estGras,
    bool? estItalique,
    bool? estSouligne,
  }) {
    return LigneDevis(
      id: id ?? this.id,
      uiKey: uiKey, // On conserve la clé
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      totalLigne: totalLigne ?? this.totalLigne,
      typeActivite: typeActivite ?? this.typeActivite,
      unite: unite ?? this.unite,
      type: type ?? this.type,
      ordre: ordre ?? this.ordre,
      estGras: estGras ?? this.estGras,
      estItalique: estItalique ?? this.estItalique,
      estSouligne: estSouligne ?? this.estSouligne,
    );
  }
}

class Devis {
  final String? id;
  final String? userId;
  final String numeroDevis;
  final String objet;
  final String clientId;
  final DateTime dateEmission;
  final DateTime dateValidite;
  final String statut;
  final bool estTransforme;
  final bool estArchive;

  final Decimal totalHt;
  final Decimal remiseTaux;
  final Decimal acompteMontant;

  final String conditionsReglement;
  final String? notesPubliques;
  final String? signatureUrl;
  final DateTime? dateSignature;
  final String? tvaIntra;

  final List<LigneDevis> lignes;
  final List<LigneChiffrage> chiffrage;

  // --- GETTERS ANALYSE DE RENTABILITÉ ---

  /// Total des achats (matières premières)
  Decimal get totalAchats =>
      chiffrage.fold(Decimal.zero, (sum, ligne) => sum + ligne.totalAchat);

  /// Marge brute (CA - Achats)
  Decimal get margeBrute => totalHt - totalAchats;

  /// Taux de marge brute en %
  Decimal get tauxMargeBrute {
    if (totalHt <= Decimal.zero) return Decimal.zero;
    // Division returns Rational -> toDecimal()
    final tauxRational = (margeBrute * Decimal.fromInt(100)) / totalHt;
    return tauxRational.toDecimal();
  }

  /// Net commercial (HT - Remise)
  Decimal get netCommercial {
    final remiseRational = (totalHt * remiseTaux) / Decimal.fromInt(100);
    final remiseMontant = remiseRational.toDecimal();
    return totalHt - remiseMontant;
  }

  /// Calcule le montant total des charges sociales
  Decimal calculerChargesSociales(ConfigCharges config) {
    return config.calculerCharges(netCommercial);
  }

  /// Calcule le détail des charges par type
  Map<String, Decimal> calculerDetailCharges(ConfigCharges config) {
    return config.calculerDetailCharges(netCommercial);
  }

  /// Calcule le résultat net (Marge brute - Charges sociales)
  Decimal calculerResultatNet(ConfigCharges config) {
    return margeBrute - calculerChargesSociales(config);
  }

  /// Taux de résultat net en %
  Decimal calculerTauxResultatNet(ConfigCharges config) {
    if (totalHt <= Decimal.zero) return Decimal.zero;
    final resultat = calculerResultatNet(config);
    final tauxRational = (resultat * Decimal.fromInt(100)) / totalHt;
    return tauxRational.toDecimal();
  }

  Devis({
    this.id,
    this.userId,
    this.numeroDevis = '',
    required this.objet,
    required this.clientId,
    required this.dateEmission,
    required this.dateValidite,
    this.statut = 'brouillon',
    this.estTransforme = false,
    this.estArchive = false,
    required this.totalHt,
    required this.remiseTaux,
    required this.acompteMontant,
    this.conditionsReglement = '',
    this.notesPubliques,
    this.signatureUrl,
    this.dateSignature,
    this.tvaIntra,
    this.lignes = const [],
    this.chiffrage = const [],
  });

  factory Devis.fromMap(Map<String, dynamic> map) {
    return Devis(
      id: map['id'],
      userId: map['user_id'],
      numeroDevis: map['numero_devis'] ?? '',
      objet: map['objet'] ?? '',
      clientId: map['client_id'],
      dateEmission: DateTime.parse(map['date_emission']),
      dateValidite: DateTime.parse(map['date_validite']),
      statut: map['statut'] ?? 'brouillon',
      estTransforme: map['est_transforme'] ?? false,
      estArchive: map['est_archive'] ?? false,
      signatureUrl: map['signature_url'],
      dateSignature: map['date_signature'] != null
          ? DateTime.parse(map['date_signature'])
          : null,
      totalHt: Decimal.parse((map['total_ht'] ?? 0).toString()),
      remiseTaux: Decimal.parse((map['remise_taux'] ?? 0).toString()),
      acompteMontant: Decimal.parse((map['acompte_montant'] ?? 0).toString()),
      conditionsReglement: map['conditions_reglement'] ?? '',
      notesPubliques: map['notes_publiques'],
      tvaIntra: map['tva_intra'],
      lignes: (map['lignes_devis'] as List<dynamic>?)
              ?.map((e) => LigneDevis.fromMap(e))
              .toList() ??
          [],
      chiffrage: (map['lignes_chiffrages'] as List<dynamic>?)
              ?.map((e) => LigneChiffrage.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'numero_devis': numeroDevis,
      'objet': objet,
      'client_id': clientId,
      'date_emission': dateEmission.toIso8601String(),
      'date_validite': dateValidite.toIso8601String(),
      'statut': statut,
      'est_transforme': estTransforme,
      'est_archive': estArchive,
      'total_ht': totalHt.toString(),
      'remise_taux': remiseTaux.toString(),
      'acompte_montant': acompteMontant.toString(),
      'conditions_reglement': conditionsReglement,
      'notes_publiques': notesPubliques,
      'signature_url': signatureUrl,
      'date_signature': dateSignature?.toIso8601String(),
      'tva_intra': tvaIntra,
    };
  }

  Devis copyWith({
    String? id,
    String? userId,
    String? numeroDevis,
    String? objet,
    String? clientId,
    DateTime? dateEmission,
    DateTime? dateValidite,
    String? statut,
    bool? estTransforme,
    bool? estArchive,
    Decimal? totalHt,
    Decimal? remiseTaux,
    Decimal? acompteMontant,
    String? conditionsReglement,
    String? notesPubliques,
    String? signatureUrl,
    DateTime? dateSignature,
    String? tvaIntra,
    List<LigneDevis>? lignes,
    List<LigneChiffrage>? chiffrage,
  }) {
    return Devis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      numeroDevis: numeroDevis ?? this.numeroDevis,
      objet: objet ?? this.objet,
      clientId: clientId ?? this.clientId,
      dateEmission: dateEmission ?? this.dateEmission,
      dateValidite: dateValidite ?? this.dateValidite,
      statut: statut ?? this.statut,
      estTransforme: estTransforme ?? this.estTransforme,
      estArchive: estArchive ?? this.estArchive,
      totalHt: totalHt ?? this.totalHt,
      remiseTaux: remiseTaux ?? this.remiseTaux,
      acompteMontant: acompteMontant ?? this.acompteMontant,
      conditionsReglement: conditionsReglement ?? this.conditionsReglement,
      notesPubliques: notesPubliques ?? this.notesPubliques,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      dateSignature: dateSignature ?? this.dateSignature,
      tvaIntra: tvaIntra ?? this.tvaIntra,
      lignes: lignes ?? this.lignes,
      chiffrage: chiffrage ?? this.chiffrage,
    );
  }
}
