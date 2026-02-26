// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../services/urssaf_sync_service.dart';

/// Widget de comparaison Versement Libératoire vs Impôt sur le Revenu.
///
/// Affiche côte à côte les revenus nets dans les 2 scénarios
/// et recommande l'option la plus avantageuse.
class VlVsIrCard extends StatelessWidget {
  final VlVsIrSimulation simulation;

  const VlVsIrCard({super.key, required this.simulation});

  @override
  Widget build(BuildContext context) {
    final isVlBetter = simulation.vlPlusAvantageux;
    final diff = simulation.differenceAnnuelle;
    final absDiff = diff.abs();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Icon(
                    Icons.compare_arrows_rounded,
                    color: AppTheme.secondary,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulateur VL vs IR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Versement Libératoire vs Impôt classique',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.spacing20),

            // Comparaison côte à côte
            Row(
              children: [
                Expanded(
                  child: _buildScenarioColumn(
                    title: 'Avec VL',
                    revenuNet: simulation.revenuNetApresIrAvecVl,
                    tauxEffectif: simulation.tauxEffectifVl,
                    isHighlighted: isVlBetter,
                    color: AppTheme.accent,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Column(
                  children: [
                    Text('VS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textLight,
                          fontSize: 12,
                        )),
                    SizedBox(height: 4),
                    Icon(
                      Icons.swap_horiz,
                      color: AppTheme.textLight.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildScenarioColumn(
                    title: 'Sans VL (IR)',
                    revenuNet: simulation.revenuNetApresIrSansVl,
                    tauxEffectif: simulation.tauxEffectifIr,
                    isHighlighted: !isVlBetter,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.spacing16),

            // Verdict
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isVlBetter ? AppTheme.accentSoft : AppTheme.infoSoft,
                borderRadius: AppTheme.borderRadiusSmall,
                border: Border.all(
                  color: (isVlBetter ? AppTheme.accent : AppTheme.info)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: isVlBetter ? AppTheme.accent : AppTheme.info,
                  ),
                  SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: isVlBetter ? AppTheme.accent : AppTheme.info,
                        ),
                        children: [
                          TextSpan(
                            text: isVlBetter
                                ? 'Le VL est plus avantageux '
                                : 'L\'IR classique est plus avantageux ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                                '(${absDiff.toDouble().toStringAsFixed(0)} €/an)',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Note plafond
            SizedBox(height: AppTheme.spacing8),
            Text(
              'Plafond RFR : ${simulation.plafondVlRfr.toDouble().toStringAsFixed(0)} €/part '
              '• CA simulé : ${simulation.caTotal.toDouble().toStringAsFixed(0)} €',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioColumn({
    required String title,
    required Decimal revenuNet,
    required Decimal tauxEffectif,
    required bool isHighlighted,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.06)
            : AppTheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(
          color:
              isHighlighted ? color.withValues(alpha: 0.3) : Colors.transparent,
          width: isHighlighted ? 1.5 : 0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isHighlighted)
                Icon(Icons.check_circle, size: 14, color: color),
              if (isHighlighted) SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isHighlighted ? color : AppTheme.textMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            '${revenuNet.toDouble().toStringAsFixed(0)} €',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isHighlighted ? color : AppTheme.textMedium,
            ),
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            'Taux effectif ${tauxEffectif.toDouble().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
