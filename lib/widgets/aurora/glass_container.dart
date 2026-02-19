import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Conteneur en verre dépoli Aurora — surface semi-translucide
/// avec flou optionnel, bordure lumineuse et ombre colorée.
///
/// Pour des raisons de performance (Flutter Web), le [BackdropFilter]
/// n'est activé que si [enableBlur] est true.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool enableBlur;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.enableBlur = false,
    this.blurSigma = 12,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.surfaceGlassBright;
    final border = borderColor ?? Colors.white.withValues(alpha: 0.7);
    final shadow = boxShadow ?? AppTheme.shadowMedium;

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: enableBlur ? bg.withValues(alpha: 0.6) : bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: shadow,
      ),
      child: child,
    );

    if (!enableBlur) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}
