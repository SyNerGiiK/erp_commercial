import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Fond ambiant Aurora — maille de gradients subtils qui donne
/// une profondeur organique à l'arrière-plan de l'application.
///
/// Utilise des [RadialGradient] superposés pour simuler un
/// "mesh gradient" léger sans dépendance externe.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
      ),
      child: Stack(
        children: [
          // Orbe Indigo — coin supérieur gauche
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.06),
                    AppTheme.primary.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Orbe Cyan — coin inférieur droit
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.highlight.withValues(alpha: 0.05),
                    AppTheme.highlight.withValues(alpha: 0.015),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Orbe Violet — centre-droit
          Positioned(
            top: 200,
            right: 100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Contenu
          child,
        ],
      ),
    );
  }
}
