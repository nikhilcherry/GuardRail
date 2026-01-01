import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;
  String? _userEmail;
  bool _biometricsEnabled = false;

  bool get isLoggedIn => _isLoggedIn;
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

    notifyListeners();
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
    }
  }

  // Select user role
  void selectRole(String? role) {
    _selectedRole = role;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
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
      await Future.delayed(const Duration(seconds: 1));
      // API call to resend OTP
    } catch (e) {
      rethrow;
    }
  }
}
