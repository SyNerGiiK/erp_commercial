import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ╔═══════════════════════════════════════════════════════════════════════╗
// ║          A U R O R A   2 0 3 0   D E S I G N   S Y S T E M         ║
// ║                                                                       ║
// ║   Spatial Serenity — Glassmorphism · Colored Shadows · Living UI     ║
// ╚═══════════════════════════════════════════════════════════════════════╝

class AppTheme {
  // ═══════════════════════════════════════════════════════
  //  PALETTE CHROMATIQUE AURORA
  // ═══════════════════════════════════════════════════════

  /// Indigo Électrique — confiance technologique, profondeur
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primarySoft = Color(0xFFEEF2FF);

  /// Violet Cosmique — créativité, premium
  static const Color secondary = Color(0xFF8B5CF6);

  /// Émeraude Validation — succès, paiement, sérénité
  static const Color accent = Color(0xFF10B981);
  static const Color accentSoft = Color(0xFFECFDF5);

  /// Cyan Énergie — highlights, accents dynamiques
  static const Color highlight = Color(0xFF06B6D4);
  static const Color highlightSoft = Color(0xFFECFEFF);

  /// Rose Vif — erreurs, attention immédiate
  static const Color error = Color(0xFFF43F5E);
  static const Color errorSoft = Color(0xFFFFF1F2);

