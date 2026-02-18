import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import 'paiement_model.dart';
import 'chiffrage_model.dart';
import '../utils/calculations_utils.dart';

class LigneFacture {
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

  // MODULE 2: Situation & UI
  final Decimal avancement;
  final String uiKey;

  Decimal get montantTva =>
      CalculationsUtils.calculateCharges(totalLigne, tauxTva);

  LigneFacture({
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
    Decimal? avancement,
    String? uiKey,
    Decimal? tauxTva,
  })  : avancement = avancement ?? Decimal.fromInt(100),
        uiKey = uiKey ?? const Uuid().v4(),
        tauxTva = tauxTva ?? Decimal.fromInt(20);

  factory LigneFacture.fromMap(Map<String, dynamic> map) {
    return LigneFacture(
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
      avancement: Decimal.parse((map['avancement'] ?? 100).toString()),
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
      'avancement': avancement.toString(),
      'taux_tva': tauxTva.toString(),
    };
  }

  LigneFacture copyWith({
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
    Decimal? avancement,
    Decimal? tauxTva,
  }) {
    return LigneFacture(
      id: id ?? this.id,
      uiKey: uiKey,
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
      avancement: avancement ?? this.avancement,
      tauxTva: tauxTva ?? this.tauxTva,
    );
  }
}

class Facture {
  final String? id;
  final String? userId;
  final String numeroFacture;
  final String objet;
  final String clientId;
  final String? devisSourceId;
  final String? factureSourceId; // Pour les Avoirs
  final String? parentDocumentId; // Pour lien parent (avoir -> facture)
  final String typeDocument; // 'facture' ou 'avoir'
  final DateTime dateEmission;
  final DateTime dateEcheance;
  final DateTime? dateValidation;
  final String statut;
  final String statutJuridique;
  final bool estArchive;

  // MODULE 2: Type de facture
  final String type; // standard, acompte, situation, solde
  final Decimal? avancementGlobal; // Optionnel, pour suivi macro

  // MODULE 3: Signature
  final String? signatureUrl;
  final DateTime? dateSignature;

  final Decimal totalHt;
  final Decimal totalTva;
  final Decimal totalTtc;
  final Decimal remiseTaux;
  final Decimal acompteDejaRegle;

  final String conditionsReglement;
  final String? notesPubliques;
  final String? tvaIntra;

  final List<LigneFacture> lignes;
  final List<Paiement> paiements;
  final List<LigneChiffrage> chiffrage;

  Decimal get netAPayer => totalTtc - acompteDejaRegle - totalPaiements;
  Decimal get totalPaiements =>
      paiements.fold(Decimal.zero, (prev, element) => prev + element.montant);
  bool get estSoldee => netAPayer <= Decimal.zero;

