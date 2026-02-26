import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Fond ambiant Forge 2030 — dark mesh avec orbes de feu animées (dark)
/// ou fond warm stone avec orbes ambrées subtiles (light).
///
/// Remplace l'ancien AuroraBackground light. Adaptatif via AppTheme.isDark.
class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
          ),
          child: CustomPaint(
            painter: _ForgeMeshPainter(
              progress: _controller.value,
              isDark: AppTheme.isDark,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Peint les orbes ambiantes (mesh gradient) comme sur la landing page.
class _ForgeMeshPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ForgeMeshPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _paintDarkMesh(canvas, size);
    } else {
      _paintLightMesh(canvas, size);
    }
  }

  void _paintDarkMesh(Canvas canvas, Size size) {
    // Orbe 1 — Ember (bas-gauche) — grande, chaude
    final ember = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEA580C).withValues(alpha: 0.18),
          const Color(0xFFEA580C).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.10 + 0.05 * sin(progress * pi * 2)),
            size.height * (0.90 - 0.08 * cos(progress * pi * 2)),
          ),
          radius: size.width * 0.45,
        ),
      );
    canvas.drawRect(Offset.zero & size, ember);

    // Orbe 2 — Indigo tech (haut-droite)
    final indigo = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.14),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.88 - 0.04 * cos(progress * pi * 2)),
            size.height * (0.12 + 0.06 * sin(progress * pi * 2)),
          ),
          radius: size.width * 0.38,
        ),
      );
    canvas.drawRect(Offset.zero & size, indigo);

    // Orbe 3 — Gold subtile (centre)
    final gold = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.06),
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.50 + 0.03 * sin(progress * pi * 2 + 1)),
            size.height * (0.50 + 0.04 * cos(progress * pi * 2 + 1)),
          ),
          radius: size.width * 0.30,
        ),
      );
    canvas.drawRect(Offset.zero & size, gold);
  }

  void _paintLightMesh(Canvas canvas, Size size) {
    // Orbe 1 — Ambre douce (bas-gauche)
    final amber = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.06),
          const Color(0xFFF97316).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.15 + 0.04 * sin(progress * pi * 2)),
            size.height * (0.85 - 0.06 * cos(progress * pi * 2)),
          ),
          radius: size.width * 0.40,
        ),
      );
    canvas.drawRect(Offset.zero & size, amber);

    // Orbe 2 — Indigo subtile (haut-droite)
    final indigo = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.05),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * (0.85 - 0.03 * cos(progress * pi * 2)),
            size.height * (0.15 + 0.05 * sin(progress * pi * 2)),
          ),
          radius: size.width * 0.35,
        ),
      );
    canvas.drawRect(Offset.zero & size, indigo);

    // Orbe 3 — Gold subtile (centre)
    final gold = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.03),
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * 0.50,
            size.height * 0.50,
          ),
          radius: size.width * 0.25,
        ),
      );
    canvas.drawRect(Offset.zero & size, gold);
  }

  @override
  bool shouldRepaint(_ForgeMeshPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
