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
      // Lancement des 4 requêtes en PARALLÈLE
      final results = await Future.wait([
        _repository.getFacturesPeriod(
            dates['start']!, dates['end']!), // Index 0
        _repository.getDepensesPeriod(
            dates['start']!, dates['end']!), // Index 1
        _repository.getUrssafConfig(), // Index 2
        _repository.getProfilEntreprise(), // Index 3
      ]);

      final factures = results[0] as List<Facture>;
      final depenses = results[1] as List<Depense>;
      final urssafConfig = results[2] as UrssafConfig;
      final profilEntreprise = results[3] as ProfilEntreprise?;

      // --- CALCULS LOCAUX ---
      _calculateKPI(factures, depenses, urssafConfig, profilEntreprise, dates);
      _generateGraphData(factures);
    } catch (e, s) {
      developer.log("🔴 Erreur Dashboard VM", error: e, stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateKPI(
      List<Facture> factures,
      List<Depense> depenses,
      UrssafConfig urssaf,
      ProfilEntreprise? profil,
      Map<String, DateTime> dates) {
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

    // 2. Calcul des cotisations selon le type d'entreprise
    if (_caEncaissePeriode > Decimal.zero && profil != null) {
      final type = profil.typeEntreprise;

      if (type.isMicroEntrepreneur) {
        // Micro-entrepreneur : calculer sur CA
        _totalCotisations =
            urssaf.calculerCotisationsMicro(_caEncaissePeriode, type);
      } else if (type.isTNS) {
        // TNS : calculer sur revenu net (CA - charges)
        final revenuNet = _caEncaissePeriode - _depensesPeriode;
        if (revenuNet > Decimal.zero) {
          _totalCotisations = urssaf.calculerCotisationsTNS(revenuNet);
        }
      } else if (type.isAssimileSalarie) {
        // Assimilé salarié : estimation 30% (cotisations patronales + salariales)
        final revenu = _caEncaissePeriode - _depensesPeriode;
        if (revenu > Decimal.zero) {
          _totalCotisations =
              (revenu * Decimal.fromInt(30) / Decimal.fromInt(100)).toDecimal();
        }
      } else {
        // Fallback : 22% (taux micro moyen)
        _totalCotisations =
            (_caEncaissePeriode * Decimal.fromInt(22) / Decimal.fromInt(100))
                .toDecimal();
      }
    } else {
      // Pas de profil : utiliser estimation par défaut
      if (_caEncaissePeriode > Decimal.zero) {
        _totalCotisations =
            (_caEncaissePeriode * Decimal.fromInt(22) / Decimal.fromInt(100))
                .toDecimal();
      }
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

  // --- STATS GLOBALES (Calculées sychronement depuis les listes chargées) ---

  Decimal calculateImpayes(List<Facture> factures) {
    Decimal totalImpaye = Decimal.zero;

    for (var f in factures) {
      if (f.statut == 'validee') {
        // Calcul du total réglé
        final totalRegle =
            f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

        // Calcul du net commercial
        final remiseAmount = (f.totalHt * f.remiseTaux) / Decimal.fromInt(100);
        final netCommercial = f.totalHt - remiseAmount.toDecimal();

        // Reste = Net - AcompteInitial - TotalReglé
        final reste = netCommercial - f.acompteDejaRegle - totalRegle;

        if (reste > Decimal.zero) {
          totalImpaye += reste;
        }
      }
    }
    return totalImpaye;
  }

  Decimal calculateConversion(List<Devis> devis) {
    if (devis.isEmpty) return Decimal.zero;

    final signes =
        devis.where((d) => d.statut == 'signe' || d.statut == 'facture');
    final totalSignes = signes.length;
    final totalDevis = devis.length;

    return ((Decimal.fromInt(totalSignes) * Decimal.fromInt(100)) /
            Decimal.fromInt(totalDevis))
        .toDecimal();
  }
}
