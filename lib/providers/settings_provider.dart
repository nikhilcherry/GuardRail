import 'package:flutter/foundation.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository;

  bool _biometricsEnabled = false;
  bool _notificationsEnabled = true;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository() {
    _loadSettings();
  }

  bool get biometricsEnabled => _biometricsEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadSettings() async {
    _biometricsEnabled = await _repository.getBiometricsEnabled();
    _notificationsEnabled = await _repository.getNotificationsEnabled();
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
}
