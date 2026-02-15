import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'dart:typed_data';
import '../models/devis_model.dart';
import '../models/facture_model.dart';
import '../repositories/devis_repository.dart';

class DevisViewModel extends ChangeNotifier {
  final IDevisRepository _repository = DevisRepository();

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
      final annee = DateTime.now().year;
      final newNumero = await _repository.generateNextNumero(annee);
      await _repository.finalizeDevis(devis.id!, newNumero);
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
  Facture prepareFacture(Devis d, String type, Decimal value, bool isPercent) {
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
      acompteDejaRegle: Decimal.zero,
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
      return base.copyWith(lignes: newLignes, totalHt: d.totalHt);
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
      // On copie tout avec un avancement à 0 (ou on pourrait reprendre l'existant)
      // Pour l'MVP: 0% pour forcer la saisie
      final newLignes = d.lignes.map((l) {
        return LigneFacture(
            description: l.description,
            quantite: l.quantite,
            prixUnitaire: l.prixUnitaire,
            totalLigne: Decimal.zero, // Sera calculé par l'avancement
            unite: l.unite,
            type: l.type,
            estGras: l.estGras,
            estItalique: l.estItalique,
            estSouligne: l.estSouligne,
            avancement: Decimal.zero);
      }).toList();

      return base.copyWith(
          lignes: newLignes,
          totalHt: Decimal.zero,
          objet: "Situation - ${d.objet}");
    }

    if (type == 'solde') {
      // Copie à 100%
      // La déduction des acomptes se fera via "Acompte déjà réglé" ou ligne négative ?
      // Pour l'instant, faisons une facture complète 100%.
      // L'utilisateur ajoutera manuellement la ligne de déduction ou on gère ça plus tard via "AcompteDéjaRéglé".
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

      return base.copyWith(
          lignes: newLignes, totalHt: d.totalHt, objet: "Solde - ${d.objet}");
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
    _isLoading = true;
    notifyListeners();
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
