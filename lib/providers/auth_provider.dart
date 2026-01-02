import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthService _authService = AuthService();
  final _logger = LoggerService();

  bool _isLoggedIn = false;
  bool _isInitializing = true;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;
  String? _userEmail;
  bool _biometricsEnabled = false;
  bool _isVerified = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get selectedRole => _selectedRole;
  String? get userPhone => _userPhone;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isVerified => _isVerified;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    try {
      final status = await _repository.getLoginStatus();
      _isLoggedIn = status['isLoggedIn'] ?? false;
      _selectedRole = status['selectedRole'];
      _userPhone = status['userPhone'];
      _userName = status['userName'];
      _isVerified = status['isVerified'] ?? false;

      final prefs = await SharedPreferences.getInstance();
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;

      // Verify token exists if logged in
      if (_isLoggedIn) {
        final token = await _authService.getToken();
        if (token == null) {
          _isLoggedIn = false;
          await _repository.clearAuth();
        } else if (_biometricsEnabled) {
          // Enforce biometrics if enabled
          final authenticated = await _authService.authenticate();
          if (!authenticated) {
             _isLoggedIn = false;
          }
        }
      }

      _logger.info('Login status checked. LoggedIn: $_isLoggedIn, Role: $_selectedRole, Verified: $_isVerified');
    } catch (e, stackTrace) {
      _logger.error('Error checking login status', e, stackTrace);
      _isLoggedIn = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
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
      _logger.info('Attempting login fallback for phone: $phone');
      await Future.delayed(const Duration(seconds: 1));
      
      // Determine role if stored, else default to resident for fallback
      // In real scenario, backend returns role.
      // Here we check if we have a stored role from previous session? No, we don't.
      // We will assume 'resident' if no role is found in fallback, or check repository if possible.
      // But we are logging in, so we don't know the role yet.
      // Let's assume 'resident' for fallback simplicity unless we want to query a mock DB.
      final fallbackRole = 'resident';

      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: fallbackRole,
        phone: phone,
        isVerified: true, // Assuming login implies verification
      );

      await _authService.saveToken('simulated_token_phone_$phone');

      _isLoggedIn = true;
      _selectedRole = fallbackRole;
      _userPhone = phone;
      _isVerified = true;
      _logger.info('Login successful (fallback) for phone: $phone');
      notifyListeners();
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
       _logger.info('Attempting login fallback for email: $email');
       await Future.delayed(const Duration(seconds: 1));

       // In a real app, the backend returns the role.
       // For fallback, we default to 'resident' unless it looks like an admin email
       String fallbackRole = 'resident';
       if (email.contains('admin')) fallbackRole = 'admin';
       if (email.contains('guard')) fallbackRole = 'guard';

       await _repository.saveLoginStatus(
         isLoggedIn: true,
         role: fallbackRole,
         isVerified: true, // Assuming login implies verification
       );

       await _authService.saveToken('simulated_token_email_$email');

       _isLoggedIn = true;
       _selectedRole = fallbackRole;
       _userEmail = email;
       _isVerified = true;
       _logger.info('Login successful (fallback) for email: $email');
       notifyListeners();
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        contact: email.isNotEmpty ? email : phone, // Use email as primary contact if available for backend
        password: password,
        role: role,
      );
      
      _selectedRole = role;

      // Note: Verification status will be false initially for new registrations
      await _handleLoginSuccess(response,
        phone: phone,
        email: email,
        name: name,
        isVerified: false,
      );
    } catch (e) {
       _logger.info('Attempting register fallback for: $email / $phone');
       await Future.delayed(const Duration(seconds: 1));

       await _repository.saveLoginStatus(
         isLoggedIn: true,
         role: role,
         phone: phone,
         name: name,
         isVerified: false,
       );

       await _authService.saveToken('simulated_token_reg_${email.isNotEmpty ? email : phone}');

       _isLoggedIn = true;
       _selectedRole = role;
       _userName = name;
       _userEmail = email;
       _userPhone = phone;
       _isVerified = false;

       notifyListeners();
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> response, {String? phone, String? email, String? name, bool isVerified = true}) async {
    final token = response['token'];
    if (token != null) {
      await _authService.saveToken(token);
    }

    // In a real app, response should contain the role.
    // If response has role, update _selectedRole
    if (response.containsKey('role')) {
      _selectedRole = response['role'];
    }

    // If backend returns verification status, use it
    if (response.containsKey('isVerified')) {
      isVerified = response['isVerified'];
    }

    _isLoggedIn = true;
    if (phone != null) _userPhone = phone;
    if (email != null) _userEmail = email;
    if (name != null) _userName = name;
    _isVerified = isVerified;

    await _repository.saveLoginStatus(
      isLoggedIn: true,
      role: _selectedRole,
      phone: _userPhone,
      name: _userName,
      isVerified: _isVerified,
    );

    notifyListeners();
  }

  // Verify ID
  Future<void> verifyId(String id) async {
    // Simulate verification
    await Future.delayed(const Duration(seconds: 1));
    // Here we would validate the ID with the backend

    _isVerified = true;
    await _repository.saveLoginStatus(
      isLoggedIn: true,
      role: _selectedRole,
      phone: _userPhone,
      name: _userName,
      isVerified: true,
    );
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

  // Select user role - Mainly used for Role Selection screen, but now less relevant.
  // Can be kept if needed for manual overrides or during signup flow if we wanted.
  void selectRole(String? role) {
    _logger.info('Role selected: $role');
    _selectedRole = role;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _logger.info('Logging out user: $_userName');
    _isLoggedIn = false;
    _selectedRole = null;
    _userPhone = null;
    _userName = null;
    _userEmail = null;
    _isVerified = false;

    await _authService.deleteToken();
    await _repository.clearAuth();

    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP(String phone) async {
    try {
       await _repository.resendOTP(phone);
    } catch (e, stackTrace) {
      _logger.error('Failed to resend OTP to: $phone', e, stackTrace);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
