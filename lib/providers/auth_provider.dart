import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/guard_repository.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';
import '../services/mock/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final GuardRepository _guardRepository = GuardRepository();
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
      _userEmail = status['userEmail']; // Ensure we load email if saved
      _isVerified = status['isVerified'] ?? false;

      final prefs = await SharedPreferences.getInstance();
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;

      // Check Guard Status if user is a Guard
      if (_isLoggedIn && _selectedRole == 'guard') {
        final email = _userEmail ?? _userPhone; // Fallback
        if (email != null) {
          final guard = _guardRepository.getGuardByEmail(email);
          if (guard != null) {
            final guardStatus = guard['status'];
            if (guardStatus != 'active') {
              // If not active (pending or rejected), they are technically verified (linked) but not allowed in.
              // However, app flow depends on isVerified to bypass ID screen.
              // If we set isVerified = false, they go to ID screen.
              // We need a way to tell ID screen "You are pending".
              // For now, let's keep isVerified = true if pending, but maybe logout or handle in router?
              // The router checks isVerified.
              // If we set isVerified = false, they go to ID screen.
              // ID screen can check status.
              _isVerified = false;
            } else {
              _isVerified = true;
            }
          } else {
             // Guard not found?
             _isVerified = false;
          }
        }
      }

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
      
      // SECURITY: Validate against mock credentials instead of allowing any input
      final fallbackRole = MockAuthService.validatePhoneLogin(phone, otp);

      if (fallbackRole != null) {
        await _repository.saveLoginStatus(
          isLoggedIn: true,
          role: fallbackRole,
          phone: phone,
          isVerified: true,
        );

        await _authService.saveToken('simulated_token_phone_$phone');

        _isLoggedIn = true;
        _selectedRole = fallbackRole;
        _userPhone = phone;
        _isVerified = true;
        _logger.info('Login successful (fallback) for phone: $phone');
        notifyListeners();
      } else {
        _logger.warning('Login fallback failed: Invalid mock credentials for $phone');
        // Rethrow to show error in UI
        throw Exception('Invalid phone or OTP (Mock Mode)');
      }
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

       // SECURITY: Validate against mock credentials instead of allowing any input
       // We first check the MockAuthService for explicit admin/resident matches
       String? fallbackRole = MockAuthService.validateEmailLogin(email, password);

       // If not found in basic mock service, check if it's a known Guard in the repo
       final guard = _guardRepository.getGuardByEmail(email);
       if (fallbackRole == null && guard != null) {
         // It's a known guard email. Validate using allowed test passwords.
         if (MockAuthService.validateGuardPassword(password)) {
            fallbackRole = 'guard';
         }
       }

       if (fallbackRole != null) {
         // Check status if guard
         bool isVerified = true;
         if (fallbackRole == 'guard') {
           if (guard != null && guard['status'] != 'active') {
             isVerified = false; // Send to verification/status screen
           }
         }

         await _repository.saveLoginStatus(
           isLoggedIn: true,
           role: fallbackRole,
           isVerified: isVerified,
           name: guard?['name'], // Try to get name if available
         );

         await _authService.saveToken('simulated_token_email_$email');

         _isLoggedIn = true;
         _selectedRole = fallbackRole;
         _userEmail = email;
         _isVerified = isVerified;
         _logger.info('Login successful (fallback) for email: $email');
         notifyListeners();
       } else {
          _logger.warning('Login fallback failed: Invalid mock credentials for $email');
          throw Exception('Invalid email or password (Mock Mode)');
       }
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
        contact: email.isNotEmpty ? email : phone,
        password: password,
        role: role,
      );
      
      _selectedRole = role;

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

    if (response.containsKey('role')) {
      _selectedRole = response['role'];
    }

    if (response.containsKey('isVerified')) {
      isVerified = response['isVerified'];
    }

    // Additional check for Guard status
    if (_selectedRole == 'guard') {
       final userIdentifier = email ?? phone ?? '';
       final guard = _guardRepository.getGuardByEmail(userIdentifier);
       if (guard != null && guard['status'] != 'active') {
         isVerified = false;
       }
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
  // Throws exception with message if verification fails or pending
  Future<void> verifyId(String id) async {
    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));

    if (_selectedRole == 'guard') {
       final userIdentifier = _userEmail ?? _userPhone;
       if (userIdentifier == null) throw Exception('User contact info missing');

       // Check repository
       final guard = _guardRepository.getGuardById(id);

       if (guard == null) {
         throw Exception('Invalid Guard ID');
       }

       if (guard['status'] == 'created') {
         // Link user
         final success = _guardRepository.linkUserToGuard(id, userIdentifier, _userName ?? 'Unknown');
         if (!success) throw Exception('Guard ID unavailable');

         // Set status to pending (isVerified = false, but maybe we need to communicate this to UI)
         // We will throw an exception that is actually a status message?
         // Or we can return a status string? verifyId returns Future<void>.
         // I will throw an exception with a specific prefix or message the UI can handle.
         throw Exception('PENDING_APPROVAL');
       } else if (guard['status'] == 'pending') {
          // Check if it's this user
          if (guard['linkedUserEmail'] == userIdentifier) {
             throw Exception('PENDING_APPROVAL');
          } else {
             throw Exception('Guard ID already in use');
          }
       } else if (guard['status'] == 'active') {
          if (guard['linkedUserEmail'] == userIdentifier) {
             _isVerified = true;
          } else if (guard['linkedUserEmail'] == null) {
             // Maybe it was activated manually without link? (Not in current flow)
             // Link it now?
             _guardRepository.linkUserToGuard(id, userIdentifier, _userName ?? 'Unknown');
             _guardRepository.updateGuardStatus(id, 'active'); // Ensure active
             _isVerified = true;
          } else {
             throw Exception('Guard ID already in use');
          }
       } else if (guard['status'] == 'rejected') {
          throw Exception('Account Rejected');
       }
    } else {
      // Resident Logic (Placeholder)
      _isVerified = true;
    }

    if (_isVerified) {
      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
        phone: _userPhone,
        name: _userName,
        isVerified: true,
      );
    }

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
