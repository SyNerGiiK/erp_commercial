import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../config/theme.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_drawer.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../widgets/dashboard/gradient_kpi_card.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/recent_activity_list.dart';
import '../widgets/dashboard/cotisation_detail_card.dart';
import '../widgets/dashboard/plafonds_card.dart';
import '../widgets/dashboard/expense_pie_chart.dart';
import '../widgets/dashboard/suivi_seuil_tva_card.dart';
import '../widgets/dashboard/factures_retard_card.dart';
import '../widgets/dashboard/archivage_suggestion_card.dart';
import '../widgets/dashboard/vl_vs_ir_card.dart';
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
      _initDashboard();
    });
  }

  Future<void> _initDashboard() async {
    final dashVM = context.read<DashboardViewModel>();
    await dashVM.refreshData();
    if (!mounted) return;

    // Onboarding : si le profil n'a pas de nom d'entreprise → première connexion
    final entrepriseVM =
        Provider.of<EntrepriseViewModel>(context, listen: false);
    await entrepriseVM.fetchProfil();
    if (!mounted) return;

    final profil = entrepriseVM.profil;
    if (profil == null || profil.nomEntreprise.trim().isEmpty) {
      context.go('/app/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const BaseScreen(
            title: "Tableau de Bord",
            menuIndex: 0,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final ca = vm.caEncaissePeriode;
        final benef = vm.beneficeNetPeriode;
        final cotis = vm.totalCotisations;
        final dep = vm.depensesPeriode;

        return BaseScreen(
          title: "Tableau de Bord",
          menuIndex: 0,
          child: RefreshIndicator(
            onRefresh: vm.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // Padding géré par BaseScreen (16.0), on ajoute juste un peu si besoin ou on laisse.
              // BaseScreen met 16.0. L'ancien code avait 24.0. On peut laisser tel quel ou ajuster.
              // Le contenu est dans un ConstrainedBox(maxWidth: 1200) fourni par BaseScreen.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildHeader(context, vm),
                  const SizedBox(height: AppTheme.spacing32),

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
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6)
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
                              Color(0xFF10B981),
                              Color(0xFF06B6D4)
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
                              Color(0xFFF43F5E),
                              Color(0xFFF59E0B)
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
                              Color(0xFF818CF8),
                              Color(0xFF475569)
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: AppTheme.spacing32),

                  // --- DEVIS PIPELINE & CONVERSION ---
                  if (vm.totalDevisYear > 0)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Pipeline Devis',
                            icon: Icons.description_outlined,
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          LayoutBuilder(builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 32) / 3
                                      : constraints.maxWidth,
                                  child: _buildDevisStatCard(
                                    icon: Icons.trending_up_rounded,
                                    title: 'Taux de conversion',
                                    value:
                                        '${vm.tauxConversion.toStringAsFixed(1)}%',
                                    subtitle:
                                        '${vm.totalDevisYear} devis cette année',
                                    color: vm.tauxConversion.toDouble() >= 50
                                        ? const Color(0xFF43E97B)
                                        : vm.tauxConversion.toDouble() >= 25
                                            ? Colors.orange
                                            : Colors.red.shade400,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 32) / 3
                                      : constraints.maxWidth,
                                  child: _buildDevisStatCard(
                                    icon: Icons.hourglass_top_rounded,
                                    title: 'Devis en cours',
                                    value: '${vm.devisEnCours}',
                                    subtitle: 'brouillons & envoyés',
                                    color: const Color(0xFF6B8EFF),
                                  ),
                                ),
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 32) / 3
                                      : constraints.maxWidth,
                                  child: _buildDevisStatCard(
                                    icon: Icons.account_balance_wallet_outlined,
                                    title: 'Montant pipeline',
                                    value:
                                        '${vm.montantPipeline.toStringAsFixed(2)} €',
                                    subtitle: 'CA potentiel en attente',
                                    color: const Color(0xFFA8BFFF),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                  // --- FACTURES EN RETARD ---
                  if (vm.relances.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing32),
                      child: FacturesRetardCard(
                        relances: vm.relances,
                        onTap: () => context.go('/app/relances'),
                      ),
                    ),

                  // --- ARCHIVAGE AUTOMATIQUE ---
                  if (vm.showArchivageSuggestion)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spacing32),
                      child: ArchivageSuggestionCard(
                        facturesArchivables: vm.facturesArchivables,
                        onArchiver: () async {
                          final count = vm.facturesArchivables.length;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Archiver les factures'),
                              content: Text(
                                'Archiver $count facture${count > 1 ? 's' : ''} soldée${count > 1 ? 's' : ''} depuis plus d\'un an ?\n\n'
                                'Vous pourrez les retrouver dans l\'onglet Archives.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Annuler'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Archiver'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await vm.archiverToutesLesFactures();
                          }
                        },
                        onDismiss: vm.dismissArchivageSuggestion,
                      ),
                    ),

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
                                const SizedBox(height: AppTheme.spacing24),
                                if (vm.cotisationBreakdown.isNotEmpty)
                                  CotisationDetailCard(
                                    breakdown: vm.cotisationBreakdown,
                                    total: vm.totalCotisations,
                                    repartition: vm.cotisationRepartition,
                                  ),
                                if (vm.vlVsIrSimulation != null) ...[
                                  const SizedBox(height: AppTheme.spacing24),
                                  VlVsIrCard(simulation: vm.vlVsIrSimulation!),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SectionHeader(
                                  title: 'Répartition Dépenses',
                                  icon: Icons.pie_chart_outline_rounded,
                                ),
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
                                const SizedBox(height: AppTheme.spacing24),
                                if (vm.urssafConfig != null &&
                                    vm.profilEntreprise != null)
                                  PlafondsCard(
                                    caVente: vm.caVente,
                                    caPrestaBIC: vm.caPrestaBIC,
                                    caPrestaBNC: vm.caPrestaBNC,
                                    type: vm.profilEntreprise!.typeEntreprise,
                                    config: vm.urssafConfig!,
                                  ),
                                if (vm.bilanTva != null) ...[
                                  const SizedBox(height: AppTheme.spacing24),
                                  SuiviSeuilTvaCard(bilan: vm.bilanTva!),
                                ],
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
                          const SizedBox(height: AppTheme.spacing24),
                          const SectionHeader(
                            title: 'Répartition Dépenses',
                            icon: Icons.pie_chart_outline_rounded,
                          ),
                          ExpensePieChart(data: vm.expenseBreakdown),
                          const SizedBox(height: AppTheme.spacing24),
                          if (vm.cotisationBreakdown.isNotEmpty)
                            CotisationDetailCard(
                              breakdown: vm.cotisationBreakdown,
                              total: vm.totalCotisations,
                              repartition: vm.cotisationRepartition,
                            ),
                          if (vm.vlVsIrSimulation != null) ...[
                            const SizedBox(height: AppTheme.spacing24),
                            VlVsIrCard(simulation: vm.vlVsIrSimulation!),
                          ],
                          const SizedBox(height: AppTheme.spacing24),
                          if (vm.urssafConfig != null &&
                              vm.profilEntreprise != null)
                            PlafondsCard(
                              caVente: vm.caVente,
                              caPrestaBIC: vm.caPrestaBIC,
                              caPrestaBNC: vm.caPrestaBNC,
                              type: vm.profilEntreprise!.typeEntreprise,
                              config: vm.urssafConfig!,
                            ),
                          if (vm.bilanTva != null) ...[
                            const SizedBox(height: AppTheme.spacing24),
                            SuiviSeuilTvaCard(bilan: vm.bilanTva!),
                          ],
                        ],
                      );
                    }
                  }),

                  const SizedBox(height: AppTheme.spacing32),

                  // --- ACTIVITÉ RÉCENTE ---
                  const SectionHeader(
                    title: 'Activité Récente',
                    icon: Icons.history_rounded,
                  ),
                  RecentActivityList(
                    items: vm.recentActivity,
                    onTap: (item) {
                      if (item is Facture) {
                        // Adaptez la route selon votre config GoRouter
                        context.push('/app/ajout_facture/${item.id}',
                            extra: item);
                      } else if (item is Devis) {
                        context.push('/app/ajout_devis/${item.id}',
                            extra: item);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        // Sélecteur de Période Aurora — pilule glass
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlassBright,
            borderRadius: AppTheme.borderRadiusMedium,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1,
            ),
            boxShadow: AppTheme.shadowSmall,
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: AppTheme.borderRadiusSmall,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDevisStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlassBright,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
