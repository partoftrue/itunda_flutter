import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useVibration = true;

  // Get current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Get vibration setting
  bool get useVibration => _useVibration;

  // Check if current effective theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadSettings();
  }

  // Load theme settings from shared preferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    final vibration = prefs.getBool('use_vibration') ?? true;
    
    switch (themeModeString) {
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
    
    _useVibration = vibration;
    notifyListeners();
  }

  // Set theme mode and save to shared preferences
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    String modeString;
    
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        modeString = 'system';
        break;
    }
    
    await prefs.setString('theme_mode', modeString);
    notifyListeners();
  }

  // Toggle vibration setting
  void toggleVibration() async {
    _useVibration = !_useVibration;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_vibration', _useVibration);
    notifyListeners();
  }
} 