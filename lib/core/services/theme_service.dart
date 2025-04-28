import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';
  static const String _colorSchemeKey = 'color_scheme';
  
  ThemeMode _themeMode = ThemeMode.system;
  ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  );
  
  ThemeService(this._prefs) {
    _loadThemeSettings();
  }

  ThemeMode get themeMode => _themeMode;
  ColorScheme get colorScheme => _colorScheme;

  Future<void> _loadThemeSettings() async {
    final themeModeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    final colorSchemeIndex = _prefs.getInt(_colorSchemeKey) ?? 0;
    _updateColorScheme(colorSchemeIndex);
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setColorScheme(int index) async {
    await _prefs.setInt(_colorSchemeKey, index);
    _updateColorScheme(index);
    notifyListeners();
  }

  void _updateColorScheme(int index) {
    final colors = [
      const Color(0xFF6750A4), // Purple
      const Color(0xFF007AFF), // Blue
      const Color(0xFF34C759), // Green
      const Color(0xFFFF9500), // Orange
      const Color(0xFFFF3B30), // Red
    ];
    
    if (index >= 0 && index < colors.length) {
      _colorScheme = ColorScheme.fromSeed(
        seedColor: colors[index],
        brightness: _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    }
  }
} 