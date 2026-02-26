// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../widgets/base_screen.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../widgets/dashboard/gradient_kpi_card.dart';
import '../widgets/dashboard/revenue_chart.dart';
import '../widgets/dashboard/expense_pie_chart.dart';
import '../widgets/dashboard/regime_block.dart';
import '../widgets/dashboard/devis_pipeline_card.dart';
import '../widgets/dashboard/top_clients_card.dart';
import '../widgets/dashboard/factures_recurrentes_card.dart';
import '../widgets/dashboard/temps_non_facture_card.dart';
import '../widgets/dashboard/rappels_card.dart';
import '../widgets/dashboard/tresorerie_card.dart';
import '../widgets/dashboard/alertes_banner.dart';
import '../widgets/dashboard/recent_activity_list.dart';
import '../widgets/dashboard/weather_widget.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/enums/entreprise_enums.dart';

class TableauDeBordView extends StatefulWidget {
  const TableauDeBordView({super.key});

  @override
  State<TableauDeBordView> createState() => _TableauDeBordViewState();
}

class _TableauDeBordViewState extends State<TableauDeBordView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDashboard();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initDashboard() async {
    final dashVM = context.read<DashboardViewModel>();
    await dashVM.refreshData();
    if (!mounted) return;

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

        return BaseScreen(
          title: "Tableau de Bord",
          menuIndex: 0,
          useFullWidth: true,
          child: RefreshIndicator(
            onRefresh: vm.refreshData,
            child: LayoutBuilder(
              builder: (context, outerConstraints) {
                final isDesktop = outerConstraints.maxWidth > 1100;
                final isTablet = outerConstraints.maxWidth > 700;

                return Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: outerConstraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- HEADER ----------------------------
                            _buildHeader(context, vm),
                            SizedBox(height: AppTheme.spacing24),

                            // --- ALERTES (retard + archivage) ------
                            AlertesBanner(
                              relances: vm.relances,
                              facturesArchivables: vm.showArchivageSuggestion
                                  ? vm.facturesArchivables
                                  : [],
                              onRelancesTap: () => context.go('/app/relances'),
                              onArchiverTap: () async {
                                final count = vm.facturesArchivables.length;
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Archiver les factures'),
                                    content: Text(
                                      'Archiver $count facture${count > 1 ? 's' : ''} sold�e${count > 1 ? 's' : ''} depuis plus d\'un an ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Annuler'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Archiver'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await vm.archiverToutesLesFactures();
                                }
                              },
                              onDismissArchivage: vm.dismissArchivageSuggestion,
                            ),

                            // --- 5 KPI CARDS ----------------------
                            _buildKpiRow(context, vm, isDesktop, isTablet),
                            SizedBox(height: AppTheme.spacing24),

                            // --- ZONE PRINCIPALE 2 COLONNES -------
                            if (isDesktop)
                              _buildDesktopMainSection(context, vm)
                            else
                              _buildMobileMainSection(context, vm),

                            SizedBox(height: AppTheme.spacing20),

                            // --- 4 MINI-CARDS (infos compl�mentaires) -
                            _buildMiniCardsRow(
                                context, vm, isDesktop, isTablet),

                            SizedBox(height: AppTheme.spacing20),

                            // --- ACTIVIT� R�CENTE ------------------
                            if (vm.recentActivity.isNotEmpty) ...[
                              SectionHeader(
                                title: 'Activit� R�cente',
                                icon: Icons.history_rounded,
                              ),
                              SizedBox(
                                height: 160,
                                child: RecentActivityList(
                                  items: vm.recentActivity,
                                  onTap: (item) {
                                    if (item is Facture) {
                                      context.push(
                                          '/app/ajout_facture/${item.id}',
                                          extra: item);
                                    } else if (item is Devis) {
                                      context.push(
                                          '/app/ajout_devis/${item.id}',
                                          extra: item);
                                    }
                                  },
                                ),
                              ),
                            ],
                            SizedBox(height: AppTheme.spacing16),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------
  // KPI ROW � 5 cartes avec gradient Aurora
  // -------------------------------------------------------------------

  Widget _buildKpiRow(BuildContext context, DashboardViewModel vm,
      bool isDesktop, bool isTablet) {
    final ca = vm.caEncaissePeriode;
    final benef = vm.beneficeNetPeriode;
    final cotis = vm.totalCotisations;
    final dep = vm.depensesPeriode;
    final treso = vm.tresoreriePrev;

    final kpiCards = <Widget>[
      GradientKpiCard(
        title: "Chiffre d'Affaires",
        value: "${ca.toDouble().toStringAsFixed(2)} �",
        subtitle:
            "${vm.caVariation >= 0 ? '+' : ''}${vm.caVariation.toStringAsFixed(1)}% vs N-1",
        variation: vm.caVariation,
        icon: Icons.monetization_on_outlined,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      GradientKpiCard(
        title: "B�n�fice Net",
        value: "${benef.toDouble().toStringAsFixed(2)} �",
        subtitle:
            "${vm.beneficeVariation >= 0 ? '+' : ''}${vm.beneficeVariation.toStringAsFixed(1)}% vs N-1",
        variation: vm.beneficeVariation,
        icon: Icons.savings_outlined,
        gradientColors: const [Color(0xFF10B981), Color(0xFF06B6D4)],
      ),
      GradientKpiCard(
        title: vm.isAssimileSalarie ? "Charges Sociales" : "Cotisations",
        value: "${cotis.toDouble().toStringAsFixed(2)} �",
        subtitle: vm.isMicro
            ? "Estim� sur le CA"
            : vm.isTNS
                ? "Estim� sur le b�n�fice"
                : "Via fiches de paie",
        icon: Icons.account_balance_outlined,
        gradientColors: const [Color(0xFFF43F5E), Color(0xFFF59E0B)],
      ),
      GradientKpiCard(
        title: "D�penses",
        value: "${dep.toDouble().toStringAsFixed(2)} �",
        subtitle: "Charges d�ductibles",
        variation: vm.depensesVariation,
        icon: Icons.shopping_bag_outlined,
        gradientColors: const [Color(0xFF818CF8), Color(0xFF475569)],
      ),
      GradientKpiCard(
        title: "Tr�sorerie Pr�v.",
        value: "${treso.toDouble().toStringAsFixed(2)} �",
        subtitle: "${vm.facturesImpayees.length} facture(s) en attente",
        icon: Icons.account_balance_wallet_outlined,
        gradientColors: const [Color(0xFF0EA5E9), Color(0xFF6366F1)],
      ),
    ];

    // On calcule le nombre de colonnes selon la taille
    final cols = isDesktop ? 5 : (isTablet ? 3 : 1);
    const spacing = 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: 160,
      ),
      itemCount: kpiCards.length,
      itemBuilder: (context, i) {
        return kpiCards[i]
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: (80 * i).ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.12,
              end: 0,
              duration: 500.ms,
              delay: (80 * i).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  // -------------------------------------------------------------------
  // DESKTOP : 2 colonnes (Graphiques + Pipeline | RegimeBlock)
  // -------------------------------------------------------------------

  Widget _buildDesktopMainSection(BuildContext context, DashboardViewModel vm) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Colonne gauche : CA Chart + D�penses + Pipeline --
          Expanded(
            flex: 3,
            child: Column(
              children: [
                RevenueChart(
                  monthlyRevenue: vm.monthlyRevenue,
                  year: DateTime.now().year,
                  compact: true,
                ),
                SizedBox(height: AppTheme.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: _buildExpenseMiniCard(vm),
                    ),
                    SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: DevisPipelineCard(
                        tauxConversion: vm.tauxConversion,
                        devisEnCours: vm.devisEnCours,
                        montantPipeline: vm.montantPipeline,
                        totalDevisYear: vm.totalDevisYear,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppTheme.spacing20),

          // -- Colonne droite : Bloc R�gime adaptatif --
          Expanded(
            flex: 2,
            child: RegimeBlock(
              typeEntreprise: vm.profilEntreprise?.typeEntreprise ??
                  TypeEntreprise.microEntrepreneur,
              isMicro: vm.isMicro,
              isTNS: vm.isTNS,
              isAssimileSalarie: vm.isAssimileSalarie,
              caVente: vm.caVente,
              caPrestaBIC: vm.caPrestaBIC,
              caPrestaBNC: vm.caPrestaBNC,
              urssafConfig: vm.urssafConfig,
              bilanTva: vm.bilanTva,
              vlVsIrSimulation: vm.vlVsIrSimulation,
              cotisationBreakdown: vm.cotisationBreakdown,
              totalCotisations: vm.totalCotisations,
              cotisationRepartition: vm.cotisationRepartition,
              caEncaisse: vm.caEncaissePeriode,
              depenses: vm.depensesPeriode,
              beneficeNet: vm.beneficeNetPeriode,
              tauxMarge: vm.tauxMarge,
              expenseBreakdown: vm.expenseBreakdown,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic)
        .slideY(
            begin: 0.08,
            end: 0,
            duration: 600.ms,
            delay: 300.ms,
            curve: Curves.easeOutCubic);
  }

  // -------------------------------------------------------------------
  // MOBILE/TABLET : empil� verticalement
  // -------------------------------------------------------------------

  Widget _buildMobileMainSection(BuildContext context, DashboardViewModel vm) {
    return Column(
      children: [
        RevenueChart(
          monthlyRevenue: vm.monthlyRevenue,
          year: DateTime.now().year,
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildExpenseMiniCard(vm),
        SizedBox(height: AppTheme.spacing16),
        DevisPipelineCard(
          tauxConversion: vm.tauxConversion,
          devisEnCours: vm.devisEnCours,
          montantPipeline: vm.montantPipeline,
          totalDevisYear: vm.totalDevisYear,
        ),
        SizedBox(height: AppTheme.spacing16),
        RegimeBlock(
          typeEntreprise: vm.profilEntreprise?.typeEntreprise ??
              TypeEntreprise.microEntrepreneur,
          isMicro: vm.isMicro,
          isTNS: vm.isTNS,
          isAssimileSalarie: vm.isAssimileSalarie,
          caVente: vm.caVente,
          caPrestaBIC: vm.caPrestaBIC,
          caPrestaBNC: vm.caPrestaBNC,
          urssafConfig: vm.urssafConfig,
          bilanTva: vm.bilanTva,
          vlVsIrSimulation: vm.vlVsIrSimulation,
          cotisationBreakdown: vm.cotisationBreakdown,
          totalCotisations: vm.totalCotisations,
          cotisationRepartition: vm.cotisationRepartition,
          caEncaisse: vm.caEncaissePeriode,
          depenses: vm.depensesPeriode,
          beneficeNet: vm.beneficeNetPeriode,
          tauxMarge: vm.tauxMarge,
          expenseBreakdown: vm.expenseBreakdown,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic)
        .slideY(
            begin: 0.08,
            end: 0,
            duration: 600.ms,
            delay: 300.ms,
            curve: Curves.easeOutCubic);
  }

  // -------------------------------------------------------------------
  // 4 MINI-CARDS ROW
  // -------------------------------------------------------------------

  Widget _buildMiniCardsRow(BuildContext context, DashboardViewModel vm,
      bool isDesktop, bool isTablet) {
    final cards = <Widget>[
      TopClientsCard(
        clients: vm.topClients,
        onTap: () => context.go('/app/clients'),
      ),
      FacturesRecurrentesCard(
        facturesRecurrentes: vm.facturesRecurrentes,
        onTap: () => context.go('/app/factures_recurrentes'),
      ),
      TempsNonFactureCard(
        totalMinutes: vm.totalMinutesNonFacturees,
        montantFacturable: vm.montantNonFacture,
        dureeFormatee: vm.dureeNonFactureeFormatee,
        nbEntrees: vm.tempsNonFactures.length,
        onTap: () => context.go('/app/temps'),
      ),
      RappelsCard(
        rappels: vm.prochainRappels,
        onTap: () => context.go('/app/rappels'),
      ),
    ];

    const spacing = 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        mainAxisExtent: 220,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        return cards[i]
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: (500 + 80 * i).ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 500.ms,
              delay: (500 + 80 * i).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  // -------------------------------------------------------------------
  // EXPENSE MINI CARD � pie chart compact dans un glass container
  // -------------------------------------------------------------------

  Widget _buildExpenseMiniCard(DashboardViewModel vm) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlassBright,
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  size: 16, color: AppTheme.primary),
              SizedBox(width: 6),
              Text(
                'R�partition D�penses',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ExpensePieChart(data: vm.expenseBreakdown),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // HEADER
  // -------------------------------------------------------------------

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
                color: AppTheme.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 12),
            const WeatherWidget(),
          ],
        ),
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
              _buildPeriodTab(context, vm, DashboardPeriod.annee, "Ann�e"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodTab(BuildContext context, DashboardViewModel vm,
      DashboardPeriod period, String label) {
    final isSelected = vm.selectedPeriod == period;
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
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
        ));
  }
}