  /// Ambre — avertissements doux
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFFBEB);

  /// Bleu Ciel — information, neutre-positif
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFEFF6FF);

  /// Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  /// Glass — surfaces vivantes semi-translucides
  static Color get surfaceGlass => Colors.white.withValues(alpha: 0.72);
  static Color get surfaceGlassBright => Colors.white.withValues(alpha: 0.85);
  static Color get surfaceGlassSubtle => Colors.white.withValues(alpha: 0.50);

  /// Encre & Texte
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════════════════
  //  SPACING (Grille harmonique 4px)
  // ═══════════════════════════════════════════════════════

  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // ═══════════════════════════════════════════════════════
  //  BORDER RADIUS (Généreux, organique)
  // ═══════════════════════════════════════════════════════

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 20;
  static const double radiusXLarge = 28;
  static const double radiusCircular = 50;

  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);

  // ═══════════════════════════════════════════════════════
  //  OMBRES COLORÉES (Living Shadows)
  // ═══════════════════════════════════════════════════════

  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: primary.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: primary.withValues(alpha: 0.12),
          blurRadius: 36,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];

  /// Ombre à lueur (glow) pour éléments premium
  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.18),
          blurRadius: 48,
          offset: const Offset(0, 8),
          spreadRadius: -8,
        ),
      ];

  // ═══════════════════════════════════════════════════════
  //  DÉGRADÉS AURORA
  // ═══════════════════════════════════════════════════════

  /// Indigo → Violet — gradient signature
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan → Émeraude — gradient énergie
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Surface douce
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Maille ambiante Aurora — fond principal avec reflets subtils
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFEEF2FF),
      Color(0xFFF8FAFC),
      Color(0xFFECFEFF),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════
  //  GLASS DECORATIONS (réutilisables)
  // ═══════════════════════════════════════════════════════

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceGlassBright,
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: shadowMedium,
      );

  static BoxDecoration get glassDecorationSubtle => BoxDecoration(
        color: surfaceGlassSubtle,
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      );

  // ═══════════════════════════════════════════════════════
  //  THEME DATA — AURORA LIGHT
  // ═══════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    final bodyTextTheme = GoogleFonts.interTextTheme();
    final titleFont = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: background,

      // Typographie Cinématique
      textTheme: bodyTextTheme.copyWith(
        displayLarge: titleFont.copyWith(
            fontSize: 34, color: textDark, letterSpacing: -0.5, height: 1.2),
        displayMedium: titleFont.copyWith(
            fontSize: 28, color: textDark, letterSpacing: -0.3, height: 1.2),
        displaySmall: titleFont.copyWith(
            fontSize: 24, color: textDark, letterSpacing: -0.2, height: 1.3),
        headlineMedium:
            titleFont.copyWith(fontSize: 20, color: textDark, height: 1.3),
        bodyLarge:
            bodyTextTheme.bodyLarge?.copyWith(color: textDark, height: 1.6),
        bodyMedium:
            bodyTextTheme.bodyMedium?.copyWith(color: textDark, height: 1.5),
      ),

      // App Bar — Transparent pour glass overlay
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: titleFont.copyWith(
          color: Colors.white,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),

      // Boutons — Épurés, zéro elevation
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // Cartes — Glass, zéro elevation, bordure lumineuse
      cardTheme: CardThemeData(
        color: surfaceGlassBright,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side:
              BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // Dialogues — Aériens avec radius généreux
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge)),
        titleTextStyle: titleFont.copyWith(fontSize: 20, color: textDark),
      ),

      // Divider — Quasi invisible
      dividerTheme: DividerThemeData(
        color: divider.withValues(alpha: 0.4),
        thickness: 1,
      ),

      // Inputs — Glass-like
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: divider.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: error.withValues(alpha: 0.5)),
        ),
        prefixIconColor: primary,
        hintStyle: const TextStyle(color: textLight),
      ),

      // Transitions de pages
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: NoTransitionsBuilder(),
          TargetPlatform.windows: NoTransitionsBuilder(),
          TargetPlatform.linux: NoTransitionsBuilder(),
        },
      ),

      // FAB — Épuré
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        hoverElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: primarySoft,
        labelStyle:
            const TextStyle(color: primary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall)),
        side: BorderSide.none,
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textLight,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium)),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HELPERS STATUT
  // ═══════════════════════════════════════════════════════

  /// Couleur vive selon le statut d'un document
  static Color statusColor(String statut) {
    switch (statut) {
      case 'brouillon':
        return textLight;
      case 'envoye':
      case 'envoyee':
        return info;
      case 'validee':
        return highlight;
      case 'signe':
      case 'payee':
        return accent;
      case 'partielle':
        return warning;
      case 'refuse':
      case 'annule':
      case 'annulee':
        return error;
      case 'expire':
        return const Color(0xFF9E9E9E);
      default:
        return textLight;
    }
  }

  /// Couleur de fond douce associée au statut
  static Color statusBackgroundColor(String statut) {
    switch (statut) {
      case 'brouillon':
        return surfaceVariant;
      case 'envoye':
      case 'envoyee':
        return infoSoft;
      case 'validee':
        return highlightSoft;
      case 'signe':
      case 'payee':
        return accentSoft;
      case 'partielle':
        return warningSoft;
      case 'refuse':
      case 'annule':
      case 'annulee':
        return errorSoft;
      case 'expire':
        return surfaceVariant;
      default:
        return surfaceVariant;
    }
  }
}

/// Badge de statut Aurora — pilule lumineuse avec micro-glow
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final double fontSize;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.fontSize = 11,
  });

  /// Factory depuis un statut de document
  factory AppBadge.fromStatus(String statut, {String? label}) {
    return AppBadge(
      label: label ?? _statusLabel(statut),
      color: AppTheme.statusColor(statut),
      backgroundColor: AppTheme.statusBackgroundColor(statut),
    );
  }

  static String _statusLabel(String statut) {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'envoye':
      case 'envoyee':
        return 'Envoyé';
      case 'validee':
        return 'Validée';
      case 'signe':
        return 'Signé';
      case 'payee':
        return 'Payée';
      case 'partielle':
        return 'Partielle';
      case 'refuse':
        return 'Refusé';
      case 'annule':
      case 'annulee':
        return 'Annulé';
      case 'expire':
        return 'Expiré';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Header de section Aurora — trait lumineux + typographie cinématique
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: AppTheme.spacing16, top: AppTheme.spacing4),
      child: Row(
        children: [
          // Trait lumineux avec gradient
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: AppTheme.spacing8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Une transition instantanée pour le Web et Desktop
/// Permet une navigation "Snappy" sans effet de slide inutile
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
