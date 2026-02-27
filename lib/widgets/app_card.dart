import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Carte Aurora 2030 — surface glass avec ombre colorée
/// et barre de statut latérale avec micro-glow.
class AppCard extends StatelessWidget {
  // Mode "Custom Content"
  final Widget? child;

  // Mode "ListTile"
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? statusColor; // Barre de couleur latérale optionnelle
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.statusColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlassBright,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child ?? _buildListTileContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildListTileContent() {
    return Row(
      children: [
        // Barre de statut optionnelle — avec micro-glow
        if (statusColor != null) ...[
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: statusColor!.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],

        // Leading (Icône ou Avatar)
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 16),
        ],

        // Contenu central
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textDark,
                    letterSpacing: -0.2,
                  ),
                  child: title!,
                ),
              if (title != null && subtitle != null) const SizedBox(height: 4),
              if (subtitle != null)
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                  child: subtitle!,
                ),
            ],
          ),
        ),

        // Trailing (Montant ou Action)
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}
