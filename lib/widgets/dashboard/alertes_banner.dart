import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/facture_model.dart';
import '../../services/relance_service.dart';

/// Bandeau d'alertes compact fusionnant retard factures + archivage suggéré.
class AlertesBanner extends StatelessWidget {
  final List<RelanceInfo> relances;
  final List<Facture> facturesArchivables;
  final VoidCallback? onRelancesTap;
  final VoidCallback? onArchiverTap;
  final VoidCallback? onDismissArchivage;

  const AlertesBanner({
    super.key,
    this.relances = const [],
    this.facturesArchivables = const [],
    this.onRelancesTap,
    this.onArchiverTap,
    this.onDismissArchivage,
  });

  @override
  Widget build(BuildContext context) {
    final hasRetard = relances.isNotEmpty;
    final hasArchivage = facturesArchivables.isNotEmpty;

    if (!hasRetard && !hasArchivage) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasRetard
              ? [
                  AppTheme.error.withValues(alpha: 0.08),
                  AppTheme.warning.withValues(alpha: 0.06),
                ]
              : [
                  AppTheme.warning.withValues(alpha: 0.08),
                  AppTheme.warning.withValues(alpha: 0.04),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(
          color: hasRetard
              ? AppTheme.error.withValues(alpha: 0.15)
              : AppTheme.warning.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Retard
          if (hasRetard) ...[
            _buildAlertChip(
              icon: Icons.warning_amber_rounded,
              label:
                  '${relances.length} facture${relances.length > 1 ? 's' : ''} en retard',
              color: AppTheme.error,
              onTap: onRelancesTap,
            ),
          ],
          if (hasRetard && hasArchivage)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
              child: Container(
                width: 1,
                height: 24,
                color: AppTheme.divider,
              ),
            ),
          // Archivage
          if (hasArchivage) ...[
            _buildAlertChip(
              icon: Icons.archive_outlined,
              label: '${facturesArchivables.length} à archiver',
              color: AppTheme.warning,
              onTap: onArchiverTap,
            ),
            if (onDismissArchivage != null)
              IconButton(
                onPressed: onDismissArchivage,
                icon: const Icon(Icons.close, size: 16),
                splashRadius: 14,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                color: AppTheme.textLight,
              ),
          ],
          const Spacer(),
          if (hasRetard)
            TextButton.icon(
              onPressed: onRelancesTap,
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('Voir'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
