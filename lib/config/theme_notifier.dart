import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier pour le toggle thème Light / Dark (Forge).
/// Persiste le choix de l'utilisateur via SharedPreferences.
class ThemeNotifier extends ChangeNotifier {
  static const _key = 'craftos_theme_mode';

  ThemeMode _themeMode = ThemeMode.dark; // Forge Dark par défaut
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  /// Bascule entre dark et light.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveToPrefs();
    notifyListeners();
  }

  /// Force un mode spécifique.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      if (stored == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
      notifyListeners();
    } catch (_) {
      // Silently default to dark
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}
