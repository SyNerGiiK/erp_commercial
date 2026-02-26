import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

/// Overlay animé de succès — remplace les SnackBars pour les actions critiques.
///
/// Affiche un cercle pulsant avec une coche animée, un titre et un sous-titre,
/// puis se ferme automatiquement et appelle [onDismissed].
///
/// Usage :
/// ```dart
/// SuccessOverlay.show(
///   context: context,
///   title: 'Facture validée !',
///   subtitle: 'La facture a été finalisée avec succès.',
///   onDismissed: () => context.go('/app/factures'),
/// );
/// ```
class SuccessOverlay {
  SuccessOverlay._();

  /// Affiche l'overlay dans un [OverlayEntry] au-dessus de tout le contenu.
  ///
  /// [duration] contrôle la durée totale d'affichage (défaut 2s).
  /// [onDismissed] est appelé après la fermeture de l'overlay.
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    Duration duration = const Duration(milliseconds: 2000),
    VoidCallback? onDismissed,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _SuccessOverlayWidget(
        title: title,
        subtitle: subtitle,
        duration: duration,
        onDismissed: () {
          entry.remove();
          onDismissed?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _SuccessOverlayWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Duration duration;
  final VoidCallback onDismissed;

  const _SuccessOverlayWidget({
    required this.title,
    this.subtitle,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_SuccessOverlayWidget> createState() => _SuccessOverlayWidgetState();
}

class _SuccessOverlayWidgetState extends State<_SuccessOverlayWidget> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _autoDismissTimer = Timer(widget.duration, () {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onDismissed,
        child: Container(
          color: Colors.black.withValues(alpha: 0.0),
          alignment: Alignment.center,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      margin: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.shadowLarge,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cercle avec coche animée
          _buildCheckCircle(),
          const SizedBox(height: 24),
          // Titre
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 550.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, duration: 400.ms),
          ],
        ],
      ),
    )
        .animate()
        .scaleXY(
            begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildCheckCircle() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.accent,
            AppTheme.accent.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 44,
      ),
    )
        .animate()
        .scaleXY(
          begin: 0.0,
          end: 1.0,
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          delay: 200.ms,
          duration: 800.ms,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }
}
