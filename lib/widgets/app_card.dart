import 'package:flutter/material.dart';
import '../config/theme.dart';

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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child ?? _buildListTileContent(),
        ),
      ),
    );
  }

  Widget _buildListTileContent() {
    return Row(
      children: [
        // Barre de statut optionnelle
        if (statusColor != null) ...[
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                  child: title!,
                ),
              if (title != null && subtitle != null) const SizedBox(height: 4),
              if (subtitle != null)
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
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
