import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALETTE DE COULEURS (Paper UI - Artisan 3.0) ---
  static const Color primary = Color(0xFF1E5572); // Bleu Pétrole Profond
  static const Color primaryLight = Color(0xFF4A809E);
  static const Color primarySoft = Color(0xFFE8F0F5); // Fond bleu très léger
  static const Color secondary = Color(0xFF2A769E); // Bleu Acier
  static const Color accent = Color(0xFF5AB646); // Vert Validation
  static const Color accentSoft = Color(0xFFE8F8E4); // Fond vert très léger
  static const Color error = Color(0xFFE74C3C); // Rouge Erreur
  static const Color errorSoft = Color(0xFFFDE8E6); // Fond rouge très léger
  static const Color warning = Color(0xFFF39C12); // Orange Attention
  static const Color warningSoft = Color(0xFFFFF3E0); // Fond orange très léger
  static const Color info = Color(0xFF3498DB); // Bleu Info
  static const Color infoSoft = Color(0xFFE3F2FD); // Fond bleu info léger
  static const Color background = Color(0xFFF5F7FA); // Gris Papier
  static const Color surface = Colors.white; // Surface Cartes
  static const Color surfaceVariant = Color(0xFFF8FAFB); // Surface alternative

  static const Color textDark = Color(0xFF2C3E50); // Encre
  static const Color textMedium = Color(0xFF546E7A); // Texte intermédiaire
  static const Color textLight = Color(0xFF7F8C8D); // Texte secondaire
  static const Color textGrey = Color(0xFF7F8C8D); // Alias
  static const Color divider = Color(0xFFE0E0E0); // Séparateur

  // --- SPACING (Grille de 4px) ---
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // --- BORDER RADIUS ---
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusCircular = 50;

  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);

  // --- OMBRES ---
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // --- DÉGRADÉS ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- THEME DATA ---
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.robotoTextTheme();
    final titleSection = GoogleFonts.montserrat(fontWeight: FontWeight.bold);

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

      // Text Theme
      textTheme: baseTextTheme.copyWith(
        displayLarge: titleSection.copyWith(fontSize: 32, color: textDark),
        displayMedium: titleSection.copyWith(fontSize: 28, color: textDark),
        displaySmall: titleSection.copyWith(fontSize: 24, color: textDark),
        headlineMedium: titleSection.copyWith(fontSize: 20, color: textDark),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textDark),
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        clipBehavior: Clip.antiAlias,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: titleSection.copyWith(fontSize: 20, color: primary),
      ),

      // Divider (Compatibilité 3.27)
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        prefixIconColor: primary,
      ),

      // Transitions de pages
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: NoTransitionsBuilder(),
          TargetPlatform.windows: NoTransitionsBuilder(),
          TargetPlatform.linux: NoTransitionsBuilder(),
        },
      ),
    );
  }

  // --- HELPERS STATUT ---

  /// Retourne une couleur selon le statut d'un document (facture / devis)
  static Color statusColor(String statut) {
    switch (statut) {
      case 'brouillon':
        return textLight;
      case 'envoye':
      case 'envoyee':
        return info;
      case 'validee':
        return secondary;
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

  /// Retourne la couleur de fond douce associée au statut
  static Color statusBackgroundColor(String statut) {
    switch (statut) {
      case 'brouillon':
        return const Color(0xFFF5F5F5);
      case 'envoye':
      case 'envoyee':
        return infoSoft;
      case 'validee':
        return primarySoft;
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
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}

/// Badge de statut réutilisable
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Header de section avec trait décoratif
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
          bottom: AppTheme.spacing12, top: AppTheme.spacing4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: AppTheme.spacing8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
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
