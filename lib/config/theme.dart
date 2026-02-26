import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// +-----------------------------------------------------------------------+
// �     A R T I S A N   F O R G E   2 0 3 0   D E S I G N   S Y S T E M �
// �                                                                       �
// �   Dark Forge � Fire � Gold � Indigo Tech � Glassmorphism Dark        �
// �   Light Forge � Warm Stone � Fire accents � Glass Light              �
// +-----------------------------------------------------------------------+

class AppTheme {
  // -------------------------------------------------------
  //  PALETTE CHROMATIQUE FORGE � COULEURS DE MARQUE
  //  (identiques en light ET dark)
  // -------------------------------------------------------

  /// Ambre Feu � �nergie artisan, action, CTA
  static const Color primary = Color(0xFFF97316);
  static const Color primaryLight = Color(0xFFFB923C);
  static const Color primaryDark = Color(0xFFEA580C);
  static const Color primarySoft = Color(0x1AF97316); // 10% opacity

  /// Or � premium, succ�s secondaire
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFCD34D);

  /// Indigo Tech � �l�ments IA, badges tech
  static const Color accentTech = Color(0xFF6366F1);
  static const Color accentTechLight = Color(0xFF818CF8);

  /// �meraude Validation � succ�s, paiement, s�r�nit�
  static const Color accent = Color(0xFF10B981);
  static const Color accentSoft = Color(0x1A10B981);

  /// Cyan � highlights, accents dynamiques
  static const Color highlight = Color(0xFF06B6D4);
  static const Color highlightSoft = Color(0x1A06B6D4);

  /// Rose Vif � erreurs, attention imm�diate
  static const Color error = Color(0xFFF43F5E);
  static const Color errorSoft = Color(0x1AF43F5E);

  /// Ambre Warning (distinct du secondary)
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSoft = Color(0x1AFBBF24);

  /// Bleu Info
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0x1A3B82F6);

  // -------------------------------------------------------
  //  COULEURS ADAPTATIVES (changent selon le mode)
  // -------------------------------------------------------

  // -- DARK MODE (Forge) --
  static const Color _darkBackground = Color(0xFF0F0D0B);
  static const Color _darkSurface = Color(0xFF1C1917);
  static const Color _darkSurfaceVariant = Color(0xFF292524);
  static const Color _darkTextPrimary = Color(0xFFFAFAF9);
  static const Color _darkTextMedium = Color(0xFFD6D3D1);
  static const Color _darkTextLight = Color(0xFFA8A29E);
  static const Color _darkTextGrey = Color(0xFF78716C);
  static const Color _darkDivider = Color(0x1FF97316); // fire 12%
  static const Color _darkBorderGlass = Color(0x26F97316); // fire 15%

  // -- LIGHT MODE (Forge Light) --
  static const Color _lightBackground = Color(0xFFFAF9F7);
  static const Color _lightSurface = Colors.white;
  static const Color _lightSurfaceVariant = Color(0xFFF5F3F0);
  static const Color _lightTextPrimary = Color(0xFF1C1917);
  static const Color _lightTextMedium = Color(0xFF57534E);
  static const Color _lightTextLight = Color(0xFFA8A29E);
  static const Color _lightTextGrey = Color(0xFF78716C);
  static const Color _lightDivider = Color(0x1FF97316); // fire 12%
  static const Color _lightBorderGlass = Color(0x1AF97316); // fire 10%

  // -------------------------------------------------------
  //  ACCESSEURS ADAPTATIFS
  //  ? Utilisent _brightness pour r�soudre la bonne couleur
  // -------------------------------------------------------

  static Brightness _brightness = Brightness.dark;

  /// Appel� par ThemeNotifier quand le mode change.
  static void setBrightness(Brightness b) => _brightness = b;
  static bool get isDark => _brightness == Brightness.dark;

  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get surface => isDark ? _darkSurface : _lightSurface;
  static Color get surfaceVariant =>
      isDark ? _darkSurfaceVariant : _lightSurfaceVariant;

  // Texte
  static Color get textDark => isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textPrimary => textDark;
  static Color get textMedium => isDark ? _darkTextMedium : _lightTextMedium;
  static Color get textLight => isDark ? _darkTextLight : _lightTextLight;
  static Color get textSecondary => textLight;
  static Color get textGrey => isDark ? _darkTextGrey : _lightTextGrey;

  // Dividers / Borders
  static Color get divider => isDark ? _darkDivider : _lightDivider;
  static Color get border => divider;
  static Color get borderGlass => isDark ? _darkBorderGlass : _lightBorderGlass;

  // Glass surfaces
  static Color get surfaceGlass => isDark
      ? const Color(0xFF1C1917).withValues(alpha: 0.80)
      : Colors.white.withValues(alpha: 0.72);
  static Color get surfaceGlassBright => isDark
      ? const Color(0xFF1C1917).withValues(alpha: 0.90)
      : Colors.white.withValues(alpha: 0.85);
  static Color get surfaceGlassSubtle => isDark
      ? const Color(0xFF1C1917).withValues(alpha: 0.60)
      : Colors.white.withValues(alpha: 0.50);
  static Color get surfaceGlassLight => surfaceGlassBright;

  // -------------------------------------------------------
  //  SPACING (Grille harmonique 4px)
  // -------------------------------------------------------

  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // -------------------------------------------------------
  //  BORDER RADIUS (G�n�reux, organique)
  // -------------------------------------------------------

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

  // -------------------------------------------------------
  //  OMBRES (adaptatives dark/light)
  // -------------------------------------------------------

  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.30)
              : primary.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.50)
              : primary.withValues(alpha: 0.12),
          blurRadius: 36,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];

  /// Glow fire � effet de lueur ambre premium
  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.25 : 0.18),
          blurRadius: 48,
          offset: const Offset(0, 8),
          spreadRadius: -8,
        ),
      ];

  /// Glow fire pour cartes en hover
  static List<BoxShadow> get shadowFireHover => [
        BoxShadow(
          color: primary.withValues(alpha: 0.40),
          blurRadius: 40,
          offset: const Offset(0, 0),
        ),
      ];

  // -------------------------------------------------------
  //  D�GRAD�S FORGE
  // -------------------------------------------------------

  /// Fire ? Gold � gradient signature CraftOS
  static const LinearGradient forgeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Alias pour compatibilit�
  static const LinearGradient primaryGradient = forgeGradient;

  /// Indigo ? Violet � gradient �l�ments IA/tech
  static const LinearGradient techGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan ? �meraude � gradient �nergie
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Surface douce (dark/light adaptatif)
  static LinearGradient get surfaceGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF0F0D0B), Color(0xFF1C1917)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFFAF9F7), Color(0xFFF5F3F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  /// Maille ambiante Forge � fond avec reflets fire subtils
  static LinearGradient get auroraGradient => isDark
      ? const LinearGradient(
          colors: [
            Color(0xFF0F0D0B),
            Color(0xFF1A1412),
            Color(0xFF0F0D0B),
            Color(0xFF11100E),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [
            Color(0xFFFAF9F7),
            Color(0xFFFFF7ED),
            Color(0xFFFAF9F7),
            Color(0xFFFEF3C7),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // -------------------------------------------------------
  //  GLASS DECORATIONS (r�utilisables)
  // -------------------------------------------------------

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceGlassBright,
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(
          color: borderGlass,
          width: 1,
        ),
        boxShadow: shadowMedium,
      );

  static BoxDecoration get glassDecorationSubtle => BoxDecoration(
        color: surfaceGlassSubtle,
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(
          color: borderGlass.withValues(alpha: isDark ? 0.10 : 0.4),
          width: 0.5,
        ),
      );

  // -------------------------------------------------------
  //  THEME DATA � FORGE DARK
  // -------------------------------------------------------

  static ThemeData get darkTheme {
    final bodyTextTheme =
        GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final titleFont = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: _darkSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
      ),
      scaffoldBackgroundColor: _darkBackground,

      // Typographie Cin�matique
      textTheme: bodyTextTheme.copyWith(
        displayLarge: titleFont.copyWith(
            fontSize: 34,
            color: _darkTextPrimary,
            letterSpacing: -0.5,
            height: 1.2),
        displayMedium: titleFont.copyWith(
            fontSize: 28,
            color: _darkTextPrimary,
            letterSpacing: -0.3,
            height: 1.2),
        displaySmall: titleFont.copyWith(
            fontSize: 24,
            color: _darkTextPrimary,
            letterSpacing: -0.2,
            height: 1.3),
        headlineMedium: titleFont.copyWith(
            fontSize: 20, color: _darkTextPrimary, height: 1.3),
        bodyLarge: bodyTextTheme.bodyLarge
            ?.copyWith(color: _darkTextPrimary, height: 1.6),
        bodyMedium: bodyTextTheme.bodyMedium
            ?.copyWith(color: _darkTextPrimary, height: 1.5),
      ),

      // App Bar � Transparente dark
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _darkTextPrimary),
        titleTextStyle: titleFont.copyWith(
          color: _darkTextPrimary,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),

      // Boutons � Feu/Or, z�ro elevation
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
          foregroundColor: primaryLight,
          side: BorderSide(color: primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // Cartes � Dark glass, z�ro elevation
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: primary.withValues(alpha: 0.12), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // Dialogues
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge)),
        titleTextStyle:
            titleFont.copyWith(fontSize: 20, color: _darkTextPrimary),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 1,
      ),

      // Inputs � Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: _darkDivider.withValues(alpha: 0.5)),
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
        hintStyle: const TextStyle(color: _darkTextGrey),
        labelStyle: const TextStyle(color: _darkTextLight),
      ),

      // Transitions de pages
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: _ForgeFadeTransitionBuilder(),
          TargetPlatform.windows: _ForgeFadeTransitionBuilder(),
          TargetPlatform.linux: _ForgeFadeTransitionBuilder(),
        },
      ),

      // FAB
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
        unselectedLabelColor: _darkTextLight,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium)),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _darkSurfaceVariant,
          borderRadius: BorderRadius.circular(radiusSmall),
          border: Border.all(color: _darkDivider),
        ),
        textStyle: const TextStyle(
            color: _darkTextPrimary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // -------------------------------------------------------
  //  THEME DATA � FORGE LIGHT
  // -------------------------------------------------------

  static ThemeData get lightTheme {
    final bodyTextTheme = GoogleFonts.interTextTheme();
    final titleFont = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: _lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
      ),
      scaffoldBackgroundColor: _lightBackground,
      textTheme: bodyTextTheme.copyWith(
        displayLarge: titleFont.copyWith(
            fontSize: 34,
            color: _lightTextPrimary,
            letterSpacing: -0.5,
            height: 1.2),
        displayMedium: titleFont.copyWith(
            fontSize: 28,
            color: _lightTextPrimary,
            letterSpacing: -0.3,
            height: 1.2),
        displaySmall: titleFont.copyWith(
            fontSize: 24,
            color: _lightTextPrimary,
            letterSpacing: -0.2,
            height: 1.3),
        headlineMedium: titleFont.copyWith(
            fontSize: 20, color: _lightTextPrimary, height: 1.3),
        bodyLarge: bodyTextTheme.bodyLarge
            ?.copyWith(color: _lightTextPrimary, height: 1.6),
        bodyMedium: bodyTextTheme.bodyMedium
            ?.copyWith(color: _lightTextPrimary, height: 1.5),
      ),
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
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: primary.withValues(alpha: 0.08), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge)),
        titleTextStyle:
            titleFont.copyWith(fontSize: 20, color: _lightTextPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: _lightDivider.withValues(alpha: 0.5)),
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
        hintStyle: const TextStyle(color: _lightTextLight),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: _ForgeFadeTransitionBuilder(),
          TargetPlatform.windows: _ForgeFadeTransitionBuilder(),
          TargetPlatform.linux: _ForgeFadeTransitionBuilder(),
        },
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        hoverElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primarySoft,
        labelStyle:
            const TextStyle(color: primary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall)),
        side: BorderSide.none,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: _lightTextLight,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _lightTextPrimary.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // -------------------------------------------------------
  //  HELPERS STATUT
  // -------------------------------------------------------

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
        return textGrey;
      default:
        return textLight;
    }
  }

  /// Couleur de fond douce associ�e au statut
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

/// Badge de statut Forge � pilule lumineuse avec micro-glow
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

/// Header de section Forge � trait lumineux fire + typographie cin�matique
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
          // Trait lumineux avec gradient fire
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppTheme.forgeGradient,
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
              style: TextStyle(
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

/// Transition fade douce pour Desktop/Web
class _ForgeFadeTransitionBuilder extends PageTransitionsBuilder {
  const _ForgeFadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}

/// Compat alias � l'ancien nom
typedef NoTransitionsBuilder = _ForgeFadeTransitionBuilder;
