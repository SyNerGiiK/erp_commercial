import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../models/enums/entreprise_enums.dart';
import '../../models/urssaf_model.dart';
import '../../services/tva_service.dart';
import '../../services/urssaf_sync_service.dart';
import 'seuils_et_plafonds_card.dart';
import 'vl_vs_ir_card.dart';
import 'cotisation_detail_card.dart';

/// Bloc adaptatif selon le régime d'entreprise.
///
/// - Micro-entrepreneur : Plafonds + Seuils TVA + VL vs IR
/// - TNS (EI/EURL) : Cotisations détaillées + Taux de marge + Projection
/// - Assimilé salarié (SASU/SAS) : Synthèse CA/Charges + Taux de marge
class RegimeBlock extends StatelessWidget {
  final TypeEntreprise typeEntreprise;
  final bool isMicro;
  final bool isTNS;
  final bool isAssimileSalarie;

  // Données micro
  final Decimal caVente;
  final Decimal caPrestaBIC;
  final Decimal caPrestaBNC;
  final UrssafConfig? urssafConfig;
  final BilanTva? bilanTva;
  final VlVsIrSimulation? vlVsIrSimulation;

  // Données cotisations (tous régimes)
  final Map<String, Decimal> cotisationBreakdown;
  final Decimal totalCotisations;
  final Map<String, Decimal> cotisationRepartition;

  // Données financières (tous régimes)
  final Decimal caEncaisse;
  final Decimal depenses;
  final Decimal beneficeNet;
  final double tauxMarge;
  final Map<String, double> expenseBreakdown;

  RegimeBlock({
    super.key,
    required this.typeEntreprise,
    required this.isMicro,
    required this.isTNS,
    required this.isAssimileSalarie,
    Decimal? caVente,
    Decimal? caPrestaBIC,
    Decimal? caPrestaBNC,
    this.urssafConfig,
    this.bilanTva,
    this.vlVsIrSimulation,
    this.cotisationBreakdown = const {},
    Decimal? totalCotisations,
    this.cotisationRepartition = const {},
    Decimal? caEncaisse,
    Decimal? depenses,
    Decimal? beneficeNet,
    this.tauxMarge = 0.0,
    this.expenseBreakdown = const {},
  })  : caVente = caVente ?? Decimal.zero,
        caPrestaBIC = caPrestaBIC ?? Decimal.zero,
        caPrestaBNC = caPrestaBNC ?? Decimal.zero,
        totalCotisations = totalCotisations ?? Decimal.zero,
        caEncaisse = caEncaisse ?? Decimal.zero,
        depenses = depenses ?? Decimal.zero,
        beneficeNet = beneficeNet ?? Decimal.zero;

  @override
  Widget build(BuildContext context) {
    if (isMicro) {
      return _buildMicroBlock(context);
    } else if (isTNS) {
      return _buildTNSBlock(context);
    } else if (isAssimileSalarie) {
      return _buildAssimileSalarieBlock(context);
    }
    return _buildDefaultBlock(context);
  }

