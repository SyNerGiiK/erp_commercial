import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

/// Squelette de chargement avec effet shimmer Forge.
/// Remplace les CircularProgressIndicator par des placeholders animes.
class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  /// Ligne de texte shimmer
  factory ShimmerSkeleton.line({double width = 200, double height = 14}) {
    return ShimmerSkeleton(width: width, height: height, borderRadius: 6);
  }

  /// Carte shimmer (grande zone)
  factory ShimmerSkeleton.card({double height = 120}) {
    return ShimmerSkeleton(
      height: height,
      borderRadius: AppTheme.radiusLarge,
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  /// Cercle shimmer (avatar)
  factory ShimmerSkeleton.circle({double size = 48}) {
    return ShimmerSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
        AppTheme.isDark ? const Color(0xFF292524) : const Color(0xFFE7E5E4);
    final highlightColor =
        AppTheme.isDark ? const Color(0xFF44403C) : const Color(0xFFF5F5F4);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Groupe de lignes shimmer pour simuler du texte
class ShimmerTextBlock extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const ShimmerTextBlock({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: ShimmerSkeleton(
            height: lineHeight,
            width: isLast ? 120 : double.infinity,
          ),
        );
      }),
    );
  }
}
