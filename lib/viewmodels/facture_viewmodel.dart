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

  // AJOUTÉ: Méthode manquante
  Future<bool> createFacture(Facture facture) async {
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

  // AJOUTÉ: Gestion signature conforme repo (id)
  Future<void> deleteFacture(String id, [String? statutJuridique]) async {
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

  // --- LOGIQUE MÉTIER ---

  // AJOUTÉ: Méthode manquante pour générer numéros
  Future<String> generateNextNumero() async {
    final annee = DateTime.now().year;
    return await _repository.generateNextNumero(annee);
  }

  /// Calcule le montant déjà réglé (via d'autres factures) pour un Devis donné.
  /// Utile pour les factures d'avancement.
  Future<Decimal> getMontantDejaReglePourDevis(String devisId,
      {String? excludeFactureId}) async {
    try {
      // On récupère toutes les factures liées à ce devis
      final response = await _client
          .from('factures')
          .select('*, paiements(*)')
          .eq('devis_source_id', devisId)
          .neq('statut', 'brouillon'); // Seules les factures validées comptent

      final List<Facture> linkedFactures = (response as List)
          .map((e) => Facture.fromMap(e))
          .where(
              (f) => f.id != excludeFactureId) // On exclut la facture courante
          .toList();

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

  void _setError(dynamic e) {
    _errorMessage = e.toString();
    developer.log("Erreur ViewModel", error: e);
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
