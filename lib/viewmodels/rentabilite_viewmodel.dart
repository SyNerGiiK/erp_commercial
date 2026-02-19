import 'dart:async';
import 'dart:developer' as developer;
import 'package:decimal/decimal.dart';

import '../core/base_viewmodel.dart';
import '../models/devis_model.dart';
import '../models/chiffrage_model.dart';
import '../repositories/chiffrage_repository.dart';
import '../repositories/devis_repository.dart';
import '../utils/calculations_utils.dart';

/// État d'avancement calculé pour une ligne de devis
class LigneDevisAvancement {
  final LigneDevis ligne;
  final Decimal avancement;
  final Decimal valeurRealisee;
  final Decimal prixTotal;
  final List<LigneChiffrage> chiffrages;
  final bool isComplete;

  LigneDevisAvancement({
    required this.ligne,
    required this.avancement,
    required this.valeurRealisee,
    required this.prixTotal,
    required this.chiffrages,
  }) : isComplete = avancement >= Decimal.fromInt(100);
}

/// ViewModel pour la vue "Analyse & Rentabilité" revampée.
///
/// Gère l'arbre Devis → LigneDevis → LigneChiffrage avec :
/// - Navigation fluide dans le panneau gauche (sélection devis puis ligne)
/// - État réactif dans le panneau droit (coûts liés + toggle/slider)
/// - Auto-save transparent avec debounce sur chaque modification
/// - Calcul d'avancement en temps réel
class RentabiliteViewModel extends BaseViewModel {
  final IChiffrageRepository _chiffrageRepo;
  final IDevisRepository _devisRepo;

  RentabiliteViewModel({
    IChiffrageRepository? chiffrageRepository,
    IDevisRepository? devisRepository,
  })  : _chiffrageRepo = chiffrageRepository ?? ChiffrageRepository(),
        _devisRepo = devisRepository ?? DevisRepository();

  // ============ ÉTAT ============

  List<Devis> _devisList = [];
  List<Devis> get devisList => _devisList;

  Devis? _selectedDevis;
  Devis? get selectedDevis => _selectedDevis;

  LigneDevis? _selectedLigneDevis;
  LigneDevis? get selectedLigneDevis => _selectedLigneDevis;

  /// Chiffrages du devis sélectionné (tous)
  List<LigneChiffrage> _chiffrages = [];
  List<LigneChiffrage> get chiffrages => _chiffrages;

  /// Map ligneDevisId → avancement calculé
  Map<String, Decimal> _avancements = {};
  Map<String, Decimal> get avancements => _avancements;

  /// Avancement global du devis sélectionné
  Decimal _avancementGlobal = Decimal.zero;
  Decimal get avancementGlobal => _avancementGlobal;

  /// Devis expandus dans le panneau gauche
  final Set<String> _expandedDevisIds = {};
  Set<String> get expandedDevisIds => _expandedDevisIds;

  /// Timer debounce pour auto-save
  Timer? _debounceTimer;

  /// Flag de dirty pour savoir si des changements sont en attente
  bool _isDirty = false;
  bool get isDirty => _isDirty;

  // ============ CHARGEMENT ============

  /// Charge tous les devis actifs (non archivés, non supprimés)
  Future<void> loadDevis() async {
    await execute(() async {
      _devisList = await _devisRepo.getDevis(archives: false);
    });
  }

  /// Sélectionne un devis et charge ses chiffrages
  Future<void> selectDevis(Devis devis) async {
    _selectedDevis = devis;
    _selectedLigneDevis = null;
    notifyListeners();

    await _loadChiffrages(devis.id!);
  }

  /// Toggle l'expansion d'un devis dans le panneau gauche
  void toggleDevisExpanded(String devisId) {
    if (_expandedDevisIds.contains(devisId)) {
      _expandedDevisIds.remove(devisId);
    } else {
      _expandedDevisIds.add(devisId);
    }
    notifyListeners();
  }

  /// Sélectionne une ligne de devis pour afficher ses coûts dans le panneau droit
  void selectLigneDevis(LigneDevis ligne) {
    _selectedLigneDevis = ligne;
    notifyListeners();
  }

  /// Charge les chiffrages d'un devis et recalcule les avancements
  Future<void> _loadChiffrages(String devisId) async {
    await execute(() async {
      _chiffrages = await _chiffrageRepo.getByDevisId(devisId);
      _recalculerAvancements();
    });
  }

  // ============ CHIFFRAGES DU PANNEAU DROIT ============

  /// Retourne les chiffrages liés à la ligne de devis sélectionnée
  List<LigneChiffrage> get chiffragesForSelectedLigne {
    if (_selectedLigneDevis?.id == null) return [];
    return _chiffrages
        .where((c) => c.linkedLigneDevisId == _selectedLigneDevis!.id)
        .toList();
  }

