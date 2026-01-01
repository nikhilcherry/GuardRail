import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  final _logger = LoggerService();
  bool _isLoggedIn = false;
  bool _isInitializing = true;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;
  String? _userEmail;
  bool _biometricsEnabled = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get selectedRole => _selectedRole;
  String? get userPhone => _userPhone;
  String? get userName => _userName;
  bool get biometricsEnabled => _biometricsEnabled;

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _selectedRole = prefs.getString('selectedRole');
    _userPhone = prefs.getString('userPhone');
    _userName = prefs.getString('userName');
    _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;

    // Verify token exists if logged in
    if (_isLoggedIn) {
      final token = await _authService.getToken();
      if (token == null) {
        _isLoggedIn = false;
        await prefs.setBool('isLoggedIn', false);
      } else if (_biometricsEnabled) {
        // Enforce biometrics if enabled
        final authenticated = await _authService.authenticate();
        if (!authenticated) {
          _isLoggedIn = false;
           // We don't clear prefs here so they can try again,
           // but for now we set isLoggedIn to false so they see the login screen
           // In a more complex app we might show a "Unlock" screen.
           // For simplicity: logout/require re-login.
        }
      }
    }

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
      final response = await _authService.login(phone, otp);
      await _handleLoginSuccess(response, phone: phone);
    } catch (e) {
      _logger.info('Attempting login with phone: $phone');
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;
      _userPhone = phone;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      if (_selectedRole != null) {
        await prefs.setString('selectedRole', _selectedRole!);
      }
      await prefs.setString('userPhone', phone);

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
      final response = await _authService.loginWithEmail(email, password);
      await _handleLoginSuccess(response, email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String contact,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        contact: contact,
        password: password,
        role: role,
      );
      _logger.info('Attempting login with email: $email');
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Auto login after registration
      await _handleLoginSuccess(response,
        phone: role != 'admin' ? contact : null,
        email: role == 'admin' ? contact : null,
        name: name
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> response, {String? phone, String? email, String? name}) async {
    final token = response['token'];
    await _authService.saveToken(token);

    _isLoggedIn = true;
    _userPhone = phone;
    _userEmail = email;
    if (name != null) _userName = name;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (_selectedRole != null) {
      await prefs.setString('selectedRole', _selectedRole!);
    }
    if (phone != null) await prefs.setString('userPhone', phone);
    if (name != null) await prefs.setString('userName', name);

    notifyListeners();
  }

  // Toggle Biometrics
  Future<bool> toggleBiometrics(bool value) async {
    if (value) {
      final canCheck = await _authService.checkBiometrics();
      if (!canCheck) {
        return false;
      }
      final authenticated = await _authService.authenticate();
      if (authenticated) {
        _biometricsEnabled = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometricsEnabled', true);
        notifyListeners();
        return true;
      }
      return false;
    } else {
      _biometricsEnabled = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricsEnabled', false);
      notifyListeners();
      return true;
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
    _userEmail = null;

    await _authService.deleteToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP(String phone) async {
    try {
      _logger.info('Resending OTP to: $phone');
      await Future.delayed(const Duration(seconds: 1));
      // API call to resend OTP
    } catch (e, stackTrace) {
      _logger.error('Failed to resend OTP to: $phone', e, stackTrace);
      rethrow;
    }
  }
}
