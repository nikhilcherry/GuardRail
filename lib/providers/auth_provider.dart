import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
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

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _selectedRole = prefs.getString('selectedRole');
    _userPhone = prefs.getString('userPhone');
    _userName = prefs.getString('userName');
    _isInitializing = false;
    notifyListeners();
  }

  // Login with phone and OTP
  Future<void> loginWithPhoneAndOTP({
    required String phone,
    required String otp,
  }) async {
    try {
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

      notifyListeners();
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      if (_selectedRole != null) {
        await prefs.setString('selectedRole', _selectedRole!);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
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
