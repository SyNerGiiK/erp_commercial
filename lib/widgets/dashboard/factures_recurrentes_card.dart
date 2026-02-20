import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/facture_recurrente_model.dart';

/// Mini-card dashboard listant les prochaines factures récurrentes.
class FacturesRecurrentesCard extends StatelessWidget {
  final List<FactureRecurrente> facturesRecurrentes;
  final VoidCallback? onTap;

  const FacturesRecurrentesCard({
    super.key,
    required this.facturesRecurrentes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actives =
        facturesRecurrentes.where((f) => f.estActive).take(4).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    color: AppTheme.highlight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.autorenew_rounded,
                      color: AppTheme.highlight, size: 18),
                ),
                const SizedBox(width: AppTheme.spacing8),
                const Expanded(
                  child: Text(
                    'Récurrentes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.highlight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${facturesRecurrentes.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.highlight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Liste des prochaines émissions
            if (actives.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucune facture récurrente',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              )
            else
              ...actives.map((fr) => _buildItem(fr)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(FactureRecurrente fr) {
    final dateStr = DateFormat('dd/MM').format(fr.prochaineEmission);
    final now = DateTime.now();
    final daysUntil = fr.prochaineEmission.difference(now).inDays;
    final isUrgent = daysUntil <= 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppTheme.warning.withValues(alpha: 0.1)
                  : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isUrgent ? AppTheme.warning : AppTheme.textMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fr.objet,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fr.frequence.label,
                  style:
                      const TextStyle(fontSize: 10, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          Text(
            '${fr.totalTtc.toDouble().toStringAsFixed(0)} €',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
