import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme Provider
///
/// Manages application theme mode (light, dark, system) with persistence.
/// Theme preference is saved to Hive and restored on app launch.
///
/// Supported modes:
/// - Light: Always use light theme
/// - Dark: Always use dark theme
/// - System: Follow device system settings (default)
class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'app_preferences';
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  Box? _preferencesBox;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load theme preference from Hive
  Future<void> _loadThemePreference() async {
    try {
      _preferencesBox = await Hive.openBox(_boxName);
      final savedTheme = _preferencesBox?.get(_themeKey);

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await _preferencesBox?.put(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Get display name for theme mode
  String getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Check if a theme mode is currently active
  bool isThemeModeActive(ThemeMode mode) {
    return _themeMode == mode;
  }
}
