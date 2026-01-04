import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository;

  bool _biometricsEnabled = false;
  bool _notificationsEnabled = true;
  Locale _locale = const Locale('en');

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository() {
    _loadSettings();
  }

  bool get biometricsEnabled => _biometricsEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;

  Future<void> _loadSettings() async {
    _biometricsEnabled = await _repository.getBiometricsEnabled();
    _notificationsEnabled = await _repository.getNotificationsEnabled();
    final localeCode = await _repository.getLocale();
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    notifyListeners();
    await _repository.setBiometricsEnabled(value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _repository.setNotificationsEnabled(value);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _repository.setLocale(locale.languageCode);
  }
}
