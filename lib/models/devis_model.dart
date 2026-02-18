import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import 'chiffrage_model.dart';
import 'config_charges_model.dart';
import '../utils/calculations_utils.dart';

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

  // MODULE TVA
  final Decimal tauxTva;

  final String uiKey;

  Decimal get montantTva =>
      CalculationsUtils.calculateCharges(totalLigne, tauxTva);

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
    Decimal? tauxTva,
  })  : uiKey = uiKey ?? const Uuid().v4(),
        tauxTva = tauxTva ?? Decimal.fromInt(20);

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
      tauxTva: Decimal.parse((map['taux_tva'] ?? 20.0).toString()),
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
      'taux_tva': tauxTva.toString(),
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
    Decimal? tauxTva,
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
      tauxTva: tauxTva ?? this.tauxTva,
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
  final Decimal totalTva;
  final Decimal totalTtc;
  final Decimal remiseTaux;
  final Decimal acompteMontant;
  final Decimal acomptePercentage;

  final String conditionsReglement;
  final String? notesPubliques;
  final String? signatureUrl;
  final DateTime? dateSignature;
  final String? tvaIntra;

  // Avenant : reference au devis parent
  final String? devisParentId;

  final List<LigneDevis> lignes;
  final List<LigneChiffrage> chiffrage;

  // --- GETTERS WORKFLOW ---
  bool get isAvenant => devisParentId != null;
  bool get isEditable => statut == 'brouillon' || statut == 'envoye';
  bool get isLocked => statut == 'signe';
  bool get isTerminal => statut == 'annule';

  // --- GETTERS ANALYSE DE RENTABILITÉ ---

  /// Total des achats (matières premières)
  Decimal get totalAchats =>
      chiffrage.fold(Decimal.zero, (sum, ligne) => sum + ligne.totalAchat);

  /// Marge brute (CA - Achats)
  Decimal get margeBrute => totalHt - totalAchats;

  /// Taux de marge brute en %
  Decimal get tauxMargeBrute {
    if (totalHt <= Decimal.zero) return Decimal.zero;
    // Division returns Rational -> toDecimal() immédiatement
    return ((margeBrute * Decimal.fromInt(100)) / totalHt).toDecimal();
  }

  /// Net commercial (HT - Remise)
  Decimal get netCommercial {
    final remiseMontant =
        ((totalHt * remiseTaux) / Decimal.fromInt(100)).toDecimal();
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
    return ((resultat * Decimal.fromInt(100)) / totalHt).toDecimal();
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
    Decimal? totalTva,
    Decimal? totalTtc,
    required this.remiseTaux,
    required this.acompteMontant,
    Decimal? acomptePercentage,
    this.conditionsReglement = '',
    this.notesPubliques,
    this.signatureUrl,
    this.dateSignature,
    this.tvaIntra,
    this.devisParentId,
    this.lignes = const [],
    this.chiffrage = const [],
  })  : totalTva = totalTva ?? Decimal.zero,
        acomptePercentage = acomptePercentage ?? Decimal.fromInt(30),
        totalTtc = totalTtc ?? totalHt; // Fallback

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
      totalTva: Decimal.parse((map['total_tva'] ?? 0).toString()),
      totalTtc: Decimal.parse((map['total_ttc'] ?? 0).toString()),
      remiseTaux: Decimal.parse((map['remise_taux'] ?? 0).toString()),
      acompteMontant: Decimal.parse((map['acompte_montant'] ?? 0).toString()),
      acomptePercentage:
          Decimal.parse((map['acompte_percentage'] ?? 30).toString()),
      conditionsReglement: map['conditions_reglement'] ?? '',
      notesPubliques: map['notes_publiques'],
      tvaIntra: map['tva_intra'],
      devisParentId: map['devis_parent_id'],
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
      'total_tva': totalTva.toString(),
      'total_ttc': totalTtc.toString(),
      'remise_taux': remiseTaux.toString(),
      'acompte_montant': acompteMontant.toString(),
      'acompte_percentage': acomptePercentage.toString(),
      'conditions_reglement': conditionsReglement,
      'notes_publiques': notesPubliques,
      'signature_url': signatureUrl,
      'date_signature': dateSignature?.toIso8601String(),
      'tva_intra': tvaIntra,
      if (devisParentId != null) 'devis_parent_id': devisParentId,
      'lignes_devis': lignes.map((e) => e.toMap()).toList(),
      'lignes_chiffrages': chiffrage.map((e) => e.toMap()).toList(),
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
    Decimal? totalTva,
    Decimal? totalTtc,
    Decimal? remiseTaux,
    Decimal? acompteMontant,
    Decimal? acomptePercentage,
    String? conditionsReglement,
    String? notesPubliques,
    String? signatureUrl,
    DateTime? dateSignature,
    String? tvaIntra,
    String? devisParentId,
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
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      remiseTaux: remiseTaux ?? this.remiseTaux,
      acompteMontant: acompteMontant ?? this.acompteMontant,
      acomptePercentage: acomptePercentage ?? this.acomptePercentage,
      conditionsReglement: conditionsReglement ?? this.conditionsReglement,
      notesPubliques: notesPubliques ?? this.notesPubliques,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      dateSignature: dateSignature ?? this.dateSignature,
      tvaIntra: tvaIntra ?? this.tvaIntra,
      devisParentId: devisParentId ?? this.devisParentId,
      lignes: lignes ?? this.lignes,
      chiffrage: chiffrage ?? this.chiffrage,
    );
  }
}
