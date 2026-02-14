// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../models/facture_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
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
      if (mounted) {
        Provider.of<DashboardViewModel>(context, listen: false).refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    return BaseScreen(
      menuIndex: 0, // INDEX IMPORTANT
      title: "Cockpit",
      subtitle: "Vue d'ensemble de l'activité",
      headerActions: [
        DropdownButton<DashboardPeriod>(
          value: vm.selectedPeriod,
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
            if (v != null) vm.setPeriod(v);
          },
        )
      ],
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // KPI CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: "Chiffre d'Affaires",
                          amount: FormatUtils.currency(vm.caEncaissePeriode),
                          icon: Icons.attach_money,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          title: "Bénéfice Net",
                          amount: FormatUtils.currency(vm.beneficeNetPeriode),
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: "Charges (URSSAF)",
                          amount: FormatUtils.currency(vm.totalCotisations),
                          icon: Icons.account_balance,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          title: "Dépenses / Achats",
                          amount: FormatUtils.currency(vm.depensesPeriode),
                          icon: Icons.shopping_cart,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // GRAPHIQUE
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Évolution CA (Annuel)",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: vm.graphData.values.isEmpty
                                    ? 1000
                                    : (vm.graphData.values.reduce(
                                                (a, b) => a > b ? a : b) *
                                            1.2)
                                        .toDouble(),
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const style = TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        );
                                        String text;
                                        switch (value.toInt()) {
                                          case 1:
                                            text = 'J';
                                            break;
                                          case 3:
                                            text = 'M';
                                            break;
                                          case 5:
                                            text = 'M';
                                            break;
                                          case 7:
                                            text = 'J';
                                            break;
                                          case 9:
                                            text = 'S';
                                            break;
                                          case 11:
                                            text = 'N';
                                            break;
                                          default:
                                            return Container();
                                        }
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 4,
                                          child: Text(text, style: style),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: vm.graphData.entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value,
                                        color: AppTheme.primary,
                                        width: 12,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Style minimaliste moderne
    final isDark = color == AppTheme.primary || color == AppTheme.secondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // Fond teinté léger
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? Colors.white : color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
