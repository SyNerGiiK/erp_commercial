import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';

/// Card compacte pour les statistiques pipeline devis.
class DevisPipelineCard extends StatelessWidget {
  final Decimal tauxConversion;
  final int devisEnCours;
  final Decimal montantPipeline;
  final int totalDevisYear;

  const DevisPipelineCard({
    super.key,
    required this.tauxConversion,
    required this.devisEnCours,
    required this.montantPipeline,
    required this.totalDevisYear,
  });

  @override
  Widget build(BuildContext context) {
    if (totalDevisYear == 0) return const SizedBox.shrink();

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Text(
                  'Pipeline Devis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalDevisYear cette année',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Stats en row
          Row(
            children: [
              _buildStat(
                label: 'Conversion',
                value: '${tauxConversion.toDouble().toStringAsFixed(1)}%',
                color: tauxConversion.toDouble() >= 50
                    ? AppTheme.accent
                    : tauxConversion.toDouble() >= 25
                        ? AppTheme.warning
                        : AppTheme.error,
              ),
              const SizedBox(width: AppTheme.spacing16),
              _buildStat(
                label: 'En cours',
                value: '$devisEnCours',
                color: AppTheme.info,
              ),
              const SizedBox(width: AppTheme.spacing16),
              _buildStat(
                label: 'Pipeline',
                value: '${montantPipeline.toDouble().toStringAsFixed(0)} €',
                color: AppTheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing8, horizontal: AppTheme.spacing8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