  // ─── MICRO-ENTREPRENEUR ────────────────────────────────────
  Widget _buildMicroBlock(BuildContext context) {
    return Column(
      children: [
        SeuilsEtPlafondsCard(
          type: typeEntreprise,
          caVente: caVente,
          caService: caPrestaBIC + caPrestaBNC,
          config: urssafConfig,
          bilanTva: bilanTva,
        ),
        if (vlVsIrSimulation != null) ...[
          const SizedBox(height: AppTheme.spacing16),
          VlVsIrCard(simulation: vlVsIrSimulation!),
        ],
        if (cotisationBreakdown.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacing16),
          CotisationDetailCard(
            breakdown: cotisationBreakdown,
            total: totalCotisations,
            repartition: cotisationRepartition,
          ),
        ],
      ],
    );
  }

  // ─── TNS (EI / EURL) ──────────────────────────────────────
  Widget _buildTNSBlock(BuildContext context) {
    return Column(
      children: [
        SeuilsEtPlafondsCard(
          type: typeEntreprise,
          caVente: caVente,
          caService: caPrestaBIC + caPrestaBNC,
          bilanTva: bilanTva,
        ),
        if (bilanTva != null) const SizedBox(height: AppTheme.spacing16),

        // Cotisations TNS détaillées
        if (cotisationBreakdown.isNotEmpty)
          CotisationDetailCard(
            breakdown: cotisationBreakdown,
            total: totalCotisations,
            repartition: cotisationRepartition,
          ),
        const SizedBox(height: AppTheme.spacing16),
        // Synthèse financière TNS
        _buildFinanceSummaryCard(
          context,
          title: 'Synthèse TNS',
          subtitle: typeEntreprise.label,
          items: [
            _SummaryItem(
              'Taux de marge',
              '${tauxMarge.toStringAsFixed(1)}%',
              tauxMarge >= 30
                  ? AppTheme.accent
                  : tauxMarge >= 15
                      ? AppTheme.warning
                      : AppTheme.error,
              Icons.show_chart_rounded,
            ),
            _SummaryItem(
              'Charges estimées',
              '${totalCotisations.toDouble().toStringAsFixed(0)} €',
              AppTheme.secondary,
              Icons.account_balance_outlined,
            ),
            _SummaryItem(
              'Bénéfice net',
              '${beneficeNet.toDouble().toStringAsFixed(0)} €',
              beneficeNet > Decimal.zero ? AppTheme.accent : AppTheme.error,
              Icons.savings_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ─── ASSIMILÉ SALARIÉ (SASU / SAS) ────────────────────────
  Widget _buildAssimileSalarieBlock(BuildContext context) {
    return Column(
      children: [
        SeuilsEtPlafondsCard(
          type: typeEntreprise,
          caVente: caVente,
          caService: caPrestaBIC + caPrestaBNC,
          bilanTva: bilanTva,
        ),
        if (bilanTva != null) const SizedBox(height: AppTheme.spacing16),

        _buildFinanceSummaryCard(
          context,
          title: 'Synthèse ${typeEntreprise.label}',
          subtitle: 'Charges via fiches de paie',
          items: [
            _SummaryItem(
              'Taux de marge',
              '${tauxMarge.toStringAsFixed(1)}%',
              tauxMarge >= 30
                  ? AppTheme.accent
                  : tauxMarge >= 15
                      ? AppTheme.warning
                      : AppTheme.error,
              Icons.show_chart_rounded,
            ),
            _SummaryItem(
              'Dépenses',
              '${depenses.toDouble().toStringAsFixed(0)} €',
              AppTheme.warning,
              Icons.shopping_bag_outlined,
            ),
            _SummaryItem(
              'Résultat net',
              '${beneficeNet.toDouble().toStringAsFixed(0)} €',
              beneficeNet > Decimal.zero ? AppTheme.accent : AppTheme.error,
              Icons.savings_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        // Top catégories de dépenses
        if (expenseBreakdown.isNotEmpty) _buildExpenseMiniChart(context),
      ],
    );
  }

  // ─── DEFAULT (Autre) ───────────────────────────────────────
  Widget _buildDefaultBlock(BuildContext context) {
    return _buildFinanceSummaryCard(
      context,
      title: 'Synthèse Financière',
      subtitle: typeEntreprise.label,
      items: [
        _SummaryItem(
          'Taux de marge',
          '${tauxMarge.toStringAsFixed(1)}%',
          AppTheme.primary,
          Icons.show_chart_rounded,
        ),
        _SummaryItem(
          'Dépenses',
          '${depenses.toDouble().toStringAsFixed(0)} €',
          AppTheme.warning,
          Icons.shopping_bag_outlined,
        ),
        _SummaryItem(
          'Résultat net',
          '${beneficeNet.toDouble().toStringAsFixed(0)} €',
          beneficeNet > Decimal.zero ? AppTheme.accent : AppTheme.error,
          Icons.savings_outlined,
        ),
      ],
    );
  }

  // ─── WIDGETS INTERNES ──────────────────────────────────────

  Widget _buildFinanceSummaryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<_SummaryItem> items,
  }) {
    return Container(
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
              const Icon(Icons.analytics_outlined,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
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
          const SizedBox(height: AppTheme.spacing16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildExpenseMiniChart(BuildContext context) {
    final sorted = expenseBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();
    final total = expenseBreakdown.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.warning,
      AppTheme.highlight,
    ];

    return Container(
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
          const Text(
            'Top Dépenses',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          ...List.generate(top.length, (i) {
            final entry = top[i];
            final pct = entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMedium),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)} €',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors[i % colors.length],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade200,
                      color: colors[i % colors.length],
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem(this.label, this.value, this.color, this.icon);
}
