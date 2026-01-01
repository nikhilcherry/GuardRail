import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      // Ensure we start with a known state if possible, but loadTheme is async
    });

    test('Initial theme mode is system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('toggleTheme(true) sets dark mode', () async {
      themeProvider.toggleTheme(true);
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.themeMode, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
    });

    test('toggleTheme(false) sets light mode', () async {
      themeProvider.toggleTheme(false);
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.themeMode, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), false);
    });

    test('loadTheme loads from preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', true);

      // Create new provider to simulate app restart
      final newProvider = ThemeProvider();
      await newProvider.loadTheme();

      expect(newProvider.isDarkMode, true);
      expect(newProvider.themeMode, ThemeMode.dark);
    });
  });
}