  Facture({
    this.id,
    this.userId,
    this.numeroFacture = '',
    required this.objet,
    required this.clientId,
    this.devisSourceId,
    this.factureSourceId,
    this.parentDocumentId,
    this.typeDocument = 'facture',
    required this.dateEmission,
    required this.dateEcheance,
    this.dateValidation,
    this.statut = 'brouillon',
    this.statutJuridique = 'brouillon',
    this.estArchive = false,
    this.type = 'standard',
    this.avancementGlobal,
    this.signatureUrl,
    this.dateSignature,
    required this.totalHt,
    Decimal? totalTva,
    Decimal? totalTtc,
    required this.remiseTaux,
    required this.acompteDejaRegle,
    this.conditionsReglement = '',
    this.notesPubliques,
    this.tvaIntra,
    this.lignes = const [],
    this.paiements = const [],
    this.chiffrage = const [],
  })  : totalTva = totalTva ?? Decimal.zero,
        totalTtc = totalTtc ?? totalHt; // Fallback pour compatibilité

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      id: map['id'],
      userId: map['user_id'],
      numeroFacture: map['numero_facture'] ?? '',
      objet: map['objet'] ?? '',
      clientId: map['client_id'],
      devisSourceId: map['devis_source_id'],
      factureSourceId: map['facture_source_id'],
      parentDocumentId: map['parent_document_id'],
      typeDocument: map['type_document'] ?? 'facture',
      dateEmission: DateTime.parse(map['date_emission']),
      dateEcheance: DateTime.parse(map['date_echeance']),
      dateValidation: map['date_validation'] != null
          ? DateTime.parse(map['date_validation'])
          : null,
      statut: map['statut'] ?? 'brouillon',
      statutJuridique: map['statut_juridique'] ?? 'brouillon',
      estArchive: map['est_archive'] ?? false,
      type: map['type'] ?? 'standard',
      avancementGlobal: map['avancement_global'] != null
          ? Decimal.parse(map['avancement_global'].toString())
          : null,
      signatureUrl: map['signature_url'],
      dateSignature: map['date_signature'] != null
          ? DateTime.parse(map['date_signature'])
          : null,
      totalHt: Decimal.parse((map['total_ht'] ?? 0).toString()),
      totalTva: Decimal.parse((map['total_tva'] ?? 0).toString()),
      totalTtc: Decimal.parse((map['total_ttc'] ?? 0).toString()),
      remiseTaux: Decimal.parse((map['remise_taux'] ?? 0).toString()),
      acompteDejaRegle:
          Decimal.parse((map['acompte_deja_regle'] ?? 0).toString()),
      conditionsReglement: map['conditions_reglement'] ?? '',
      notesPubliques: map['notes_publiques'],
      tvaIntra: map['tva_intra'],
      lignes: (map['lignes_factures'] as List<dynamic>?)
              ?.map((e) => LigneFacture.fromMap(e))
              .toList() ??
          [],
      paiements: (map['paiements'] as List<dynamic>?)
              ?.map((e) => Paiement.fromMap(e))
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
      'numero_facture': numeroFacture,
      'objet': objet,
      'client_id': clientId,
      'devis_source_id': devisSourceId,
      'facture_source_id': factureSourceId,
      'parent_document_id': parentDocumentId,
      'type_document': typeDocument,
      'date_emission': dateEmission.toIso8601String(),
      'date_echeance': dateEcheance.toIso8601String(),
      'date_validation': dateValidation?.toIso8601String(),
      'statut': statut,
      'statut_juridique': statutJuridique,
      'est_archive': estArchive,
      'type': type,
      'avancement_global': avancementGlobal?.toString(),
      'signature_url': signatureUrl,
      'date_signature': dateSignature?.toIso8601String(),
      'total_ht': totalHt.toString(),
      'total_tva': totalTva.toString(),
      'total_ttc': totalTtc.toString(),
      'remise_taux': remiseTaux.toString(),
      'acompte_deja_regle': acompteDejaRegle.toString(),
      'conditions_reglement': conditionsReglement,
      'notes_publiques': notesPubliques,
      'tva_intra': tvaIntra,
      'lignes_factures': lignes.map((e) => e.toMap()).toList(),
      'paiements': paiements.map((e) => e.toMap()).toList(),
      'lignes_chiffrages': chiffrage.map((e) => e.toMap()).toList(),
    };
  }

  Facture copyWith({
    String? id,
    String? userId,
    String? numeroFacture,
    String? objet,
    String? clientId,
    String? devisSourceId,
    String? factureSourceId,
    String? parentDocumentId,
    String? typeDocument,
    DateTime? dateEmission,
    DateTime? dateEcheance,
    DateTime? dateValidation,
    String? statut,
    String? statutJuridique,
    bool? estArchive,
    String? type,
    Decimal? avancementGlobal,
    String? signatureUrl,
    DateTime? dateSignature,
    Decimal? totalHt,
    Decimal? totalTva,
    Decimal? totalTtc,
    Decimal? remiseTaux,
    Decimal? acompteDejaRegle,
    String? conditionsReglement,
    String? notesPubliques,
    String? tvaIntra,
    List<LigneFacture>? lignes,
    List<Paiement>? paiements,
    List<LigneChiffrage>? chiffrage,
  }) {
    return Facture(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      objet: objet ?? this.objet,
      clientId: clientId ?? this.clientId,
      devisSourceId: devisSourceId ?? this.devisSourceId,
      factureSourceId: factureSourceId ?? this.factureSourceId,
      parentDocumentId: parentDocumentId ?? this.parentDocumentId,
      typeDocument: typeDocument ?? this.typeDocument,
      dateEmission: dateEmission ?? this.dateEmission,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      dateValidation: dateValidation ?? this.dateValidation,
      statut: statut ?? this.statut,
      statutJuridique: statutJuridique ?? this.statutJuridique,
      estArchive: estArchive ?? this.estArchive,
      type: type ?? this.type,
      avancementGlobal: avancementGlobal ?? this.avancementGlobal,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      dateSignature: dateSignature ?? this.dateSignature,
      totalHt: totalHt ?? this.totalHt,
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      remiseTaux: remiseTaux ?? this.remiseTaux,
      acompteDejaRegle: acompteDejaRegle ?? this.acompteDejaRegle,
      conditionsReglement: conditionsReglement ?? this.conditionsReglement,
      notesPubliques: notesPubliques ?? this.notesPubliques,
      tvaIntra: tvaIntra ?? this.tvaIntra,
      lignes: lignes ?? this.lignes,
      paiements: paiements ?? this.paiements,
      chiffrage: chiffrage ?? this.chiffrage,
    );
  }
}
