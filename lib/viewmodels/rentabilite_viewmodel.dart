import 'dart:async';
import 'dart:developer' as developer;
import 'package:decimal/decimal.dart';

import '../core/base_viewmodel.dart';
import '../models/devis_model.dart';
import '../models/chiffrage_model.dart';
import '../models/depense_model.dart';
import '../repositories/chiffrage_repository.dart';
import '../repositories/devis_repository.dart';
import '../repositories/depense_repository.dart';
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
  final IDepenseRepository _depenseRepo;

  RentabiliteViewModel({
    IChiffrageRepository? chiffrageRepository,
    IDevisRepository? devisRepository,
    IDepenseRepository? depenseRepository,
  })  : _chiffrageRepo = chiffrageRepository ?? ChiffrageRepository(),
        _devisRepo = devisRepository ?? DevisRepository(),
        _depenseRepo = depenseRepository ??
            ((chiffrageRepository != null || devisRepository != null)
                ? _MemoryDepenseRepository()
                : DepenseRepository());

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

  /// Dépenses (Réelles) du devis sélectionné
  List<Depense> _depenses = [];
  List<Depense> get depenses => _depenses;

  /// Cache des dépenses par chantier (devisId)
  Map<String, List<Depense>> _depensesByDevis = {};
  Map<String, List<Depense>> get depensesByDevis => _depensesByDevis;

  /// Map ligneDevisId → avancement calculé
  Map<String, Decimal> _avancements = {};
  Map<String, Decimal> get avancements => _avancements;

  /// Avancement global du devis sélectionné
  Decimal _avancementGlobal = Decimal.zero;
  Decimal get avancementGlobal => _avancementGlobal;

  /// Marge réelle = (Total Devis HT) - (Total Dépenses)
  Decimal get margeReelle {
    if (_selectedDevis == null) return Decimal.zero;
    final totalDepenses = _depenses.fold(
        Decimal.zero,
        (sum, d) =>
            sum +
            d.montant); // montant est TTC par défaut sur les dépenses, à raffiner si besoin réel
    return _selectedDevis!.totalHt - totalDepenses;
  }

  /// Facturation = Total encaissements
  Decimal get facturationEncaissee {
    if (_selectedDevis == null) return Decimal.zero;
    // Note: Devis -> Transformé en Facture. Pour le MVP Cockpit on utilise l'acompte
    // Mais l'idéal serait de récupérer la facture liée pour sommer les vrais paiements
    return _selectedDevis!.acompteMontant;
  }

  Decimal get margePrevue {
    if (_selectedDevis == null) return Decimal.zero;
    final totalAchats = _chiffrages.fold<Decimal>(
      Decimal.zero,
      (sum, c) => sum + c.totalAchat,
    );
    return _selectedDevis!.totalHt - totalAchats;
  }

  Decimal get tauxEncaissement {
    if (_selectedDevis == null || _selectedDevis!.totalTtc <= Decimal.zero) {
      return Decimal.zero;
    }
    return ((facturationEncaissee * Decimal.fromInt(100)) /
            _selectedDevis!.totalTtc)
        .toDecimal();
  }

  /// Devis expandus dans le panneau gauche (déconseillé dans le dashboard mais gardé pour compat')
  final Set<String> _expandedDevisIds = {};
  Set<String> get expandedDevisIds => _expandedDevisIds;

  /// Timer debounce pour auto-save
  Timer? _debounceTimer;

  /// Flag de dirty pour savoir si des changements sont en attente
  bool _isDirty = false;
  bool get isDirty => _isDirty;

  // ============ CHARGEMENT ============

  /// Charge tous les chantiers actifs (Devis Validés/Acceptés)
  Future<void> loadDevis() async {
    await execute(() async {
      _devisList = await _devisRepo.getChantiersActifs();

      final depensesEntries = await Future.wait(
        _devisList.where((d) => d.id != null).map((devis) async {
          final id = devis.id!;
          final list = await _depenseRepo.getDepensesByChantier(id);
          return MapEntry(id, list);
        }),
      );

      _depensesByDevis = {
        for (final entry in depensesEntries) entry.key: entry.value
      };
    });
  }

  /// Sélectionne un devis et charge son écosystème
  Future<void> selectDevis(Devis devis) async {
    _selectedDevis = devis;
    _selectedLigneDevis = null;
    notifyListeners();

    await Future.wait([
      _loadChiffrages(devis.id!),
      _loadDepenses(devis.id!),
    ]);
  }

  /// Charge les dépenses d'un chantier
  Future<void> _loadDepenses(String devisId) async {
    await execute(() async {
      final loaded = await _depenseRepo.getDepensesByChantier(devisId);
      _depenses = loaded;
      _depensesByDevis[devisId] = loaded;
    });
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

  /// Sélectionne une ligne de devis pour afficher ses coûts dans le panneau droit.
  /// Si la ligne n'a aucun coût interne et qu'elle est chiffrable,
  /// un coût par défaut est créé automatiquement.
  /// Le type (matériel vs main d'œuvre) est déduit par analyse textuelle de la description.
  Future<void> selectLigneDevis(LigneDevis ligne) async {
    _selectedLigneDevis = ligne;
    notifyListeners();

    // Auto-init : créer un coût par défaut si la ligne est chiffrable et vide
    if (ligne.id != null &&
        _selectedDevis != null &&
        !['titre', 'sous-titre', 'texte', 'saut_page'].contains(ligne.type)) {
      final existing =
          _chiffrages.where((c) => c.linkedLigneDevisId == ligne.id);
      if (existing.isEmpty) {
        try {
          final prixTotalVente = ligne.quantite * ligne.prixUnitaire;
          final type = _detecterTypeChiffrage(ligne.description);
          final defaultChiffrage = LigneChiffrage(
            devisId: _selectedDevis!.id,
            linkedLigneDevisId: ligne.id,
            designation: ligne.description,
            quantite: ligne.quantite,
            prixAchatUnitaire: Decimal.zero, // Prix d'achat inconnu par défaut
            prixVenteInterne: prixTotalVente,
            typeChiffrage: type,
            estAchete: false,
          );
          final created = await _chiffrageRepo.create(defaultChiffrage);
          _chiffrages.add(created);
          _recalculerAvancements();
        } catch (e) {
          developer.log('🔴 Auto-init chiffrage error: $e');
        }
      }
    }
  }

  /// Détecte le type de chiffrage à partir de la description textuelle.
  /// Si la description contient des termes liés à la main d'œuvre,
  /// retourne [TypeChiffrage.mainDoeuvre], sinon [TypeChiffrage.materiel].
  static TypeChiffrage _detecterTypeChiffrage(String description) {
    final lower = description.toLowerCase();
    const motsClesMo = [
      'main d\'oeuvre',
      'main d\'œuvre',
      'main-d\'oeuvre',
      'main-d\'œuvre',
      'mo ',
      'm.o.',
      'pose',
      'installation',
      'montage',
      'démontage',
      'dépose',
      'mise en service',
      'mise en place',
      'intervention',
      'prestation',
      'réparation',
      'entretien',
      'nettoyage',
      'peinture',
      'enduit',
      'plâtre',
      'maçonnerie',
      'soudure',
      'raccordement',
      'heure',
      'heures',
      'journée',
      'journées',
      'forfait mo',
      'forfait main',
      'travaux',
    ];
    for (final mot in motsClesMo) {
      if (lower.contains(mot)) {
        return TypeChiffrage.mainDoeuvre;
      }
    }
    return TypeChiffrage.materiel;
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

  List<LigneChiffrage> getChiffragesForLigne(String ligneDevisId) {
    return _chiffrages
        .where((c) => c.linkedLigneDevisId == ligneDevisId)
        .toList();
  }

  Decimal getAvancementForDevis(Devis devis) {
    return CalculationsUtils.calculateDevisAvancementGlobal(
      tousChiffrages: devis.chiffrage,
    );
  }

  Decimal getTauxEncaissementForDevis(Devis devis) {
    if (devis.totalTtc <= Decimal.zero) return Decimal.zero;
    return ((devis.acompteMontant * Decimal.fromInt(100)) / devis.totalTtc)
        .toDecimal();
  }

  Decimal getMargePrevueForDevis(Devis devis) {
    final totalAchats = devis.chiffrage.fold<Decimal>(
      Decimal.zero,
      (sum, c) => sum + c.totalAchat,
    );
    return devis.totalHt - totalAchats;
  }

  Decimal getMargeReelleForDevis(Devis devis) {
    final chantierId = devis.id;
    if (chantierId == null) return devis.totalHt;

    final depenses = _depensesByDevis[chantierId] ?? const <Depense>[];
    final totalDepenses = depenses.fold<Decimal>(
      Decimal.zero,
      (sum, d) => sum + d.montant,
    );
    return devis.totalHt - totalDepenses;
  }

  Decimal getMargeNetteComparativeForDevis(Devis devis) {
    final margePrevue = getMargePrevueForDevis(devis);
    if (margePrevue <= Decimal.zero) return Decimal.zero;

    final margeReelle = getMargeReelleForDevis(devis);
    return ((margeReelle * Decimal.fromInt(100)) / margePrevue).toDecimal();
  }

  Decimal getVentilationMaterielRatio(Devis devis) {
    final linked = _chiffrages.where((c) => c.devisId == devis.id).toList();
    final totalVente = linked.fold<Decimal>(
      Decimal.zero,
      (sum, c) => sum + c.prixVenteInterne,
    );
    if (totalVente <= Decimal.zero) return Decimal.fromInt(50);

    final materiel = linked
        .where((c) => c.typeChiffrage == TypeChiffrage.materiel)
        .fold<Decimal>(Decimal.zero, (sum, c) => sum + c.prixVenteInterne);

    return ((materiel * Decimal.fromInt(100)) / totalVente).toDecimal();
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

  Future<void> updateVentilationForLigne(
    String ligneDevisId,
    Decimal ratioMateriel,
  ) async {
    if (_selectedDevis == null) return;

    LigneDevis? ligne;
    for (final current in _selectedDevis!.lignes) {
      if (current.id == ligneDevisId) {
        ligne = current;
        break;
      }
    }

    if (ligne == null) return;

    final clamped = ratioMateriel < Decimal.zero
        ? Decimal.zero
        : (ratioMateriel > Decimal.fromInt(100)
            ? Decimal.fromInt(100)
            : ratioMateriel);

    await ensureVentilationForLigne(ligne);

    final linked = getChiffragesForLigne(ligneDevisId);
    final materielLignes =
        linked.where((c) => c.typeChiffrage == TypeChiffrage.materiel).toList();
    final moLignes = linked
        .where((c) => c.typeChiffrage == TypeChiffrage.mainDoeuvre)
        .toList();

    if (materielLignes.isEmpty || moLignes.isEmpty) return;

    final total = ligne.totalLigne;
    final totalMateriel =
        ((total * clamped) / Decimal.fromInt(100)).toDecimal();
    final totalMo = total - totalMateriel;

    final updates = <LigneChiffrage>[];
    updates.addAll(_repartirPrixVenteInterne(materielLignes, totalMateriel));
    updates.addAll(_repartirPrixVenteInterne(moLignes, totalMo));

    for (final updated in updates) {
      final index = _chiffrages.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _chiffrages[index] = updated;
      }
    }

    _recalculerAvancements();
    _debounceSave(() async {
      await Future.wait(updates.map((c) => _chiffrageRepo.update(c)));
    });
  }

  Future<void> ensureVentilationForLigne(LigneDevis ligne) async {
    if (_selectedDevis?.id == null || ligne.id == null) return;

    final linked = getChiffragesForLigne(ligne.id!);
    final hasMateriel =
        linked.any((c) => c.typeChiffrage == TypeChiffrage.materiel);
    final hasMo =
        linked.any((c) => c.typeChiffrage == TypeChiffrage.mainDoeuvre);

    if (hasMateriel && hasMo) return;

    final defaultMaterielRatio =
        _detecterTypeChiffrage(ligne.description) == TypeChiffrage.materiel
            ? Decimal.fromInt(70)
            : Decimal.fromInt(30);

    final total = ligne.totalLigne;
    final totalMateriel =
        ((total * defaultMaterielRatio) / Decimal.fromInt(100)).toDecimal();
    final totalMo = total - totalMateriel;

    if (!hasMateriel) {
      final created = await _chiffrageRepo.create(
        LigneChiffrage(
          devisId: _selectedDevis!.id,
          linkedLigneDevisId: ligne.id,
          designation: '${ligne.description} - Matériel',
          quantite: Decimal.fromInt(1),
          prixAchatUnitaire: Decimal.zero,
          prixVenteInterne: totalMateriel,
          typeChiffrage: TypeChiffrage.materiel,
          estAchete: false,
        ),
      );
      _chiffrages.add(created);
    }

    if (!hasMo) {
      final created = await _chiffrageRepo.create(
        LigneChiffrage(
          devisId: _selectedDevis!.id,
          linkedLigneDevisId: ligne.id,
          designation: '${ligne.description} - MO',
          quantite: Decimal.fromInt(1),
          prixAchatUnitaire: Decimal.zero,
          prixVenteInterne: totalMo,
          typeChiffrage: TypeChiffrage.mainDoeuvre,
          avancementMo: Decimal.zero,
        ),
      );
      _chiffrages.add(created);
    }

    _recalculerAvancements();
  }

  List<LigneChiffrage> _repartirPrixVenteInterne(
    List<LigneChiffrage> lignes,
    Decimal totalType,
  ) {
    if (lignes.isEmpty) return [];
    if (lignes.length == 1) {
      return [lignes.first.copyWith(prixVenteInterne: totalType)];
    }

    final sommeActuelle = lignes.fold<Decimal>(
        Decimal.zero, (sum, c) => sum + c.prixVenteInterne);

    if (sommeActuelle <= Decimal.zero) {
      final taille = Decimal.fromInt(lignes.length);
      final unitaire = (totalType / taille).toDecimal();
      return lignes.map((c) => c.copyWith(prixVenteInterne: unitaire)).toList();
    }

    final result = <LigneChiffrage>[];
    Decimal cumul = Decimal.zero;
    for (var i = 0; i < lignes.length; i++) {
      final current = lignes[i];
      if (i == lignes.length - 1) {
        result.add(current.copyWith(prixVenteInterne: totalType - cumul));
        continue;
      }

      final part =
          ((totalType * current.prixVenteInterne) / sommeActuelle).toDecimal();
      cumul += part;
      result.add(current.copyWith(prixVenteInterne: part));
    }
    return result;
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

class _MemoryDepenseRepository implements IDepenseRepository {
  @override
  Future<void> createDepense(Depense depense) async {}

  @override
  Future<void> deleteDepense(String id) async {}

  @override
  Future<List<Depense>> getDeletedDepenses() async => [];

  @override
  Future<List<Depense>> getDepenses() async => [];

  @override
  Future<List<Depense>> getDepensesByChantier(String devisId) async => [];

  @override
  Future<void> purgeDepense(String id) async {}

  @override
  Future<void> restoreDepense(String id) async {}

  @override
  Future<void> updateDepense(Depense depense) async {}
}
