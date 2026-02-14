import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
      // Génération Numéro
      final annee = DateTime.now().year;
      final newNumero = await _repository.generateNextNumero(annee);

      // Update local temporaire pour éviter re-fetch immédiat (Optimistic)
      final updated = facture.copyWith(
        numeroFacture: newNumero,
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

      // On récupère toutes les factures liées à ce devis
      final response = await _client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .eq('devis_source_id', devisSourceId)
          .neq('id', excludeFactureId); // On exclut la facture courante

      final linkedFactures =
          (response as List).map((e) => Facture.fromMap(e)).toList();

      Decimal total = Decimal.zero;
      for (var f in linkedFactures) {
        // On additionne les paiements reçus sur ces factures
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

  // --- PAIEMENTS ---

  Future<bool> addPaiement(Paiement paiement) async {
    return await _executeOperation(() async {
      await _repository.addPaiement(paiement);
      await fetchFactures();
    });
  }

  Future<bool> deletePaiement(String paiementId) async {
    return await _executeOperation(() async {
      await _repository.deletePaiement(paiementId);
      await fetchFactures();
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

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
