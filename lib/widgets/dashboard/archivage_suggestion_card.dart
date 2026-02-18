import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/facture_model.dart';

/// Carte dashboard affichée quand des factures sont archivables.
///
/// Propose à l'utilisateur d'archiver en lot les factures soldées
/// depuis plus d'un an.
class ArchivageSuggestionCard extends StatelessWidget {
  final List<Facture> facturesArchivables;
  final VoidCallback? onArchiver;
  final VoidCallback? onDismiss;

  const ArchivageSuggestionCard({
    super.key,
    required this.facturesArchivables,
    this.onArchiver,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (facturesArchivables.isEmpty) return const SizedBox.shrink();

    final count = facturesArchivables.length;
    final label = count == 1
        ? '1 facture soldée depuis plus d\'un an'
        : '$count factures soldées depuis plus d\'un an';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.borderRadiusMedium,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.shade700.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              Icons.archive_outlined,
              color: Colors.orange.shade800,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Archivage suggéré',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Ignorer',
              splashRadius: 18,
              color: AppTheme.textLight,
            ),
          const SizedBox(width: AppTheme.spacing4),
          FilledButton.icon(
            onPressed: onArchiver,
            icon: const Icon(Icons.archive_rounded, size: 18),
            label: Text(count == 1 ? 'Archiver' : 'Tout archiver'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
