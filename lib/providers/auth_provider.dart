import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  final _logger = LoggerService();
  bool _isLoggedIn = false;
  bool _isInitializing = true;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get selectedRole => _selectedRole;
  String? get userPhone => _userPhone;
  String? get userName => _userName;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    final status = await _repository.getLoginStatus();
    _isLoggedIn = status['isLoggedIn'] ?? false;
    _selectedRole = status['selectedRole'];
    _userPhone = status['userPhone'];
    _userName = status['userName'];
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _selectedRole = prefs.getString('selectedRole');
    _userPhone = prefs.getString('userPhone');
    _userName = prefs.getString('userName');
    _isInitializing = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _selectedRole = prefs.getString('selectedRole');
      _userPhone = prefs.getString('userPhone');
      _userName = prefs.getString('userName');
      _logger.info('Login status checked. LoggedIn: $_isLoggedIn, Role: $_selectedRole');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Error checking login status', e, stackTrace);
    }
  }

  // Login with phone and OTP
  Future<void> loginWithPhoneAndOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      await _repository.loginWithPhoneAndOTP(phone, otp);
      _logger.info('Attempting login with phone: $phone');
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;
      _userPhone = phone;

      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
        phone: phone,
      );

      _logger.info('Login successful for phone: $phone');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Login failed for phone: $phone', e, stackTrace);
      rethrow;
    }
  }

  // Login with email
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _repository.loginWithEmail(email, password);
      _logger.info('Attempting login with email: $email');
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;

      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
      );

      _logger.info('Login successful for email: $email');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Login failed for email: $email', e, stackTrace);
      rethrow;
    }
  }

  // Select user role
  void selectRole(String? role) {
    _logger.info('Role selected: $role');
    _selectedRole = role;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _logger.info('Logging out user: $_userName ?? $_userPhone');
    _isLoggedIn = false;
    _selectedRole = null;
    _userPhone = null;
    _userName = null;

    await _repository.clearAuth();

    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP(String phone) async {
    try {
      await _repository.resendOTP(phone);
    } catch (e) {
      _logger.info('Resending OTP to: $phone');
      await Future.delayed(const Duration(seconds: 1));
      // API call to resend OTP
    } catch (e, stackTrace) {
      _logger.error('Failed to resend OTP to: $phone', e, stackTrace);
      rethrow;
    }
  }
}
