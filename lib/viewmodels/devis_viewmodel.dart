import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'dart:typed_data';
import '../models/devis_model.dart';
import '../models/facture_model.dart';
import '../repositories/devis_repository.dart';
import '../models/client_model.dart'; // Added
import '../models/entreprise_model.dart'; // Added
import '../services/pdf_service.dart'; // Added
import 'dart:async'; // Added
import '../config/supabase_config.dart'; // Added
import '../services/local_storage_service.dart'; // Auto-Save

class DevisViewModel extends ChangeNotifier {
  final IDevisRepository _repository = DevisRepository();

  // --- PDF GENERATION STATE ---
  bool _isRealTimePreviewEnabled = false;
  bool get isRealTimePreviewEnabled => _isRealTimePreviewEnabled;

  bool _isGeneratingPdf = false;
  bool get isGeneratingPdf => _isGeneratingPdf;

  Uint8List? _currentPdfData;
  Uint8List? get currentPdfData => _currentPdfData;

  // Keep track of the last processed draft to avoid loops if needed (optional)
  // For now simple debounce.
  Timer? _pdfDebounce;

  // --- AUTO-SAVE STATE ---
  Timer? _saveDebounce;
  bool _isRestoringDraft = false;
  bool get isRestoringDraft => _isRestoringDraft;

  void toggleRealTimePreview(bool value) {
    _isRealTimePreviewEnabled = value;
    notifyListeners();
  }

  void clearPdfState() {
    _currentPdfData = null;
    _isGeneratingPdf = false;
    // We don't reset _isRealTimePreviewEnabled to keep user preference?
    // Or reset it? User didn't specify. Let's keep it persistence-ish in session, so don't reset.
    // Actually, safest to reset to false to avoid unwanted load on entry?
    // Let's reset to false to be safe and clean.
    _isRealTimePreviewEnabled = false;
    _isRealTimePreviewEnabled = false;
    _pdfDebounce?.cancel();
    _saveDebounce?.cancel();
  }

  // --- AUTO-SAVE LOGIC ---

  /// Tente de charger un brouillon local
  Future<Map<String, dynamic>?> checkLocalDraft(String? id) async {
    _isRestoringDraft = true;
    Future.microtask(() => notifyListeners());

    final key = LocalStorageService.generateKey('devis', id);
    final data = await LocalStorageService.getDraft(key);

    _isRestoringDraft = false;
    notifyListeners();
    return data;
  }

  /// Sauvegarde locale déclenchée par l'UI (Debounce 2s)
  void autoSaveDraft(String? id, Map<String, dynamic> data) {
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();

    _saveDebounce = Timer(const Duration(seconds: 2), () async {
      final key = LocalStorageService.generateKey('devis', id);
      await LocalStorageService.saveDraft(key, data);
      developer.log("Auto-saved draft: $key");
    });
  }

  /// Nettoyage explicite (après validation)
  Future<void> clearLocalDraft(String? id) async {
    _saveDebounce?.cancel();
    final key = LocalStorageService.generateKey('devis', id);
    await LocalStorageService.clearDraft(key);
  }

  void triggerPdfUpdate(
      dynamic document, Client? client, ProfilEntreprise? profil,
      {required bool isTvaApplicable}) {
    if (!_isRealTimePreviewEnabled) return;
    if (_pdfDebounce?.isActive ?? false) _pdfDebounce!.cancel();

    _pdfDebounce = Timer(const Duration(milliseconds: 1000), () {
      _generatePdf(document, client, profil, isTvaApplicable: isTvaApplicable);
    });
  }

  void forceRefreshPdf(
      dynamic document, Client? client, ProfilEntreprise? profil,
      {required bool isTvaApplicable}) {
    if (_pdfDebounce?.isActive ?? false) _pdfDebounce!.cancel();
    _generatePdf(document, client, profil, isTvaApplicable: isTvaApplicable);
  }

  Future<void> _generatePdf(
      dynamic document, Client? client, ProfilEntreprise? profil,
      {required bool isTvaApplicable}) async {
    if (_isGeneratingPdf) return;

    _isGeneratingPdf = true;
    notifyListeners();

    try {
      // Create request object with Maps to be isolate-safe
      final request = PdfGenerationRequest(
        document: (document as Devis).toMap(),
        documentType: 'devis',
        client: client?.toMap(),
        profil: profil?.toMap(),
        docTypeLabel: "DEVIS",
        isTvaApplicable: isTvaApplicable,
      );

      final result = await compute(PdfService.generatePdfIsolate, request);
      _currentPdfData = result;
    } catch (e) {
      developer.log("Error generating PDF", error: e);
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }

    // Defer actual call to separate method or closure to ensure imports?
    // Actually I need to add the import in the `multi_replace`.
  }

  List<Devis> _devis = [];
  List<Devis> _archives = [];

