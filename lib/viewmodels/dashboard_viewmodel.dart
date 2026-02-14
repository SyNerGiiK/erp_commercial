import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';

import '../repositories/dashboard_repository.dart';
import '../models/facture_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';

enum DashboardPeriod { mois, trimestre, annee }

class DashboardViewModel extends ChangeNotifier {
  final IDashboardRepository _repository = DashboardRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardPeriod _selectedPeriod = DashboardPeriod.mois;
  DashboardPeriod get selectedPeriod => _selectedPeriod;

  // KPI
  Decimal _caEncaissePeriode = Decimal.zero;
  Decimal _depensesPeriode = Decimal.zero;
  Decimal _totalCotisations = Decimal.zero;

  // Getters
  Decimal get caEncaissePeriode => _caEncaissePeriode;
  Decimal get depensesPeriode => _depensesPeriode;
  Decimal get totalCotisations => _totalCotisations;
  Decimal get beneficeNetPeriode =>
      _caEncaissePeriode - _depensesPeriode - _totalCotisations;

  // Graphiques (Mois 1-12 -> Montant)
  final Map<int, double> _graphData = {};
  Map<int, double> get graphData => _graphData;

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

      // --- OPTIMISATION PERFORMANCE ---
      // Lancement des 3 requêtes en PARALLÈLE
      final results = await Future.wait([
        _repository.getFacturesPeriod(
            dates['start']!, dates['end']!), // Index 0
        _repository.getDepensesPeriod(
            dates['start']!, dates['end']!), // Index 1
        _repository.getUrssafConfig(), // Index 2
      ]);

      final factures = results[0] as List<Facture>;
      final depenses = results[1] as List<Depense>;
      final urssafConfig = results[2] as UrssafConfig;

      // --- CALCULS LOCAUX ---
      _calculateKPI(factures, depenses, urssafConfig, dates);
      _generateGraphData(factures);
    } catch (e, s) {
      developer.log("🔴 Erreur Dashboard VM", error: e, stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateKPI(List<Facture> factures, List<Depense> depenses,
      UrssafConfig urssaf, Map<String, DateTime> dates) {
    final start = dates['start']!;
    final end = dates['end']!;

    _caEncaissePeriode = Decimal.zero;
    _depensesPeriode = Decimal.zero;
    _totalCotisations = Decimal.zero;

    // 1. CA Encaissé (Basé sur les paiements effectifs)
    for (var f in factures) {
      for (var p in f.paiements) {
        if (p.datePaiement.isAfter(start) && p.datePaiement.isBefore(end)) {
          _caEncaissePeriode += p.montant;
        }
      }
    }

    // 2. Calcul des cotisations (Estimatif)
    if (_caEncaissePeriode > Decimal.zero) {
      final taux = urssaf.tauxPrestation;
      final cotis = (_caEncaissePeriode * taux) / Decimal.fromInt(100);
      _totalCotisations = cotis.toDecimal();
    }

    // 3. Dépenses
    _depensesPeriode = depenses.fold(Decimal.zero, (sum, d) => sum + d.montant);
  }

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
}
