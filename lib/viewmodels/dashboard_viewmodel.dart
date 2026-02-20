import 'dart:developer' as developer;
import 'package:decimal/decimal.dart';

import '../repositories/dashboard_repository.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../models/chiffrage_model.dart';
import '../models/facture_recurrente_model.dart';
import '../models/temps_activite_model.dart';
import '../models/rappel_model.dart';
import '../core/base_viewmodel.dart';
import '../services/tva_service.dart';
import '../services/relance_service.dart';
import '../services/archivage_service.dart';
import '../services/urssaf_sync_service.dart';
import '../repositories/facture_repository.dart';

enum DashboardPeriod { mois, trimestre, annee }

class DashboardViewModel extends BaseViewModel {
  final IDashboardRepository _repository;
  final IFactureRepository _factureRepository;

  DashboardViewModel({
    IDashboardRepository? repository,
    IFactureRepository? factureRepository,
  })  : _repository = repository ?? DashboardRepository(),
        _factureRepository = factureRepository ?? FactureRepository();

  DashboardPeriod _selectedPeriod = DashboardPeriod.mois;
  DashboardPeriod get selectedPeriod => _selectedPeriod;

  // KPI Actuels
  Decimal _caEncaissePeriode = Decimal.zero;
  Decimal _depensesPeriode = Decimal.zero;
  Decimal _totalCotisations = Decimal.zero;

  // KPI Précédents (N-1) pour variations
  Decimal _caEncaissePrecedent = Decimal.zero;
  Decimal _depensesPrecedent = Decimal.zero;

  // Getters KPI
  Decimal get caEncaissePeriode => _caEncaissePeriode;
  Decimal get depensesPeriode => _depensesPeriode;
  Decimal get totalCotisations => _totalCotisations;
  Decimal get beneficeNetPeriode =>
      _caEncaissePeriode - _depensesPeriode - _totalCotisations;

  Decimal _caVente = Decimal.zero;
  Decimal get caVente => _caVente;

  Decimal _caPrestaBIC = Decimal.zero;
  Decimal get caPrestaBIC => _caPrestaBIC;

  Decimal _caPrestaBNC = Decimal.zero;
  Decimal get caPrestaBNC => _caPrestaBNC;

  // Variations (%)
  double get caVariation =>
      _calculateVariation(_caEncaissePeriode, _caEncaissePrecedent);
  double get depensesVariation =>
      _calculateVariation(_depensesPeriode, _depensesPrecedent);
  double get beneficeVariation => _calculateVariation(
      beneficeNetPeriode,
      (_caEncaissePrecedent -
          _depensesPrecedent)); // Approx pour N-1 (sans recalculer cotis N-1)

  // Graphiques & Analyses
  final Map<int, double> _graphData = {};
  Map<int, double> get graphData => _graphData;

  // Helper pour le Chart Widget qui attend une liste
  List<double> get monthlyRevenue {
    final list = <double>[];
    for (int i = 1; i <= 12; i++) {
      list.add(_graphData[i] ?? 0.0);
    }
    return list;
  }

  List<Map<String, dynamic>> _topClients = [];
  List<Map<String, dynamic>> get topClients => _topClients;

  Map<String, double> _expenseBreakdown = {};
  Map<String, double> get expenseBreakdown => _expenseBreakdown;

  // Activité Récente
  List<dynamic> _recentActivity = [];
  List<dynamic> get recentActivity => _recentActivity;

  // Cotisations Détail
  Map<String, Decimal> _cotisationBreakdown = {};
  Map<String, Decimal> get cotisationBreakdown => _cotisationBreakdown;

  // Sous-répartition détaillée (maladie, retraite, etc.)
  Map<String, Decimal> _cotisationRepartition = {};
  Map<String, Decimal> get cotisationRepartition => _cotisationRepartition;

