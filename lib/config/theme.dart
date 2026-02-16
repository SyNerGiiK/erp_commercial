import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALETTE DE COULEURS (Paper UI - Artisan 3.0) ---
  static const Color primary = Color(0xFF1E5572); // Bleu Pétrole Profond
  static const Color primaryLight = Color(0xFF4A809E);
  static const Color secondary = Color(0xFF2A769E); // Bleu Acier
  static const Color accent = Color(0xFF5AB646); // Vert Validation
  static const Color error = Color(0xFFE74C3C); // Rouge Erreur
  static const Color warning = Color(0xFFF39C12); // Orange Attention
  static const Color background = Color(0xFFF5F7FA); // Gris Papier
  static const Color surface = Colors.white; // Surface Cartes

  static const Color textDark = Color(0xFF2C3E50); // Encre
  static const Color textLight = Color(0xFF7F8C8D); // Texte secondaire
  static const Color textGrey = Color(0xFF7F8C8D); // Alias

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
