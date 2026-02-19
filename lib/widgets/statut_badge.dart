import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Badge de statut Aurora 2030 — pilule glass avec icône et micro-glow.
class StatutBadge extends StatelessWidget {
  final String statut;
  final DateTime? dateEcheance;
  final bool isSmall;

  const StatutBadge({
    super.key,
    required this.statut,
    this.dateEcheance,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    final s = statut.toLowerCase();

    if (s == 'brouillon') {
      color = AppTheme.textLight;
      label = "Brouillon";
      icon = Icons.edit_note_rounded;
    } else if (s == 'payee') {
      color = AppTheme.accent;
      label = "Payée";
      icon = Icons.check_circle_rounded;
    } else if (s == 'envoye' ||
        s == 'envoyee' ||
        s == 'validee' ||
        s == 'en_attente') {
      color = AppTheme.info;
      label = "Envoyé";
      icon = Icons.send_rounded;
    } else if (s == 'signe' || s == 'transforme') {
      color = AppTheme.accent;
      label = "Signé";
      icon = Icons.thumb_up_rounded;
    } else if (s == 'refuse') {
      color = AppTheme.error;
      label = "Refusé";
      icon = Icons.block_rounded;
    } else if (s == 'expire') {
      color = AppTheme.warning;
      label = "Expiré";
      icon = Icons.timer_off_rounded;
    } else if (s == 'annule' || s == 'annulee') {
      color = const Color(0xFF64748B);
      label = "Annulé";
      icon = Icons.cancel_rounded;
    } else {
      color = AppTheme.textLight;
      label = s.toUpperCase();
      icon = Icons.info_rounded;
    }

    if (isSmall) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 6,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
