import 'package:flutter/material.dart';
import '../config/theme.dart';

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
      color = Colors.grey;
      label = "Brouillon";
      icon = Icons.edit_note;
    } else if (s == 'payee') {
      color = AppTheme.accent;
      label = "Payée";
      icon = Icons.check_circle;
    } else if (s == 'envoye' ||
        s == 'envoyee' ||
        s == 'validee' ||
        s == 'en_attente') {
      color = Colors.blue;
      label = "Envoyé";
      icon = Icons.send;
    } else if (s == 'signe' || s == 'transforme') {
      color = Colors.green.shade700;
      label = "Signé";
      icon = Icons.thumb_up;
    } else if (s == 'refuse') {
      color = AppTheme.error;
      label = "Refusé";
      icon = Icons.block;
    } else if (s == 'expire') {
      color = Colors.orange;
      label = "Expiré";
      icon = Icons.timer_off;
    } else if (s == 'annule' || s == 'annulee') {
      color = Colors.black45;
      label = "Annulé";
      icon = Icons.cancel;
    } else {
      color = Colors.blueGrey;
      label = s.toUpperCase();
      icon = Icons.info;
    }

    if (isSmall) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
