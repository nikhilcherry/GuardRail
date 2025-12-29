import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get selectedRole => _selectedRole;
  String? get userPhone => _userPhone;
  String? get userName => _userName;

  // Login with phone and OTP
  Future<void> loginWithPhoneAndOTP({
    required String phone,
    required String otp,
    required String role,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;
      _userPhone = phone;
      _selectedRole = role;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login with email
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoggedIn = true;
      _selectedRole = role;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Select user role (Used if logic separated)
  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  // Logout
  void logout() {
    _isLoggedIn = false;
    _selectedRole = null;
    _userPhone = null;
    _userName = null;
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