  /// Retourne les avancements détaillés pour chaque ligne du devis sélectionné
  List<LigneDevisAvancement> get lignesAvancement {
    if (_selectedDevis == null) return [];

    return _selectedDevis!.lignes
        .where((l) =>
            !['titre', 'sous-titre', 'texte', 'saut_page'].contains(l.type))
        .map((ligne) {
      final enfants =
          _chiffrages.where((c) => c.linkedLigneDevisId == ligne.id).toList();
      final prixTotal = ligne.quantite * ligne.prixUnitaire;
      final avancement = _avancements[ligne.id] ?? Decimal.zero;
      final valeurRealisee = enfants.fold<Decimal>(
        Decimal.zero,
        (sum, c) => sum + c.valeurRealisee,
      );

      return LigneDevisAvancement(
        ligne: ligne,
        avancement: avancement,
        valeurRealisee: valeurRealisee,
        prixTotal: prixTotal,
        chiffrages: enfants,
      );
    }).toList();
  }

  // ============ MUTATIONS (avec auto-save) ============

  /// Ajoute un nouveau coût lié à une ligne de devis
  Future<bool> ajouterChiffrage(LigneChiffrage ligne) async {
    return await executeOperation(() async {
      final created = await _chiffrageRepo.create(ligne);
      _chiffrages.add(created);
      _recalculerAvancements();
    });
  }

  /// Supprime un coût
  Future<bool> supprimerChiffrage(String id) async {
    return await executeOperation(() async {
      await _chiffrageRepo.delete(id);
      _chiffrages.removeWhere((c) => c.id == id);
      _recalculerAvancements();
    });
  }

  /// Toggle le statut d'achat d'un matériel (binaire : acheté/pas acheté)
  /// Auto-save immédiat + recalcul d'avancement
  void toggleEstAchete(String chiffrageId) {
    final index = _chiffrages.indexWhere((c) => c.id == chiffrageId);
    if (index == -1) return;

    final current = _chiffrages[index];
    final newValue = !current.estAchete;

    _chiffrages[index] = current.copyWith(estAchete: newValue);
    _recalculerAvancements();

    // Auto-save immédiat pour les toggles
    _autoSave(() => _chiffrageRepo.updateEstAchete(chiffrageId, newValue));
  }

  /// Met à jour l'avancement MO (slider 0-100)
  /// Auto-save avec debounce (300ms) pour éviter les appels réseau excessifs
  void updateAvancementMo(String chiffrageId, Decimal avancement) {
    final index = _chiffrages.indexWhere((c) => c.id == chiffrageId);
    if (index == -1) return;

    // Clamp entre 0 et 100
    final clamped = avancement < Decimal.zero
        ? Decimal.zero
        : (avancement > Decimal.fromInt(100)
            ? Decimal.fromInt(100)
            : avancement);

    _chiffrages[index] = _chiffrages[index].copyWith(avancementMo: clamped);
    _recalculerAvancements();

    // Debounce auto-save pour le slider
    _debounceSave(
        () => _chiffrageRepo.updateAvancementMo(chiffrageId, clamped));
  }

  /// Met à jour une ligne de chiffrage complète (édition du formulaire)
  Future<bool> updateChiffrage(LigneChiffrage updated) async {
    return await executeOperation(() async {
      await _chiffrageRepo.update(updated);
      final index = _chiffrages.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _chiffrages[index] = updated;
      }
      _recalculerAvancements();
    });
  }

  // ============ CALCULS ============

  /// Recalcule les avancements de toutes les lignes du devis sélectionné
  void _recalculerAvancements() {
    if (_selectedDevis == null) {
      _avancements = {};
      _avancementGlobal = Decimal.zero;
      notifyListeners();
      return;
    }

    _avancements = CalculationsUtils.calculateAllLignesAvancement(
      lignesDevis: _selectedDevis!.lignes,
      tousChiffrages: _chiffrages,
    );

    _avancementGlobal = CalculationsUtils.calculateDevisAvancementGlobal(
      tousChiffrages: _chiffrages,
    );

    notifyListeners();
  }

  /// Retourne la map complète des avancements par ligne de devis
  /// pour pré-remplir une facture de situation (mode Global)
  Map<String, Decimal> getAvancementsForFactureSituation() {
    return Map<String, Decimal>.from(_avancements);
  }

  // ============ AUTO-SAVE ============

  /// Auto-save immédiat (pour les toggles binaires)
  void _autoSave(Future<void> Function() saveOperation) {
    _isDirty = true;
    saveOperation().then((_) {
      _isDirty = false;
      notifyListeners();
    }).catchError((e) {
      developer.log('🔴 Auto-save error: $e');
      _isDirty = true;
      notifyListeners();
    });
  }

  /// Auto-save avec debounce (pour les sliders)
  void _debounceSave(Future<void> Function() saveOperation,
      {Duration duration = const Duration(milliseconds: 400)}) {
    _isDirty = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      saveOperation().then((_) {
        _isDirty = false;
        notifyListeners();
      }).catchError((e) {
        developer.log('🔴 Debounce save error: $e');
        _isDirty = true;
        notifyListeners();
      });
    });
  }

  // ============ LIFECYCLE ============

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
