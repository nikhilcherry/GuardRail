import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoggedIn = false;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
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
    notifyListeners();
  }

  // Login with phone and OTP
  Future<void> loginWithPhoneAndOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      await _repository.loginWithPhoneAndOTP(phone, otp);
      
      _isLoggedIn = true;
      _userPhone = phone;

      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
        phone: phone,
      );

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
      await _repository.loginWithEmail(email, password);
      
      _isLoggedIn = true;

      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
      );

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

    await _repository.clearAuth();

    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP(String phone) async {
    try {
      await _repository.resendOTP(phone);
    } catch (e) {
      rethrow;
    }
  }
}
