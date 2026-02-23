import 'dart:developer' as developer;
import 'package:decimal/decimal.dart';
import 'dart:typed_data';
import '../models/devis_model.dart';
import '../models/facture_model.dart';
import '../repositories/devis_repository.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../core/base_viewmodel.dart';
import '../core/pdf_generation_mixin.dart';
import '../core/autosave_mixin.dart';
import '../services/gemini_service.dart';

class DevisViewModel extends BaseViewModel
    with PdfGenerationMixin, AutoSaveMixin {
  final IDevisRepository _repository;

  DevisViewModel({IDevisRepository? repository})
      : _repository = repository ?? DevisRepository();

  List<Devis> _devis = [];
  List<Devis> _archives = [];

  List<Devis> get devis => _devis;
  List<Devis> get archives => _archives;

  // Stockage temporaire du draft facture pour la transformation
  Facture? _pendingDraftFacture;
  Facture? get pendingDraftFacture => _pendingDraftFacture;

  /// Méthode pour définir le draft facture pending
  void setPendingDraftFacture(Facture? draft) {
    _pendingDraftFacture = draft;
  }

  /// Clear le draft facture après récupération
  void clearPendingDraftFacture() {
    _pendingDraftFacture = null;
  }

  // --- AUTO-SAVE & PDF WRAPPERS ---

  /// Wrapper pour check local draft avec le bon type
  Future<Map<String, dynamic>?> checkDevisDraft(String? id) async {
    return await checkLocalDraft('devis', id);
  }

  /// Wrapper pour auto-save avec le bon type
  void saveDevisDraft(String? id, Map<String, dynamic> data) {
    autoSaveDraft('devis', id, data);
  }

  /// Wrapper pour clear draft avec le bon type
  Future<void> clearDevisDraft(String? id) async {
    await clearLocalDraft('devis', id);
  }

  /// Wrapper pour trigger PDF avec le bon type
  void triggerDevisPdfUpdate(
    Devis devis,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
  }) {
    triggerPdfUpdate(
      devis,
      client,
      profil,
      isTvaApplicable: isTvaApplicable,
      documentType: 'devis',
      docTypeLabel: 'DEVIS',
    );
  }

  /// Wrapper pour force refresh PDF avec le bon type
  void forceRefreshDevisPdf(
    Devis devis,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
  }) {
    forceRefreshPdf(
      devis,
      client,
      profil,
      isTvaApplicable: isTvaApplicable,
      documentType: 'devis',
      docTypeLabel: 'DEVIS',
    );
  }

  // --- CRUD OPERATIONS ---

  Future<void> fetchDevis() async {
    await execute(() async {
      _devis = await _repository.getDevis(archives: false);
    });
  }

  Future<void> fetchArchives() async {
    await execute(() async {
      _archives = await _repository.getDevis(archives: true);
    });
  }

  Future<bool> addDevis(Devis devis) async {
    return await executeOperation(() async {
      await _repository.createDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> updateDevis(Devis devis) async {
    return await executeOperation(() async {
      await _repository.updateDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> finaliserDevis(Devis devis) async {
    if (devis.id == null) return false;
    return await executeOperation(() async {
      await _repository.finalizeDevis(devis.id!);
      await fetchDevis();
    });
  }

  Future<void> deleteDevis(String id) async {
    await executeOperation(() async {
      // 🛡️ PROTECTION : Vérifier que c'est un brouillon avant suppression
      final devis = _devis.firstWhere(
        (d) => d.id == id,
        orElse: () => throw Exception("Devis introuvable"),
      );

      if (devis.statut != 'brouillon') {
        throw Exception("Impossible de supprimer un devis ${devis.statut}. "
            "Seuls les devis brouillon peuvent être supprimés.");
      }

      developer.log("🗑️ Suppression devis brouillon: ${devis.numeroDevis}");

      await _repository.deleteDevis(id);
      await fetchDevis();
    });
  }

  Future<void> toggleArchive(Devis devis, bool archiver) async {
    if (devis.id == null) return;
    await executeOperation(() async {
      await _repository.toggleArchive(devis.id!, archiver);
      await fetchDevis();
      await fetchArchives();
    });
  }

  Future<bool> markAsSent(String id) async {
    return await executeOperation(() async {
      await _repository.finalizeDevis(id);
      await fetchDevis();
    });
  }

  Future<bool> uploadSignature(String devisId, Uint8List bytes) async {
    if (devisId.isEmpty) return false;
    return await executeOperation(() async {
      final url = await _repository.uploadSignature(devisId, bytes);
      await _repository.markAsSigned(devisId, url);
      await fetchDevis();
    });
  }

  // --- MODULE 3 : IA & AITISE TON DEVIS ---

  Future<List<LigneDevis>?> generateAILignes(
      String prompt, String catalogJSON) async {
    try {
      final data =
          await GeminiService.generateQuoteStructure(prompt, catalogJSON);
      if (data == null) return null;

      final List<LigneDevis> newLignes = [];
      for (var l in data) {
        newLignes.add(LigneDevis(
          description: l['designation'] ?? l['description'] ?? 'Ligne',
          quantite:
              Decimal.tryParse(l['quantite']?.toString() ?? '1') ?? Decimal.one,
          prixUnitaire:
              Decimal.tryParse(l['prix_unitaire']?.toString() ?? '0') ??
                  Decimal.zero,
          totalLigne: Decimal.tryParse(l['total_ligne']?.toString() ?? '0') ??
              Decimal.zero,
          typeActivite: l['type_activite'] ?? 'service',
          unite: l['unite'] ?? 'u',
          type: l['type_ligne'] ?? l['type'] ?? 'article',
          isAiEstimated: l['is_ai_estimated'] == true,
        ));
      }
      return newLignes;
    } catch (e) {
      developer.log("Erreur generateAILignes", error: e);
      return null;
    }
  }

  // --- MODULE 2 : Transformation Facture ---

  /// Génère un brouillon de facture en fonction du type demandé
  /// [type] : 'standard', 'acompte', 'situation', 'solde'
  /// [value] : Pourcentage ou Montant (pour acompte)
  /// [isPercent] : Si la valeur est un pourcentage
  /// [dejaRegle] : Montant total déjà réglé sur ce devis (acomptes, situations...)
  /// [avancementsChiffrage] : Map ligneDevisId → avancement% (depuis RentabiliteViewModel)
  ///   Utilisé en mode Global pour pré-remplir l'avancement des lignes de situation
  Facture prepareFacture(Devis d, String type, Decimal value, bool isPercent,
      {Decimal? dejaRegle, Map<String, Decimal>? avancementsChiffrage}) {
    if (d.id == null) {
      throw Exception("Le devis n'a pas d'ID");
    }

    final base = Facture(
      userId: d.userId,
      objet: d.objet,
      clientId: d.clientId,
      devisSourceId: d.id,
      dateEmission: DateTime.now(),
      dateEcheance: DateTime.now(), // À ajuster selon settings
      statut: 'brouillon',
      statutJuridique: 'brouillon',
      conditionsReglement: d.conditionsReglement,
      notesPubliques: d.notesPubliques,
      tvaIntra: d.tvaIntra,
      type: type,
      totalHt: Decimal.zero, // Sera recalculé
      remiseTaux: d.remiseTaux,
      acompteDejaRegle:
          Decimal.zero, // Par défaut 0, sauf si on recupère l'historique
    );

    if (type == 'standard') {
      // Copie conforme
      final newLignes = d.lignes.map((l) {
        return LigneFacture(
            description: l.description,
            quantite: l.quantite,
            prixUnitaire: l.prixUnitaire,
            totalLigne: l.totalLigne,
            unite: l.unite,
            type: l.type,
            estGras: l.estGras,
            estItalique: l.estItalique,
            estSouligne: l.estSouligne,
            avancement: Decimal.fromInt(100));
      }).toList();
      // Si standard, on peut potentiellement reprendre l'acompte du devis ou l'historique
      return base.copyWith(
        lignes: newLignes,
        totalHt: d.totalHt,
        acompteDejaRegle: dejaRegle ?? d.acompteMontant,
      );
    }

    if (type == 'acompte') {
      // Ligne unique
      Decimal montantAcompte = Decimal.zero;
      String desc = "";

      if (isPercent) {
        // Division returns Rational, must convert to Decimal
        montantAcompte =
            ((d.totalHt * value) / Decimal.fromInt(100)).toDecimal();
        desc = "Acompte de $value% sur devis ${d.numeroDevis}";
      } else {
        montantAcompte = value;
        desc = "Acompte sur devis ${d.numeroDevis}";
      }

      // No need for separate conversion line if done above

      final ligne = LigneFacture(
        description: desc,
        quantite: Decimal.one,
        prixUnitaire: montantAcompte,
        totalLigne: montantAcompte,
        type: 'article',
        avancement: Decimal.fromInt(100),
      );

      return base.copyWith(
          lignes: [ligne],
          totalHt: montantAcompte,
          remiseTaux: Decimal.zero, // Pas de remise sur un acompte net
          objet: "Acompte - ${d.objet}");
    }

    if (type == 'situation') {
      // FACTURE DE SITUATION (AVANCEMENT) — Règles légales :
      // 1. Les prix unitaires restent ceux du marché (devis original)
      // 2. L'avancement se définit PAR LIGNE (pas globalement)
      // 3. Total = somme des (qté × PU × avancement%) par ligne
      // 4. Le montant déjà réglé (acomptes + situations précédentes) est déduit
      //
      // SMART PROGRESS BILLING (mode Global) :
      // Si avancementsChiffrage est fourni (depuis RentabiliteViewModel),
      // chaque ligne est pré-remplie avec l'avancement calculé depuis le suivi
      // des matériaux et de la main d'œuvre. L'utilisateur peut toujours ajuster.

      // Montant à déduire = max(acompte théorique du devis, paiements réels)
      final montantADeduire =
          (dejaRegle != null && dejaRegle > d.acompteMontant)
              ? dejaRegle
              : d.acompteMontant;

      final newLignes = d.lignes.map((l) {
        // Auto-fill depuis chiffrage si disponible, sinon 0%
        Decimal avancementLigne = Decimal.zero;
        if (avancementsChiffrage != null && l.id != null) {
          avancementLigne = avancementsChiffrage[l.id] ?? Decimal.zero;
        }

        // Calcul du total ligne basé sur l'avancement
        final totalAvancement = avancementLigne > Decimal.zero
            ? ((l.quantite * l.prixUnitaire * avancementLigne) /
                    Decimal.fromInt(100))
                .toDecimal()
            : Decimal.zero;

        return LigneFacture(
            description: l.description,
            quantite: l.quantite,
            prixUnitaire: l.prixUnitaire, // Prix du marché conservé
            totalLigne: totalAvancement,
            unite: l.unite,
            typeActivite:
                l.typeActivite, // Conserver service/vente pour distinguer
            type: l.type,
            estGras: l.estGras,
            estItalique: l.estItalique,
            estSouligne: l.estSouligne,
            tauxTva: l.tauxTva,
            avancement: avancementLigne);
      }).toList();

      // Calculer le total HT brut (somme des totalLigne pré-remplis)
      final totalHtBrut =
          newLignes.fold(Decimal.zero, (Decimal s, l) => s + l.totalLigne);

      return base.copyWith(
        lignes: newLignes,
        totalHt: totalHtBrut,
        objet: "Situation - ${d.objet}",
        acompteDejaRegle: montantADeduire,
      );
    }

    if (type == 'solde') {
      // Copie à 100%
      final newLignes = d.lignes.map((l) {
        return LigneFacture(
            description: l.description,
            quantite: l.quantite,
            prixUnitaire: l.prixUnitaire,
            totalLigne: l.totalLigne,
            unite: l.unite,
            type: l.type,
            estGras: l.estGras,
            estItalique: l.estItalique,
            estSouligne: l.estSouligne,
            avancement: Decimal.fromInt(100));
      }).toList();

      // ICI: On déduit tout ce qui a déjà été réglé (Acomptes, Situations...)
      // Le champ 'acompteDejaRegle' de la facture servira à soustraire du TotalTTC
      return base.copyWith(
        lignes: newLignes,
        totalHt: d.totalHt,
        objet: "Solde - ${d.objet}",
        acompteDejaRegle:
            dejaRegle ?? d.acompteMontant, // TOTAL déjà payé à déduire
      );
    }

    return base;
  }

  // --- DASHBOARD & KPI ---

  /// Taux de conversion (Devis Signés / Total Devis non annulés)
  Future<Decimal> getConversionRate() async {
    if (_devis.isEmpty) await fetchDevis();

    if (_devis.isEmpty) return Decimal.zero;

    int total = 0;
    int signed = 0;

    for (var d in _devis) {
      if (d.statut != 'annule') {
        total++;
        if (d.statut == 'signe') {
          signed++;
        }
      }
    }

    if (total == 0) return Decimal.zero;

    final ratio = (Decimal.fromInt(signed) / Decimal.fromInt(total))
        .toDecimal(scaleOnInfinitePrecision: 10);
    final percentage = ratio * Decimal.fromInt(100);
    return percentage;
  }

  /// Retourne les derniers devis modifiés/créés
  List<Devis> getRecentActivity(int limit) {
    final sorted = List<Devis>.from(_devis);
    sorted.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return sorted.take(limit).toList();
  }

  /// Duplique un devis existant en brouillon
  Devis duplicateDevis(Devis source) {
    // Construction directe pour garantir id = null (copyWith ne peut pas nullifier)
    return Devis(
      // id omis = null
      userId: source.userId,
      numeroDevis: '',
      objet: source.objet,
      clientId: source.clientId,
      dateEmission: DateTime.now(),
      dateValidite: DateTime.now().add(const Duration(days: 30)),
      statut: 'brouillon',
      estTransforme: false,
      estArchive: false,
      totalHt: source.totalHt,
      totalTva: source.totalTva,
      totalTtc: source.totalTtc,
      remiseTaux: source.remiseTaux,
      acompteMontant: source.acompteMontant,
      conditionsReglement: source.conditionsReglement,
      notesPubliques: source.notesPubliques,
      tvaIntra: source.tvaIntra,
      lignes: source.lignes
          .map((l) => LigneDevis(
                description: l.description,
                quantite: l.quantite,
                prixUnitaire: l.prixUnitaire,
                totalLigne: l.totalLigne,
                typeActivite: l.typeActivite,
                unite: l.unite,
                type: l.type,
                ordre: l.ordre,
                tauxTva: l.tauxTva,
              ))
          .toList(),
      chiffrage: source.chiffrage.map((c) => c.copyWith()).toList(),
    );
  }

  /// Annule un devis (statut -> annule)
  Future<bool> annulerDevis(String id) async {
    return await executeOperation(() async {
      final d = _devis.firstWhere((element) => element.id == id);
      if (d.statut == 'signe') {
        throw Exception("Impossible d'annuler un devis deja signe");
      }
      if (d.statut == 'annule') {
        throw Exception("Ce devis est deja annule");
      }
      await _repository.changeStatut(id, 'annule');
      await fetchDevis();
    });
  }

  /// Refuse un devis (statut envoye -> refuse)
  Future<bool> refuserDevis(String id) async {
    return await executeOperation(() async {
      final d = _devis.firstWhere((element) => element.id == id);
      if (d.statut != 'envoye') {
        throw Exception("Seul un devis envoye peut etre refuse");
      }
      await _repository.changeStatut(id, 'refuse');
      await fetchDevis();
    });
  }

  /// Cree un avenant a partir d'un devis signe
  Future<Devis?> creerAvenant(String devisId) async {
    Devis? avenant;
    await executeOperation(() async {
      avenant = await _repository.createAvenant(devisId);
      await fetchDevis();
    });
    return avenant;
  }

  /// Expire les devis dont la date de validite est depassee
  Future<void> checkExpiredDevis() async {
    await executeOperation(() async {
      await _repository.expireDevisDepasses();
      await fetchDevis();
    });
  }

  @override
  void dispose() {
    disposePdf();
    disposeAutoSave();
    super.dispose();
  }
}