  List<Devis> get devis => _devis;
  List<Devis> get archives => _archives;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<void> fetchDevis() async {
    await _executeOperation(() async {
      _devis = await _repository.getDevis(archives: false);
    });
  }

  Future<void> fetchArchives() async {
    await _executeOperation(() async {
      _archives = await _repository.getDevis(archives: true);
    });
  }

  Future<bool> addDevis(Devis devis) async {
    return await _executeOperation(() async {
      await _repository.createDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> updateDevis(Devis devis) async {
    return await _executeOperation(() async {
      await _repository.updateDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> finaliserDevis(Devis devis) async {
    if (devis.id == null) return false;
    return await _executeOperation(() async {
      await _repository.finalizeDevis(devis.id!);
      await fetchDevis();
    });
  }

  Future<void> deleteDevis(String id) async {
    await _executeOperation(() async {
      await _repository.deleteDevis(id);
      await fetchDevis();
    });
  }

  Future<void> toggleArchive(Devis devis, bool archiver) async {
    if (devis.id == null) return;
    await _executeOperation(() async {
      await _repository.toggleArchive(devis.id!, archiver);
      await fetchDevis();
      await fetchArchives();
    });
  }

  Future<bool> markAsSent(String id) async {
    return await _executeOperation(() async {
      final d = _devis.firstWhere((element) => element.id == id);
      final updated = d.copyWith(statut: 'envoye');
      await _repository.updateDevis(updated);
      await fetchDevis();
    });
  }

  Future<bool> uploadSignature(String devisId, Uint8List bytes) async {
    if (devisId.isEmpty) return false;
    return await _executeOperation(() async {
      final url = await _repository.uploadSignature(devisId, bytes);

      final devis = _devis.firstWhere((d) => d.id == devisId);
      final updated = devis.copyWith(
        signatureUrl: url,
        dateSignature: DateTime.now(),
        statut: 'signe',
      );

      await _repository.updateDevis(updated);
      await fetchDevis();
    });
  }

  // --- MODULE 2 : Transformation Facture ---

  /// Génère un brouillon de facture en fonction du type demandé
  /// [type] : 'standard', 'acompte', 'situation', 'solde'
  /// [value] : Pourcentage ou Montant (pour acompte)
  /// [isPercent] : Si la valeur est un pourcentage
  /// [dejaRegle] : Montant total déjà réglé sur ce devis (acomptes, situations...)
  Facture prepareFacture(Devis d, String type, Decimal value, bool isPercent,
      {Decimal? dejaRegle}) {
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
      // NOUVELLE LOGIQUE: Le calcul se fait sur (Devis - Acompte)
      // Exemple: Devis 10k€, Acompte 3k€ → Base = 7k€
      // Situation 50% = 50% × 7k€ = 3.5k€

      // Calculer la base de référence
      final montantDeReference = d.totalHt - d.acompteMontant;

      // Ratio de réduction à appliquer sur chaque ligne
      // Si pas d'acompte, ratio = 1.0 (comportement standard)
      final ratioReduction = d.acompteMontant > Decimal.zero
          ? (montantDeReference / d.totalHt).toDecimal()
          : Decimal.one;

      final newLignes = d.lignes.map((l) {
        // Appliquer le ratio sur le prix unitaire
        // Decimal * Decimal = Decimal (pas besoin de toDecimal)
        final prixUnitaireAjuste = l.prixUnitaire * ratioReduction;

        return LigneFacture(
            description: l.description,
            quantite: l.quantite,
            prixUnitaire:
                prixUnitaireAjuste, // Prix réduit en fonction de l'acompte
            totalLigne: Decimal.zero, // Sera calculé par l'avancement dans l'UI
            unite: l.unite,
            type: l.type,
            estGras: l.estGras,
            estItalique: l.estItalique,
            estSouligne: l.estSouligne,
            avancement: value); // Utilise le pourcentage saisi dans le dialog
      }).toList();

      return base.copyWith(
          lignes: newLignes,
          totalHt: Decimal.zero,
          objet: "Situation - ${d.objet}",
          acompteDejaRegle: dejaRegle ??
              Decimal.zero // Situation souvent autonome ou cumulative?
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

    // Fix: Decimal / Decimal -> Rational. Rational * Rational -> Rational.
    final ratio = Decimal.fromInt(signed) / Decimal.fromInt(total); // Rational
    final percentage = ratio * Decimal.fromInt(100).toRational(); // Rational
    return percentage.toDecimal();
  }

  /// Retourne les derniers devis modifiés/créés
  List<Devis> getRecentActivity(int limit) {
    // Tri par date d'émission (ou création si on avait le champ created_at dispo en local)
    // On utilise numeroDevis pour l'instant (plus récent = plus grand) ou dateEmission
    final sorted = List<Devis>.from(_devis);
    sorted.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return sorted.take(limit).toList();
  }

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    if (_isLoading) return false;
    _isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      await operation();
      return true;
    } catch (e) {
      developer.log("🔴 DevisVM Error", error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
