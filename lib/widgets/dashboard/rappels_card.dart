import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/rappel_model.dart';

/// Mini-card dashboard listant les prochains rappels et échéances.
class RappelsCard extends StatelessWidget {
  final List<Rappel> rappels;
  final VoidCallback? onTap;

  const RappelsCard({
    super.key,
    required this.rappels,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = rappels.take(5).toList();
    final enRetard = rappels.where((r) => r.estEnRetard).length;

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
                    color: (enRetard > 0 ? AppTheme.error : AppTheme.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: enRetard > 0 ? AppTheme.error : AppTheme.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                const Expanded(
                  child: Text(
                    'Échéances',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                if (enRetard > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$enRetard en retard',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),

            if (display.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucune échéance prochaine',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              )
            else
              ...display.map((r) => _buildItem(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Rappel rappel) {
    final isRetard = rappel.estEnRetard;
    final isProche = rappel.estProche;
    final color = isRetard
        ? AppTheme.error
        : isProche
            ? AppTheme.warning
            : AppTheme.textMedium;

    final joursText = rappel.joursRestants == 0
        ? "Aujourd'hui"
        : rappel.joursRestants < 0
            ? 'J${rappel.joursRestants}'
            : 'J+${rappel.joursRestants}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icône type
          Text(rappel.typeRappel.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rappel.titre,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isRetard ? AppTheme.error : AppTheme.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              joursText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildPriorityDot(rappel.priorite),
        ],
      ),
    );
  }

  Widget _buildPriorityDot(PrioriteRappel priorite) {
    final color = switch (priorite) {
      PrioriteRappel.urgente => AppTheme.error,
      PrioriteRappel.haute => AppTheme.warning,
      PrioriteRappel.normale => AppTheme.primary,
      PrioriteRappel.basse => AppTheme.textLight,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
