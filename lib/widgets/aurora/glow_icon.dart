import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Icône avec halo lumineux — donne une sensation de "vivant"
/// aux icônes de navigation et d'action.
class GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? glowColor;
  final double glowRadius;
  final bool isActive;

  const GlowIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.color,
    this.glowColor,
    this.glowRadius = 12,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ?? (isActive ? AppTheme.primary : AppTheme.textLight);
    final glow = glowColor ?? iconColor;

    return Container(
      decoration: isActive
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.25),
                  blurRadius: glowRadius,
                  spreadRadius: -2,
                ),
              ],
            )
          : null,
      child: Icon(icon, size: size, color: iconColor),
    );
  }
}
