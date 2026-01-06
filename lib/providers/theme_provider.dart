import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class ThemeProvider with ChangeNotifier {
  final SettingsRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository() {
    loadTheme();
  }

  void loadTheme() async {
    final isDark = await _repository.getIsDarkMode();
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _repository.setIsDarkMode(isDark);
  }
}
