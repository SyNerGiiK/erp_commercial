import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../repositories/facture_repository.dart';
import '../core/base_viewmodel.dart';
import '../core/pdf_generation_mixin.dart';
import '../core/autosave_mixin.dart';

class FactureViewModel extends BaseViewModel
    with PdfGenerationMixin, AutoSaveMixin {
  final IFactureRepository _repository;

  FactureViewModel({IFactureRepository? repository})
      : _repository = repository ?? FactureRepository();

  // --- WRAPPERS POUR MIXINS ---
  Future<Map<String, dynamic>?> checkFactureDraft(String? id) =>
      checkLocalDraft('facture', id);

  void saveFactureDraft(String? id, Map<String, dynamic> data) =>
      autoSaveDraft('facture', id, data);

  Future<void> clearFactureDraft(String? id) => clearLocalDraft('facture', id);

  void triggerFacturePdfUpdate(
      Facture facture, Client? client, ProfilEntreprise? profil,
      {required bool isTvaApplicable}) {
    final docTypeLabel = (facture.type == 'avoir') ? 'AVOIR' : 'FACTURE';
    triggerPdfUpdate(
      facture,
      client,
      profil,
      documentType: 'facture',
      docTypeLabel: docTypeLabel,
      isTvaApplicable: isTvaApplicable,
    );
  }

  void forceRefreshFacturePdf(
      Facture facture, Client? client, ProfilEntreprise? profil,
      {required bool isTvaApplicable}) {
    final docTypeLabel = (facture.type == 'avoir') ? 'AVOIR' : 'FACTURE';
    forceRefreshPdf(
      facture,
      client,
      profil,
      documentType: 'facture',
      docTypeLabel: docTypeLabel,
      isTvaApplicable: isTvaApplicable,
    );
  }

  List<Facture> _factures = [];
  List<Facture> _archives = [];

  List<Facture> get factures => _factures;
  List<Facture> get archives => _archives;

  Future<void> fetchFactures() async {
    await execute(() async {
      _factures = await _repository.getFactures(archives: false);
    });
  }

  Future<void> fetchArchives() async {
    await execute(() async {
      _archives = await _repository.getFactures(archives: true);
    });
  }

  // --- CRUD BASE ---

  Future<bool> addFacture(Facture facture) async {
    return await executeOperation(() async {
      await _repository.createFacture(facture);
      await fetchFactures();
    });
  }

  Future<bool> updateFacture(Facture facture) async {
    return await executeOperation(() async {
      // 🛡️ PROTECTION : Bloquer la modification des factures validées
      if (facture.statutJuridique != 'brouillon') {
        throw Exception(
            "Impossible de modifier une facture validée (statut: ${facture.statutJuridique}). "
            "Seuls les brouillons sont modifiables. Créez un avoir pour corriger.");
      }
      await _repository.updateFacture(facture);
      await fetchFactures();
    });
  }

  Future<void> deleteFacture(String id) async {
    await executeOperation(() async {
      // 🛡️ PROTECTION : Vérifier que c'est un brouillon avant suppression
      final facture = _factures.firstWhere(
        (f) => f.id == id,
        orElse: () => throw Exception("Facture introuvable"),
      );

      if (facture.statutJuridique != 'brouillon') {
        throw Exception(
            "Impossible de supprimer une facture validée (statut: ${facture.statutJuridique}). "
            "Seules les factures brouillon peuvent être supprimées.");
      }

      developer
          .log("🗑️ Suppression facture brouillon: ${facture.numeroFacture}");

      await _repository.deleteFacture(id);
      await fetchFactures();
    });
  }

  Future<void> toggleArchive(Facture facture, bool archiver) async {
    if (facture.id == null) return;
    await executeOperation(() async {
      await _repository.updateArchiveStatus(facture.id!, archiver);
      await fetchFactures();
      await fetchArchives();
    });
  }

  Future<bool> finaliserFacture(Facture facture) async {
    if (facture.id == null) return false;
    return await executeOperation(() async {
      // La numérotation est gérée par le trigger SQL (get_next_document_number_strict)
      // On met simplement le statut à 'validee' avec un numéro vide.
      // Le trigger détectera le changement de statut_juridique → 'validee'
      // et assignera automatiquement un numéro séquentiel atomique.
      await _repository.finaliserFacture(facture.id!);
      await fetchFactures();
    });
  }

  // --- LOGIQUE MÉTIER ---

  /// Calcule le total déjà réglé sur les factures liées au même devis (acomptes)
  Future<Decimal> calculateHistoriqueReglements(
      String devisSourceId, String excludeFactureId) async {
    try {
      final linkedFactures = await _repository.getLinkedFactures(
        devisSourceId,
        excludeFactureId: excludeFactureId.isNotEmpty ? excludeFactureId : null,
      );

      Decimal total = Decimal.zero;
      for (var f in linkedFactures) {
        for (var p in f.paiements) {
          total += p.montant;
        }
      }
      return total;
    } catch (e) {
      developer.log("Erreur calcul historique règlements", error: e);
      return Decimal.zero;
    }
  }

  /// Retourne les factures en retard de paiement
  List<Facture> get facturesEnRetard {
    final now = DateTime.now();
    return _factures.where((f) {
      if (f.statut == 'brouillon' ||
          f.statut == 'payee' ||
          f.statut == 'annulee') {
        return false;
      }
      return f.dateEcheance.isBefore(now);
    }).toList();
  }

  /// Retourne le nombre de jours de retard moyen
  double get retardMoyen {
    final retards = facturesEnRetard;
    if (retards.isEmpty) return 0;
    final now = DateTime.now();
    final totalJours = retards.fold<int>(
      0,
      (sum, f) => sum + now.difference(f.dateEcheance).inDays,
    );
    return totalJours / retards.length;
  }

  /// Duplique une facture existante en brouillon
  Facture duplicateFacture(Facture source) {
    // Construction directe pour garantir id = null (copyWith ne peut pas nullifier)
    return Facture(
      // id omis = null
      userId: source.userId,
      numeroFacture: '',
      objet: source.objet,
      clientId: source.clientId,
      devisSourceId: source.devisSourceId,
      dateEmission: DateTime.now(),
      dateEcheance: DateTime.now().add(const Duration(days: 30)),
      statut: 'brouillon',
      statutJuridique: 'brouillon',
      estArchive: false,
      type: source.type,
      totalHt: source.totalHt,
      totalTva: source.totalTva,
      totalTtc: source.totalTtc,
      remiseTaux: source.remiseTaux,
      acompteDejaRegle: Decimal.zero,
      conditionsReglement: source.conditionsReglement,
      notesPubliques: source.notesPubliques,
      tvaIntra: source.tvaIntra,
      lignes: source.lignes
          .map((l) => LigneFacture(
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

  /// Crée un avoir (credit note) à partir d'une facture validée.
  /// Les montants restent positifs (le type 'avoir' signale la nature).
  /// La référence à la facture source est conservée via factureSourceId.
  Facture createAvoir(Facture source, {String? motif}) {
    if (source.id == null) throw Exception("La facture source n'a pas d'ID");
    if (source.statutJuridique == 'brouillon') {
      throw Exception("Impossible de créer un avoir sur une facture brouillon");
    }

    // Les lignes sont copiées sans ID (nouvelles lignes pour l'avoir)
    final lignesAvoir = source.lignes.map((l) {
      return LigneFacture(
        // id omis = null
        description: l.description,
        quantite: l.quantite,
        prixUnitaire: l.prixUnitaire,
        totalLigne: l.totalLigne,
        typeActivite: l.typeActivite,
        unite: l.unite,
        type: l.type,
        ordre: l.ordre,
        tauxTva: l.tauxTva,
      );
    }).toList();

    return Facture(
      userId: source.userId,
      numeroFacture: '',
      objet: "Avoir sur ${source.numeroFacture} - ${source.objet}",
      clientId: source.clientId,
      factureSourceId: source.id,
      parentDocumentId: source.id,
      typeDocument: 'avoir',
      dateEmission: DateTime.now(),
      dateEcheance: DateTime.now().add(const Duration(days: 30)),
      statut: 'brouillon',
      statutJuridique: 'brouillon',
      type: 'avoir',
      totalHt: source.totalHt,
      totalTva: source.totalTva,
      totalTtc: source.totalTtc,
      remiseTaux: source.remiseTaux,
      acompteDejaRegle: Decimal.zero,
      conditionsReglement: source.conditionsReglement,
      notesPubliques: "Avoir sur facture ${source.numeroFacture}",
      tvaIntra: source.tvaIntra,
      lignes: lignesAvoir,
      motifAvoir: motif ?? '',
    );
  }

  // --- PAIEMENTS ---

  Future<bool> addPaiement(Paiement paiement) async {
    return await executeOperation(() async {
      // 🛡️ PROTECTION : Vérifier que le paiement ne dépasse pas le reste à payer
      await fetchFactures();
      final facture = _factures.firstWhere(
        (f) => f.id == paiement.factureId,
        orElse: () => throw Exception("Facture introuvable"),
      );

      // Reste à payer via le modèle (totalTtc - acomptes - paiements)
      final resteAPayer = facture.netAPayer;

      // Tolérance d'1 centime pour arrondi
      if (paiement.montant > resteAPayer + Decimal.parse('0.01')) {
        throw Exception(
            "Le paiement (${paiement.montant.toDouble().toStringAsFixed(2)}€) "
            "dépasse le reste à payer (${resteAPayer.toDouble().toStringAsFixed(2)}€)");
      }

      developer.log(
          "🟢 Ajout paiement: ${paiement.montant}€ sur facture ${facture.numeroFacture}");

      await _repository.addPaiement(paiement);
      await fetchFactures();

      // Auto-update status check
      await _checkUpdateStatusPayee(paiement.factureId);
    });
  }

  Future<bool> deletePaiement(String paiementId, String? factureId) async {
    return await executeOperation(() async {
      await _repository.deletePaiement(paiementId);
      await fetchFactures();

      if (factureId != null) {
        await _checkUpdateStatusPayee(factureId);
      }
    });
  }

  /// Vérifie si la facture est entièrement payée et met à jour le statut
  Future<void> _checkUpdateStatusPayee(String factureId) async {
    try {
      // On cherche la facture dans la liste à jour
      final facture = _factures.firstWhere((f) => f.id == factureId);

      // Si elle est brouillon ou annulée, on ne touche pas
      if (facture.statut == 'brouillon' || facture.statut == 'annulee') return;

      // Utilise le getter du modèle : totalTtc - acomptes - paiements
      final reste = facture.netAPayer;

      // Tolérance pour les erreurs d'arrondi décimales infimes
      final isPaid = reste <= Decimal.parse('0.01');

      if (isPaid && facture.statut != 'payee') {
        await _repository.updateStatus(facture.id!, 'payee');
        await fetchFactures();
      } else if (!isPaid && facture.statut == 'payee') {
        await _repository.updateStatus(facture.id!, 'validee');
        await fetchFactures();
      }
    } catch (e) {
      developer.log("Error updating status payee", error: e);
    }
  }

  // --- SIGNATURE ---

  Future<bool> uploadSignature(String factureId, Uint8List bytes) async {
    return await executeOperation(() async {
      final url = await _repository.uploadSignature(factureId, bytes);

      // On met à jour la facture locale et distante
      final facture = _factures.firstWhere((f) => f.id == factureId,
          orElse: () => Facture(
              id: factureId,
              numeroFacture: '',
              objet: '',
              clientId: '',
              dateEmission: DateTime.now(),
              dateEcheance: DateTime.now(),
              totalHt: Decimal.zero,
              remiseTaux: Decimal.zero,
              acompteDejaRegle: Decimal.zero));

      if (facture.numeroFacture.isNotEmpty) {
        final updated = facture.copyWith(
          signatureUrl: url,
          dateSignature: DateTime.now(),
          statut: 'signee', // Changement de statut explicite
        );
        await _repository.updateFacture(updated);
        await fetchFactures();
      }
    });
  }

  Future<bool> markAsSent(String id) async {
    return await executeOperation(() async {
      final f = _factures.firstWhere((element) => element.id == id);
      final updated = f.copyWith(statut: 'envoye');
      await _repository.updateFacture(updated);
      await fetchFactures();
    });
  }

  // --- DASHBOARD & KPI ---

  /// Retourne le CA (HT) par mois pour l'année donnée.
  /// Index 0 = Janvier, 11 = Décembre.
  Future<List<Decimal>> getChiffreAffaires(int year) async {
    // On s'assure d'avoir les données
    if (_factures.isEmpty) await fetchFactures();

    final monthlyCA = List<Decimal>.filled(12, Decimal.zero);

    for (var f in _factures) {
      if (f.statut == 'validee' || f.statut == 'payee') {
        if (f.dateEmission.year == year) {
          final monthIndex = f.dateEmission.month - 1; // 0..11
          // On prend le HT total
          monthlyCA[monthIndex] += f.totalHt;
        }
      }
    }
    return monthlyCA;
  }

  /// Retourne le montant total des factures validées mais NON payées (reste à payer).
  Future<Decimal> getImpayes() async {
    if (_factures.isEmpty) await fetchFactures();

    Decimal totalImpaye = Decimal.zero;

    for (var f in _factures) {
      if (f.statut == 'validee') {
        // Utilise le getter du modèle : totalTtc - acompteDejaRegle - totalPaiements
        final reste = f.netAPayer;

        if (reste > Decimal.zero) {
          totalImpaye += reste;
        }
      }
    }
    return totalImpaye;
  }

  /// Retourne les dernières factures modifiées/créées
  List<Facture> getRecentActivity(int limit) {
    final sorted = List<Facture>.from(_factures);
    sorted.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return sorted.take(limit).toList();
  }
}