  // Simulation VL vs IR (P6)
  VlVsIrSimulation? _vlVsIrSimulation;
  VlVsIrSimulation? get vlVsIrSimulation => _vlVsIrSimulation;

  // Conf
  UrssafConfig? _urssafConfig;
  ProfilEntreprise? _profilEntreprise;
  ProfilEntreprise? get profilEntreprise => _profilEntreprise;
  UrssafConfig? get urssafConfig => _urssafConfig;

  // Helpers type d'entreprise (pour adaptation conditionnelle de l'UI)
  bool get isMicro =>
      _profilEntreprise?.typeEntreprise.isMicroEntrepreneur ?? true;
  bool get isTNS => _profilEntreprise?.typeEntreprise.isTNS ?? false;
  bool get isAssimileSalarie =>
      _profilEntreprise?.typeEntreprise.isAssimileSalarie ?? false;
  bool get tvaApplicable => _profilEntreprise?.tvaApplicable ?? false;

  // Analyse TVA
  BilanTva? _bilanTva;
  BilanTva? get bilanTva => _bilanTva;

  // Factures en retard (relances)
  List<RelanceInfo> _relances = [];
  List<RelanceInfo> get relances => _relances;
  int get nbFacturesEnRetard => _relances.length;
  Decimal get montantTotalRetard =>
      _relances.fold(Decimal.zero, (sum, r) => sum + r.resteAPayer);

  // Archivage automatique
  List<Facture> _facturesArchivables = [];
  List<Facture> get facturesArchivables => _facturesArchivables;
  bool _archivageDismissed = false;
  bool get showArchivageSuggestion =>
      _facturesArchivables.isNotEmpty && !_archivageDismissed;

  // Statistiques Devis (pipeline & conversion)
  Decimal _tauxConversion = Decimal.zero;
  int _devisEnCours = 0;
  Decimal _montantPipeline = Decimal.zero;
  int _totalDevisYear = 0;

  Decimal get tauxConversion => _tauxConversion;
  int get devisEnCours => _devisEnCours;
  Decimal get montantPipeline => _montantPipeline;
  int get totalDevisYear => _totalDevisYear;

  // === NOUVELLES DONNÉES DASHBOARD ===

  // Factures récurrentes actives
  List<FactureRecurrente> _facturesRecurrentes = [];
  List<FactureRecurrente> get facturesRecurrentes => _facturesRecurrentes;

