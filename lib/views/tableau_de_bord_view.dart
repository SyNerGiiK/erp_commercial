// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';

import '../widgets/base_screen.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/recent_activity_list.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';

class TableauDeBordView extends StatefulWidget {
  const TableauDeBordView({super.key});

  @override
  State<TableauDeBordView> createState() => _TableauDeBordViewState();
}

class _TableauDeBordViewState extends State<TableauDeBordView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (mounted) {
      final dashVM = Provider.of<DashboardViewModel>(context, listen: false);
      final factVM = Provider.of<FactureViewModel>(context, listen: false);
      final devisVM = Provider.of<DevisViewModel>(context, listen: false);

      dashVM.refreshData();
      if (factVM.factures.isEmpty) factVM.fetchFactures();
      if (devisVM.devis.isEmpty) devisVM.fetchDevis();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashVM = Provider.of<DashboardViewModel>(context);
    final factVM = Provider.of<FactureViewModel>(context);
    final devisVM = Provider.of<DevisViewModel>(context);

    // Prepare Graph Data
    final List<Decimal> graphData = List<Decimal>.filled(12, Decimal.zero);
    dashVM.graphData.forEach((month, value) {
      if (month >= 1 && month <= 12) {
        graphData[month - 1] = Decimal.parse(value.toString());
      }
    });

    // Prepare Recent Activity
    final recentFactures = factVM.getRecentActivity(5);
    final recentDevis = devisVM.getRecentActivity(5);
    final List<dynamic> allActivity = [...recentFactures, ...recentDevis];
    allActivity.sort((a, b) {
      DateTime dateA =
          a is Facture ? a.dateEmission : (a as Devis).dateEmission;
      DateTime dateB =
          b is Facture ? b.dateEmission : (b as Devis).dateEmission;
      return dateB.compareTo(dateA); // Descending
    });
    final recentActivity = allActivity.take(5).toList();

    return BaseScreen(
      menuIndex: 0,
      title: "Cockpit",
      subtitle: "Vue d'ensemble de l'activité",
      headerActions: [
        DropdownButton<DashboardPeriod>(
          value: dashVM.selectedPeriod,
          dropdownColor: AppTheme.primary,
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: Container(),
          items: const [
            DropdownMenuItem(
                value: DashboardPeriod.mois, child: Text("Ce Mois")),
            DropdownMenuItem(
                value: DashboardPeriod.trimestre, child: Text("Ce Trimestre")),
            DropdownMenuItem(
                value: DashboardPeriod.annee, child: Text("Cette Année")),
          ],
          onChanged: (v) {
            if (v != null) dashVM.setPeriod(v);
          },
        )
      ],
      child: dashVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ROW 1: Période (CA & Bénéfice)
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: "CA Encaissé",
                            subtitle: _getPeriodLabel(dashVM.selectedPeriod),
                            value:
                                FormatUtils.currency(dashVM.caEncaissePeriode),
                            icon: Icons.account_balance_wallet,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KpiCard(
                            title: "Bénéfice Net",
                            subtitle: "Après charges est.",
                            value:
                                FormatUtils.currency(dashVM.beneficeNetPeriode),
                            icon: Icons.savings,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ROW 2: Global (Impayés & Conversion)
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<Decimal>(
                            future: factVM.getImpayes(),
                            initialData: Decimal.zero,
                            builder: (context, snapshot) {
                              return KpiCard(
                                title: "Impayés",
                                subtitle: "Reste à recouvrer",
                                value: FormatUtils.currency(
                                    snapshot.data ?? Decimal.zero),
                                icon: Icons.warning_amber,
                                color: Colors.orange,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FutureBuilder<Decimal>(
                            future: devisVM.getConversionRate(),
                            initialData: Decimal.zero,
                            builder: (context, snapshot) {
                              final rate = snapshot.data ?? Decimal.zero;
                              return KpiCard(
                                title: "Transformation",
                                subtitle: "Devis signés",
                                value: "${rate.toStringAsFixed(1)} %",
                                icon: Icons.check_circle_outline,
                                color: Colors.purple,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CHART
                    RevenueChart(
                      monthlyRevenue: graphData,
                      year: DateTime.now().year,
                    ),
                    const SizedBox(height: 24),

                    // ACTIVITY
                    RecentActivityList(
                      items: recentActivity,
                      onTap: (item) {
                        try {
                          if (item is Facture && item.id != null) {
                            context.push('/ajout_facture/${item.id}',
                                extra: item);
                          } else if (item is Devis && item.id != null) {
                            context.push('/ajout_devis/${item.id}',
                                extra: item);
                          }
                        } catch (e) {
                          debugPrint("Nav error: $e");
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  String _getPeriodLabel(DashboardPeriod p) {
    switch (p) {
      case DashboardPeriod.mois:
        return "Ce mois-ci";
      case DashboardPeriod.trimestre:
        return "Ce trimestre";
      case DashboardPeriod.annee:
        return "Cette année";
    }
  }
}
