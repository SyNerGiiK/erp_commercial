import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../widgets/custom_drawer.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard/gradient_kpi_card.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/recent_activity_list.dart';
import '../widgets/dashboard/cotisation_detail_card.dart';
import '../widgets/dashboard/plafonds_card.dart';
import '../widgets/dashboard/expense_pie_chart.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';

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
      context.read<DashboardViewModel>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond clair premium
      appBar: AppBar(
        title: const Text("Tableau de Bord",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const CustomDrawer(selectedIndex: 0),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final ca = vm.caEncaissePeriode;
          final benef = vm.beneficeNetPeriode;
          final cotis = vm.totalCotisations;
          final dep = vm.depensesPeriode;

          return RefreshIndicator(
            onRefresh: vm.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildHeader(context, vm),
                  const SizedBox(height: 32),

                  // --- KPI GRID (Cards Premium) ---
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth - 60) / 4
                              : (constraints.maxWidth - 20) / 2,
                          child: GradientKpiCard(
                            title: "Chiffre d'Affaires",
                            value: "${ca.toStringAsFixed(2)} €",
                            subtitle:
                                "${vm.caVariation >= 0 ? '+' : ''}${vm.caVariation.toStringAsFixed(1)}% vs N-1",
                            variation: vm.caVariation,
                            icon: Icons.monetization_on_outlined,
                            gradientColors: const [
                              Color(0xFF6B8EFF),
                              Color(0xFF3B66F5)
                            ],
                          ),
                        ),
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth - 60) / 4
                              : (constraints.maxWidth - 20) / 2,
                          child: GradientKpiCard(
                            title: "Bénéfice Net",
                            value: "${benef.toStringAsFixed(2)} €",
                            subtitle:
                                "${vm.beneficeVariation >= 0 ? '+' : ''}${vm.beneficeVariation.toStringAsFixed(1)}% vs N-1",
                            variation: vm.beneficeVariation,
                            icon: Icons.savings_outlined,
                            gradientColors: const [
                              Color(0xFF43E97B),
                              Color(0xFF38F9D7)
                            ],
                          ),
                        ),
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth - 60) / 4
                              : (constraints.maxWidth - 20) / 2,
                          child: GradientKpiCard(
                            title: "Cotisations 2026",
                            value: "${cotis.toStringAsFixed(2)} €",
                            subtitle: "Estimé selon statut",
                            icon: Icons.account_balance_outlined,
                            gradientColors: const [
                              Color(0xFFFA709A),
                              Color(0xFFFEE140)
                            ],
                          ),
                        ),
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth - 60) / 4
                              : (constraints.maxWidth - 20) / 2,
                          child: GradientKpiCard(
                            title: "Dépenses",
                            value: "${dep.toStringAsFixed(2)} €",
                            subtitle: "Charges déductibles",
                            variation: vm.depensesVariation,
                            icon: Icons.shopping_bag_outlined,
                            gradientColors: const [
                              Color(0xFFA8BFFF),
                              Color(0xFF884D80)
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  // --- GRAPHIQUES & DETAILS ---
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1100;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                RevenueChart(
                                  monthlyRevenue: vm.monthlyRevenue,
                                  year: DateTime.now().year,
                                ),
                                const SizedBox(height: 24),
                                if (vm.cotisationBreakdown.isNotEmpty)
                                  CotisationDetailCard(
                                    breakdown: vm.cotisationBreakdown,
                                    total: vm.totalCotisations,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildSectionTitle("Répartition Dépenses"),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ExpensePieChart(
                                        data: vm.expenseBreakdown),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (vm.urssafConfig != null &&
                                    vm.profilEntreprise != null)
                                  PlafondsCard(
                                    caVente: vm.caVente,
                                    caPrestaBIC: vm.caPrestaBIC,
                                    caPrestaBNC: vm.caPrestaBNC,
                                    type: vm.profilEntreprise!.typeEntreprise,
                                    config: vm.urssafConfig!,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile / Tablet layout
                      return Column(
                        children: [
                          RevenueChart(
                            monthlyRevenue: vm.monthlyRevenue,
                            year: DateTime.now().year,
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Répartition Dépenses"),
                          const SizedBox(height: 16),
                          ExpensePieChart(data: vm.expenseBreakdown),
                          const SizedBox(height: 24),
                          if (vm.cotisationBreakdown.isNotEmpty)
                            CotisationDetailCard(
                              breakdown: vm.cotisationBreakdown,
                              total: vm.totalCotisations,
                            ),
                          const SizedBox(height: 24),
                          if (vm.urssafConfig != null &&
                              vm.profilEntreprise != null)
                            PlafondsCard(
                              caVente: vm.caVente,
                              caPrestaBIC: vm.caPrestaBIC,
                              caPrestaBNC: vm.caPrestaBNC,
                              type: vm.profilEntreprise!.typeEntreprise,
                              config: vm.urssafConfig!,
                            ),
                        ],
                      );
                    }
                  }),

                  const SizedBox(height: 32),

                  // --- ACTIVITÉ RÉCENTE ---
                  _buildSectionTitle("Activité Récente"),
                  const SizedBox(height: 16),
                  RecentActivityList(
                    items: vm.recentActivity,
                    onTap: (item) {
                      if (item is Facture) {
                        // Adaptez la route selon votre config GoRouter
                        // context.push('/factures/detail/${item.id}');
                        // Pour l'instant on ne fait rien ou un log car je ne connais pas vos routes exactes
                        debugPrint("Tap Facture ${item.id}");
                      } else if (item is Devis) {
                        // context.push('/devis/detail/${item.id}');
                        debugPrint("Tap Devis ${item.id}");
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardViewModel vm) {
    final dateStr =
        DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            // Title removed to avoid duplication with AppBar
          ],
        ),

        // Sélecteur de Période Moderne
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              _buildPeriodTab(context, vm, DashboardPeriod.mois, "Mois"),
              _buildPeriodTab(
                  context, vm, DashboardPeriod.trimestre, "Trimestre"),
              _buildPeriodTab(context, vm, DashboardPeriod.annee, "Année"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodTab(BuildContext context, DashboardViewModel vm,
      DashboardPeriod period, String label) {
    final isSelected = vm.selectedPeriod == period;
    return GestureDetector(
      onTap: () => vm.setPeriod(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}
