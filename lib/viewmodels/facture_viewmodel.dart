import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import '../repositories/facture_repository.dart';
import '../config/supabase_config.dart';

class FactureViewModel extends ChangeNotifier {
  final IFactureRepository _repository = FactureRepository();
  // Accès client uniquement pour des analytics très spécifiques si nécessaire,
  // sinon passer par le repo.
  final _client = SupabaseConfig.client;

  List<Facture> _factures = [];
  List<Facture> _archives = [];

  List<Facture> get factures => _factures;
  List<Facture> get archives => _archives;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFactures() async {
    await _executeOperation(() async {
      _factures = await _repository.getFactures(archives: false);
    });
  }

  Future<void> fetchArchives() async {
    await _executeOperation(() async {
      _archives = await _repository.getFactures(archives: true);
    });
  }

  // --- CRUD BASE ---

  Future<bool> addFacture(Facture facture) async {
    return await _executeOperation(() async {
      await _repository.createFacture(facture);
      await fetchFactures();
    });
  }

  Future<bool> updateFacture(Facture facture) async {
    return await _executeOperation(() async {
      await _repository.updateFacture(facture);
      await fetchFactures();
    });
  }

  Future<void> deleteFacture(String id) async {
    await _executeOperation(() async {
      await _repository.deleteFacture(id);
      await fetchFactures();
    });
  }

  Future<void> toggleArchive(Facture facture, bool archiver) async {
    if (facture.id == null) return;
    await _executeOperation(() async {
      await _repository.updateArchiveStatus(facture.id!, archiver);
      await fetchFactures();
      await fetchArchives();
    });
  }

  Future<bool> finaliserFacture(Facture facture) async {
    if (facture.id == null) return false;
    return await _executeOperation(() async {
      // Update local temporaire pour éviter re-fetch immédiat (Optimistic)
      final updated = facture.copyWith(
        // numeroFacture: Laisse vide, sera généré par le Trigger
        statut: 'validee',
        statutJuridique: 'validee',
        dateValidation: DateTime.now(),
      );

      await _repository.updateFacture(updated);
      await fetchFactures();
    });
  }

  // --- LOGIQUE MÉTIER ---

  /// Calcule le total déjà réglé sur les factures liées au même devis (acomptes)
  Future<Decimal> calculateHistoriqueReglements(
      String devisSourceId, String excludeFactureId) async {
    try {
      final userId = SupabaseConfig.userId;

      var query = _client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .eq('devis_source_id', devisSourceId);

      if (excludeFactureId.isNotEmpty) {
        query = query.neq('id', excludeFactureId);
      }

      final response = await query;

      final linkedFactures =
          (response as List).map((e) => Facture.fromMap(e)).toList();

      developer.log(
          "CALCUL HISTORIQUE: DevisID=$devisSourceId, ExcludeID=$excludeFactureId");
      developer.log(
          "CALCUL HISTORIQUE: ${linkedFactures.length} factures liées trouvées");

      Decimal total = Decimal.zero;
      for (var f in linkedFactures) {
        developer.log(
            "  - Facture ${f.numeroFacture} (ID: ${f.id}, Type: ${f.type})");
        // On additionne les paiements reçus sur ces factures
        for (var p in f.paiements) {
          developer.log(
              "    -> Paiement: ${p.montant} (Date: ${p.datePaiement}, isAcompte: ${p.isAcompte})");
          total += p.montant;
        }
      }
      developer.log("CALCUL HISTORIQUE: TOTAL = $total");
      return total;
    } catch (e) {
      developer.log("Erreur calcul historique règlements", error: e);
      return Decimal.zero;
    }
  }

  // --- PAIEMENTS ---

  Future<bool> addPaiement(Paiement paiement) async {
    return await _executeOperation(() async {
      await _repository.addPaiement(paiement);
      await fetchFactures();

      // Auto-update status check
      await _checkUpdateStatusPayee(paiement.factureId);
    });
  }

  Future<bool> deletePaiement(String paiementId, String? factureId) async {
    return await _executeOperation(() async {
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

      // Calcul du Reste à Payer
      final totalRegle =
          facture.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

      final remiseAmount =
          (facture.totalHt * facture.remiseTaux) / Decimal.fromInt(100);
      final netCommercial = facture.totalHt - remiseAmount.toDecimal();

      final reste = netCommercial - facture.acompteDejaRegle - totalRegle;

      // Tolérance pour les erreurs d'arrondi décimales infimes
      final isPaid = reste <= Decimal.parse('0.01');

      if (isPaid && facture.statut != 'payee') {
        final updated = facture.copyWith(statut: 'payee');
        await _repository.updateFacture(updated);
        await fetchFactures();
      } else if (!isPaid && facture.statut == 'payee') {
        final updated = facture.copyWith(statut: 'validee');
        await _repository.updateFacture(updated);
        await fetchFactures();
      }
    } catch (e) {
      developer.log("Error updating status payee", error: e);
    }
  }

  // --- SIGNATURE ---

  Future<bool> uploadSignature(String factureId, Uint8List bytes) async {
    return await _executeOperation(() async {
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

  // --- HELPERS ---

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    _setLoading(true);
    _clearError();
    try {
      await operation();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(dynamic error) {
    _errorMessage = error.toString();
    developer.log("FactureViewModel Error", error: error);
    notifyListeners();
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
        // En théorie 'validee' signifie qu'elle n'est pas encore 'payee' (statut final)
        // Mais on doit vérifier le reste à payer réel.

        // Calcul du total réglé
        final totalRegle =
            f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

        // Calcul acompte devis déjà s'il y a
        // Note: f.acompteDejaRegle vient du devis, il est considéré payé.

        // Attention: Dans Facture, totalHt est le total des lignes.
        // Remise est déduite du HT.
        // Net Commercial = HT - Remise.
        final remiseAmount = (f.totalHt * f.remiseTaux) / Decimal.fromInt(100);
        final netCommercial = f.totalHt - remiseAmount.toDecimal();

        // Reste = Net - AcompteInitial - TotalReglé
        // (On simplifie ici l'historique acomptes liés pour la perf standard,
        // ou on l'ignore si c'est minime. Pour être précis 100%, faudrait charger l'historique)

        final reste = netCommercial - f.acompteDejaRegle - totalRegle;

        if (reste > Decimal.zero) {
          totalImpaye += reste;
        }
      }
    }
    return totalImpaye;
  }

  /// Retourne les dernières factures modifiées/créées
  List<Facture> getRecentActivity(int limit) {
    // Tri par date d'émission (ou création si on avait le champ created_at dispo en local)
    // On utilise dateEmission pour l'instant
    final sorted = List<Facture>.from(_factures);
    sorted.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return sorted.take(limit).toList();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
