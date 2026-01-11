import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider do zarządzania motywem aplikacji
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _isLoaded;
  
  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  /// Ładuje zapisany motyw z pamięci
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // Ignoruj błędy - użyj domyślnego motywu
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  /// Ustawia nowy motyw
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
    } catch (e) {
      // Ignoruj błędy zapisu
    }
  }

  /// Przełącza między jasnym a ciemnym motywem
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

