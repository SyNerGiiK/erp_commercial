import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';

import '../repositories/dashboard_repository.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';

enum DashboardPeriod { mois, trimestre, annee }

class DashboardViewModel extends ChangeNotifier {
  final IDashboardRepository _repository = DashboardRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  // Conf
  UrssafConfig? _urssafConfig;
  ProfilEntreprise? _profilEntreprise;
  ProfilEntreprise? get profilEntreprise => _profilEntreprise;
  UrssafConfig? get urssafConfig => _urssafConfig;

  // --- ACTIONS ---

  void setPeriod(DashboardPeriod period) {
    _selectedPeriod = period;
    refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
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
      ]);

      final factures = results[0] as List<Facture>;
      final depenses = results[1] as List<Depense>;
      _urssafConfig = results[2] as UrssafConfig;
      _profilEntreprise = results[3] as ProfilEntreprise?;
      final facturesPrev = results[4] as List<Facture>;
      final depensesPrev = results[5] as List<Depense>;
      _recentActivity = results[6] as List<dynamic>;
      final allFacturesYear = results[7] as List<Facture>;

      // --- CALCULS ---
      _calculateKPI(factures, depenses, dates, isCurrent: true);
      _calculateKPI(facturesPrev, depensesPrev, datesPrev, isCurrent: false);

      _generateGraphData(allFacturesYear); // Sur l'année entière
      _generateTopClients(factures);
      _generateExpenseBreakdown(depenses);
    } catch (e, s) {
      developer.log("🔴 Erreur Dashboard VM", error: e, stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateKPI(List<Facture> factures, List<Depense> depenses,
      Map<String, DateTime> dates,
      {required bool isCurrent}) {
    final start = dates['start']!;
    final end = dates['end']!;

    Decimal ca = Decimal.zero;
    Decimal dep = Decimal.zero;

    // 1. CA Encaissé
    for (var f in factures) {
      for (var p in f.paiements) {
        if (p.datePaiement.isAfter(start) && p.datePaiement.isBefore(end)) {
          ca += p.montant;
        }
      }
    }

    // 2. Dépenses
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
    _caVente = Decimal.zero;
    _caPrestaBIC = Decimal.zero;
    _caPrestaBNC = Decimal.zero;

    if (_caEncaissePeriode > Decimal.zero && _urssafConfig != null) {
      final config = _urssafConfig!;

      // Ventilation MVP : On applique le type principal défini dans la config.
      // NOTE : À l'avenir, il faudra ventiler le CA par type (Vente vs Service) depuis les factures
      // si des métadonnées plus précises sont disponibles.
      switch (config.typeActivite) {
        case TypeActiviteMicro.bicVente:
          _caVente = _caEncaissePeriode;
          break;
        case TypeActiviteMicro.bicPrestation:
          _caPrestaBIC = _caEncaissePeriode;
          break;
        case TypeActiviteMicro.bncPrestation:
          _caPrestaBNC = _caEncaissePeriode;
          break;
        case TypeActiviteMicro.mixte:
          // Cas complexe : Sans métadonnées sur les factures, impossible de savoir.
          // On met 50/50 pour l'exemple ou tout en Vente par défaut
          _caVente = (_caEncaissePeriode / Decimal.fromInt(2)).toDecimal();
          _caPrestaBIC = (_caEncaissePeriode - _caVente);
          break;
      }

      final result =
          config.calculerCotisations(_caVente, _caPrestaBIC, _caPrestaBNC);

      _totalCotisations = result['total'] ?? Decimal.zero;
      _cotisationBreakdown = result;
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
    // MVP: On laisse vide pour l'instant
    _topClients = [];
  }

  void _generateExpenseBreakdown(List<Depense> depenses) {
    _expenseBreakdown = {};
    for (var d in depenses) {
      final cat = d.categorie;
      _expenseBreakdown[cat] =
          (_expenseBreakdown[cat] ?? 0.0) + d.montant.toDouble();
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