  // Temps non facturés
  List<TempsActivite> _tempsNonFactures = [];
  List<TempsActivite> get tempsNonFactures => _tempsNonFactures;
  int get totalMinutesNonFacturees =>
      _tempsNonFactures.fold(0, (sum, t) => sum + t.dureeMinutes);
  Decimal get montantNonFacture =>
      _tempsNonFactures.fold(Decimal.zero, (sum, t) => sum + t.montant);
  String get dureeNonFactureeFormatee {
    final h = totalMinutesNonFacturees ~/ 60;
    final m = totalMinutesNonFacturees % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  // Rappels / échéances
  List<Rappel> _prochainRappels = [];
  List<Rappel> get prochainRappels => _prochainRappels;
  int get nbRappelsEnRetard =>
      _prochainRappels.where((r) => r.estEnRetard).length;
  int get nbRappelsProches => _prochainRappels.where((r) => r.estProche).length;

  // Trésorerie prévisionnelle
  List<Facture> _facturesImpayees = [];
  List<Facture> get facturesImpayees => _facturesImpayees;
  Decimal get tresoreriePrev =>
      _facturesImpayees.fold(Decimal.zero, (sum, f) => sum + _resteAPayer(f));

  /// Encaissements attendus par mois (3 prochains mois)
  Map<String, Decimal> get encaissementsParMois {
    final now = DateTime.now();
    final result = <String, Decimal>{};
    for (int i = 0; i < 3; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      result[key] = Decimal.zero;
    }
    // Répartir factures impayées par mois d'échéance
    for (final f in _facturesImpayees) {
      final key =
          '${f.dateEcheance.year}-${f.dateEcheance.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        result[key] = result[key]! + _resteAPayer(f);
      } else {
        // Échéance passée → ajouter au mois courant
        final nowKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        if (result.containsKey(nowKey)) {
          result[nowKey] = result[nowKey]! + _resteAPayer(f);
        }
      }
    }
    // Ajouter projections récurrentes
    for (final fr in _facturesRecurrentes) {
      final key =
          '${fr.prochaineEmission.year}-${fr.prochaineEmission.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        result[key] = result[key]! + fr.totalTtc;
      }
    }
    return result;
  }

  /// Taux de marge (bénéfice / CA)
  double get tauxMarge {
    if (_caEncaissePeriode == Decimal.zero) return 0.0;
    return beneficeNetPeriode.toDouble() / _caEncaissePeriode.toDouble() * 100;
  }

  Decimal _resteAPayer(Facture f) {
    final totalPaiements =
        f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);
    final reste = f.totalTtc - f.acompteDejaRegle - totalPaiements;
    return reste > Decimal.zero ? reste : Decimal.zero;
  }

  void dismissArchivageSuggestion() {
    _archivageDismissed = true;
    notifyListeners();
  }

  /// Archive toutes les factures archivables en lot.
  Future<void> archiverToutesLesFactures() async {
    await executeOperation(() async {
      for (final f in _facturesArchivables) {
        if (f.id != null) {
          await _factureRepository.updateArchiveStatus(f.id!, true);
        }
      }
      _facturesArchivables = [];
      _archivageDismissed = false;
    });
  }

  // --- ACTIONS ---

  void setPeriod(DashboardPeriod period) {
    _selectedPeriod = period;
    refreshData();
  }

  Future<void> refreshData() async {
    await execute(() async {
      final now = DateTime.now();
      final dates = _getDatesForPeriod(_selectedPeriod, now);
      final datesPrev =
          _getDatesForPreviousPeriod(_selectedPeriod, dates['start']!);

      // --- OPTIMISATION PERFORMANCE ---
      // Lancement des requêtes en PARALLÈLE
      final results = await Future.wait([
        _repository.getFacturesPeriod(dates['start']!, dates['end']!), // 0
        _repository.getDepensesPeriod(dates['start']!, dates['end']!), // 1
        _repository.getUrssafConfig(), // 2
        _repository.getProfilEntreprise(), // 3
        _repository.getFacturesPeriod(
            datesPrev['start']!, datesPrev['end']!), // 4
        _repository.getDepensesPeriod(
            datesPrev['start']!, datesPrev['end']!), // 5
        _repository.getRecentActivity(), // 6
        _repository
            .getAllFacturesYear(now.year), // 7: Pour le graphe annuel complet
        _repository.getAllDevisYear(now.year), // 8: Statistiques devis
        _repository.getFacturesRecurrentesActives(), // 9: Factures récurrentes
        _repository.getTempsNonFactures(), // 10: Temps non facturés
        _repository.getRappelsProchains(30), // 11: Rappels 30 jours
        _repository.getFacturesImpayees(), // 12: Trésorerie prévisionnelle
      ]);

      final factures = results[0] as List<Facture>;
      final depenses = results[1] as List<Depense>;
      _urssafConfig = results[2] as UrssafConfig;
      _profilEntreprise = results[3] as ProfilEntreprise?;
      final facturesPrev = results[4] as List<Facture>;
      final depensesPrev = results[5] as List<Depense>;
      _recentActivity = results[6] as List<dynamic>;
      final allFacturesYear = results[7] as List<Facture>;
      final allDevisYear = results[8] as List<Devis>;
      _facturesRecurrentes = results[9] as List<FactureRecurrente>;
      _tempsNonFactures = results[10] as List<TempsActivite>;
      _prochainRappels = results[11] as List<Rappel>;
      _facturesImpayees = results[12] as List<Facture>;

      // --- CALCULS ---
      _calculateKPI(factures, depenses, dates, isCurrent: true);
      _calculateKPI(facturesPrev, depensesPrev, datesPrev, isCurrent: false);

      _generateGraphData(allFacturesYear);
      _generateTopClients(factures);
      _generateExpenseBreakdown(depenses);

      // Analyse TVA YTD — uniquement si l'entreprise n'est pas déjà assujettie
      if (_urssafConfig != null && _profilEntreprise?.tvaApplicable != true) {
        final caYtd = TvaService.calculerCaYtd(allFacturesYear);
        _bilanTva = TvaService.analyser(
          caVenteYtd: caYtd.caVente,
          caServiceYtd: caYtd.caService,
          config: _urssafConfig!,
        );
      } else {
        _bilanTva = null;
      }

      // Relances — factures en retard
      _relances = RelanceService.analyserRelances(allFacturesYear);

      // Archivage automatique — factures soldées depuis plus d'un an
      _facturesArchivables =
          ArchivageService.detecterArchivables(allFacturesYear);
      _archivageDismissed = false;

      // Statistiques Devis — taux de conversion & pipeline
      _computeDevisStats(allDevisYear);
    });
  }

  void _calculateKPI(List<Facture> factures, List<Depense> depenses,
      Map<String, DateTime> dates,
      {required bool isCurrent}) {
    final start = dates['start']!;
    final end = dates['end']!;

    Decimal ca = Decimal.zero;
    Decimal dep = Decimal.zero;

    // 1. CA Encaissé (total TTC)
    for (var f in factures) {
      Decimal factureVente = Decimal.zero;
      Decimal facturePresta = Decimal.zero;

      // Calcul de la part Vente et Presta sur le HT total de la facture
      if (f.lignes.isNotEmpty) {
        for (final l in f.lignes) {
          final chiffragesLigne =
              f.chiffrage.where((c) => c.linkedLigneDevisId == l.id).toList();

          if (chiffragesLigne.isNotEmpty) {
            // Utilisation prioritaire de la Ventilation Secrète (Rentabilité)
            for (final c in chiffragesLigne) {
              if (c.typeChiffrage == TypeChiffrage.materiel) {
                factureVente += c.prixVenteInterne;
              } else {
                facturePresta += c.prixVenteInterne;
              }
            }
          } else {
            // Fallback habituel
            if (TvaService.isVente(l.typeActivite)) {
              factureVente += l.totalLigne;
            } else {
              facturePresta += l.totalLigne;
            }
          }
        }
      } else {
        facturePresta += f.totalHt; // Fallback
      }

      // Calcul des paiements de cette période pour cette facture
      Decimal encaisseFacturePeriode = Decimal.zero;
      for (var p in f.paiements) {
        if (p.datePaiement.isAfter(start) && p.datePaiement.isBefore(end)) {
          encaisseFacturePeriode += p.montant;
        }
      }

      if (encaisseFacturePeriode > Decimal.zero) {
        ca += encaisseFacturePeriode;

        if (isCurrent && f.totalTtc > Decimal.zero) {
          // Proratisation TTC de l'encaissement par rapport à la ventilation HT
          final ratio =
              encaisseFacturePeriode.toDouble() / f.totalTtc.toDouble();
          _caVente += Decimal.parse(
              (factureVente.toDouble() * ratio).toStringAsFixed(2));
          // Note: On ventile en priorité sur BIC. S'il s'agit de BNC, l'utilisateur a tout de même la possibilité de changer en BNC globalement,
          // mais dans les faits, l'ERP est centré "Artisanat", donc Presta = BIC Service par défaut.
          final pBic = Decimal.parse(
              (facturePresta.toDouble() * ratio).toStringAsFixed(2));

          if (_urssafConfig?.typeActivite == TypeActiviteMicro.bncPrestation) {
            _caPrestaBNC += pBic;
          } else {
            _caPrestaBIC += pBic;
          }
        }
      }
    }

    // 2. Dépenses (inchangé)
    dep = depenses.fold(Decimal.zero, (sum, d) => sum + d.montant);

    if (isCurrent) {
      _caEncaissePeriode = ca;
      _depensesPeriode = dep;
      _calculateCotisationsCurrent();
    } else {
      _caEncaissePrecedent = ca;
      _depensesPrecedent = dep;
    }
  }

  void _calculateCotisationsCurrent() {
    _totalCotisations = Decimal.zero;
    _cotisationBreakdown = {};
    _cotisationRepartition = {};

    if (_urssafConfig == null) return;
    final config = _urssafConfig!;
    final type =
        _profilEntreprise?.typeEntreprise ?? TypeEntreprise.microEntrepreneur;

    if (type.isMicroEntrepreneur) {
      // Micro-entrepreneur : cotisations sur le CA encaissé
      if (_caEncaissePeriode > Decimal.zero) {
        final result =
            config.calculerCotisations(_caVente, _caPrestaBIC, _caPrestaBNC);
        _totalCotisations = result['total'] ?? Decimal.zero;
        _cotisationBreakdown = result;
        _cotisationRepartition =
            config.calculerRepartition(_caVente, _caPrestaBIC, _caPrestaBNC);
      }
    } else if (type.isTNS) {
      // TNS (EI / EURL) : cotisations sur le bénéfice (CA - dépenses)
      final benefice = _caEncaissePeriode - _depensesPeriode;
      if (benefice > Decimal.zero) {
        final result = config.calculerCotisationsTNS(benefice);
        _totalCotisations = result['total'] ?? Decimal.zero;
        _cotisationBreakdown = result;
        _cotisationRepartition = {
          'maladie': result['maladie'] ?? Decimal.zero,
          'allocations_familiales':
              result['allocations_familiales'] ?? Decimal.zero,
          'retraite_base': result['retraite_base'] ?? Decimal.zero,
          'retraite_complementaire':
              result['retraite_complementaire'] ?? Decimal.zero,
          'invalidite_deces': result['invalidite_deces'] ?? Decimal.zero,
          'csg_crds': result['csg_crds'] ?? Decimal.zero,
        };
      }
    }
    // SASU / SAS (assimilé salarié) : cotisations via fiches de paie,
    // pas d'estimation possible ici → _totalCotisations reste à zéro.
  }

  /// Lance la simulation VL vs IR via l'API Publicodes.
  /// À appeler après le chargement initial si le CA > 0.
  /// Uniquement pour les micro-entrepreneurs (le VL n'existe pas pour les autres).
  Future<void> simulerVlVsIr() async {
    if (_urssafConfig == null || _caEncaissePeriode == Decimal.zero) return;
    if (!isMicro) return;

    try {
      final syncService = UrssafSyncService();
      _vlVsIrSimulation = await syncService.simulerVlVsIr(
        caVente: _caVente,
        caPrestaBIC: _caPrestaBIC,
        caPrestaBNC: _caPrestaBNC,
        config: _urssafConfig!,
      );
      notifyListeners();
    } catch (e, s) {
      developer.log('🔴 Simulation VL vs IR', error: e, stackTrace: s);
    }
  }

  // --- ANALYTICS ---

  void _generateGraphData(List<Facture> factures) {
    _graphData.clear();
    final now = DateTime.now();

    // Init à 0
    for (int i = 1; i <= 12; i++) {
      _graphData[i] = 0.0;
    }

    // Remplissage
    for (var f in factures) {
      for (var p in f.paiements) {
        if (p.datePaiement.year == now.year) {
          _graphData[p.datePaiement.month] =
              (_graphData[p.datePaiement.month] ?? 0) + p.montant.toDouble();
        }
      }
    }
  }

  void _generateTopClients(List<Facture> factures) {
    final Map<String, Decimal> clientCA = {};
    final Map<String, String> clientNames = {};

    for (var f in factures) {
      final cid = f.clientId;
      if (cid.isNotEmpty) {
        final totalRegle =
            f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);
        clientCA[cid] = (clientCA[cid] ?? Decimal.zero) + totalRegle;
        if (!clientNames.containsKey(cid)) {
          clientNames[cid] =
              f.objet; // Fallback, sera enrichi par le nom client
        }
      }
    }

    final ranked = clientCA.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _topClients = ranked.take(5).map((entry) {
      return {
        'clientId': entry.key,
        'ca': entry.value,
        'label': clientNames[entry.key] ?? entry.key,
      };
    }).toList();
  }

  void _generateExpenseBreakdown(List<Depense> depenses) {
    _expenseBreakdown = {};
    for (var d in depenses) {
      final cat = d.categorie;
      _expenseBreakdown[cat] =
          (_expenseBreakdown[cat] ?? 0.0) + d.montant.toDouble();
    }
  }

  void _computeDevisStats(List<Devis> devis) {
    _totalDevisYear = 0;
    _devisEnCours = 0;
    _montantPipeline = Decimal.zero;
    _tauxConversion = Decimal.zero;

    if (devis.isEmpty) return;

    int nonAnnules = 0;
    int signes = 0;

    for (var d in devis) {
      _totalDevisYear++;

      if (d.statut != 'annule') {
        nonAnnules++;
        if (d.statut == 'signe') {
          signes++;
        }
        // Pipeline = devis en cours (brouillon, envoyé, ou expiré mais pas annulé/signé)
        if (d.statut == 'brouillon' || d.statut == 'envoye') {
          _devisEnCours++;
          _montantPipeline += d.totalHt;
        }
      }
    }

    if (nonAnnules > 0) {
      _tauxConversion = (Decimal.fromInt(signes) / Decimal.fromInt(nonAnnules))
              .toDecimal(scaleOnInfinitePrecision: 10) *
          Decimal.fromInt(100);
    }
  }

  // --- HELPERS DATES ---

  Map<String, DateTime> _getDatesForPeriod(
      DashboardPeriod period, DateTime now) {
    DateTime start, end;
    switch (period) {
      case DashboardPeriod.mois:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case DashboardPeriod.trimestre:
        int quarter = ((now.month - 1) / 3).floor() + 1;
        start = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        end = DateTime(now.year, quarter * 3 + 1, 0, 23, 59, 59);
        break;
      case DashboardPeriod.annee:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }
    return {'start': start, 'end': end};
  }

  Map<String, DateTime> _getDatesForPreviousPeriod(
      DashboardPeriod period, DateTime currentStart) {
    // Reculer d'une période par rapport au début de la période courante
    DateTime start, end;
    switch (period) {
      case DashboardPeriod.mois:
        // Mois précédent
        start = DateTime(currentStart.year, currentStart.month - 1, 1);
        end = DateTime(currentStart.year, currentStart.month, 0, 23, 59, 59);
        break;
      case DashboardPeriod.trimestre:
        // Trimestre précédent (-3 mois)
        start = DateTime(currentStart.year, currentStart.month - 3, 1);
        final endDate = DateTime(currentStart.year, currentStart.month, 1)
            .subtract(const Duration(days: 1));
        end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        break;
      case DashboardPeriod.annee:
        // Année précédente
        start = DateTime(currentStart.year - 1, 1, 1);
        end = DateTime(currentStart.year - 1, 12, 31, 23, 59, 59);
        break;
    }
    return {'start': start, 'end': end};
  }

  double _calculateVariation(Decimal current, Decimal previous) {
    if (previous == Decimal.zero) return 0.0;
    // Explicit conversion to double to avoid Rational type issues
    final double curr = current.toDouble();
    final double prev = previous.toDouble();
    return ((curr - prev) / prev) * 100.0;
  }
}
