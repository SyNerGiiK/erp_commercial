// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../models/devis_model.dart';
import '../../utils/format_utils.dart';
import '../../viewmodels/rentabilite_viewmodel.dart';
import '../../widgets/base_screen.dart';

class RentabiliteDashboardView extends StatefulWidget {
  const RentabiliteDashboardView({super.key});

  @override
  State<RentabiliteDashboardView> createState() =>
      _RentabiliteDashboardViewState();
}

class _RentabiliteDashboardViewState extends State<RentabiliteDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentabiliteViewModel>().loadDevis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentabiliteViewModel>();

    return BaseScreen(
      menuIndex: 8,
      title: "Cockpit Chantier",
      child: vm.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chantiers Actifs",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: vm.devisList.isEmpty
                        ? const Center(
                            child: Text("Aucun chantier actif trouvé."))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: vm.devisList.length,
                            itemBuilder: (context, index) {
                              final devis = vm.devisList[index];
                              return _ChantierCard(
                                devis: devis,
                                onTap: () => context
                                    .push('/app/rentabilite/${devis.id}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ChantierCard extends StatelessWidget {
  final Devis devis;
  final VoidCallback onTap;

  const _ChantierCard({required this.devis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RentabiliteViewModel>();
    final avancement = vm.getAvancementForDevis(devis);
    final encaissement = vm.getTauxEncaissementForDevis(devis);
    final margeComparative = vm.getMargeNetteComparativeForDevis(devis);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGlassLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devis.objet,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "Réf. ${devis.numeroDevis}",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _KpiGauge(
                  label: 'Travaux',
                  percent: avancement,
                  color: AppTheme.warning,
                ),
                _KpiGauge(
                  label: 'Encaissement',
                  percent: encaissement,
                  color: AppTheme.primary,
                ),
                _KpiGauge(
                  label: 'Marge Nette',
                  percent: margeComparative,
                  color: AppTheme.accent,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatUtils.currency(devis.totalHt),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppTheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiGauge extends StatelessWidget {
  final String label;
  final Decimal percent;
  final Color color;

  const _KpiGauge({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent < Decimal.zero
        ? Decimal.zero
        : (percent > Decimal.fromInt(100) ? Decimal.fromInt(100) : percent);
    final value = (clamped / Decimal.fromInt(100)).toDecimal().toDouble();

    return SizedBox(
      width: 82,
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: AppTheme.border,
                ),
                Center(
                  child: Text(
                    '${clamped.toDouble().toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
