import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/guard_repository.dart';
import '../repositories/flat_repository.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final GuardRepository _guardRepository = GuardRepository();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final _logger = LoggerService();

  bool _isLoggedIn = false;
  bool _isInitializing = true;
  String? _selectedRole;
  String? _userPhone;
  String? _userName;
  String? _userEmail;
  bool _biometricsEnabled = false;
  bool _isVerified = false;
  bool _isAppLocked = false;
  bool _hasSociety = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get selectedRole => _selectedRole;
  String? get userPhone => _userPhone;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isVerified => _isVerified;
  bool get isAppLocked => _isAppLocked;
  bool get hasSociety => _hasSociety;
  String get userId => _userEmail ?? _userPhone ?? 'unknown_user';

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  /// Check login status on app start
  Future<void> checkLoginStatus() async {
    try {
      // First check Firebase Auth state
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        // User is signed in with Firebase
        _isLoggedIn = true;
        _userEmail = firebaseUser.email;
        _userName = firebaseUser.displayName;
        
        // Fetch profile from Firestore
        final profile = await _firestoreService.getUserProfile(firebaseUser.uid);
        if (profile != null) {
          _selectedRole = profile['role'];
          _isVerified = profile['isVerified'] ?? false;
          _userName = profile['name'] ?? _userName;
          _userPhone = profile['phone'];

          // Check if admin has society
          if (_selectedRole == 'admin') {
            final society = await _firestoreService.getSocietyByAdmin(firebaseUser.uid);
            _hasSociety = society != null;
          }
        }
      } else {
        // Check local storage for cached status
        final status = await _repository.getLoginStatus();
        _isLoggedIn = status['isLoggedIn'] ?? false;
        _selectedRole = status['selectedRole'];
        _userPhone = status['userPhone'];
        _userName = status['userName'];
        _userEmail = status['userEmail'];
        _isVerified = status['isVerified'] ?? false;
      }

      final prefs = await SharedPreferences.getInstance();
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;

      // Check if app should be locked
      if (_isLoggedIn && _biometricsEnabled) {
        _isAppLocked = true;
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

  /// Login with email and password using Firebase Auth
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.loginWithEmail(email, password);
      
      _isLoggedIn = true;
      _userEmail = response['email'];
      _userName = response['name'];
      _selectedRole = response['role'];
      _isVerified = response['isVerified'] ?? true;
      
      // Save to local storage
      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
        email: _userEmail,
        name: _userName,
        isVerified: _isVerified,
      );

      _logger.info('Login successful for email: $email');
      
      // Check for society if admin
      if (_selectedRole == 'admin') {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final society = await _firestoreService.getSocietyByAdmin(user.uid);
          _hasSociety = society != null;
        }
      }

      notifyListeners();
    } catch (e) {
      _logger.error('Login failed for email: $email', e, StackTrace.current);
      rethrow;
    }
  }

  /// Login with phone and OTP (placeholder)
  Future<void> loginWithPhoneAndOTP({
    required String phone,
    required String otp,
  }) async {
    throw Exception('Phone authentication is not yet implemented. Please use email login.');
  }

  /// Register a new user with Firebase Auth
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? residenceId,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        societyId: residenceId, // Treated as societyId/Resident ID
        isVerified: false,
      );

      _isLoggedIn = true;
      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      _selectedRole = role;
      _isVerified = false; // New users need verification

      // Save to local storage
      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: role,
        email: email,
        phone: phone,
        name: name,
        isVerified: false,
        societyId: residenceId,
      );

      // If residence ID provided, try to join flat
      if (residenceId != null && residenceId.isNotEmpty && role == 'resident') {
        try {
          final flatRepo = FlatRepository();
          await flatRepo.joinFlat(residenceId, response['userId'] ?? email, name);
        } catch (e) {
          _logger.error('Failed to auto-join flat: $residenceId', e);
          // Don't fail registration, just log
        }
      }

      _logger.info('Registration successful for email: $email');
      notifyListeners();
    } catch (e) {
      _logger.error('Registration failed for email: $email', e, StackTrace.current);
      rethrow;
    }
  }

  /// Verify guard ID
  Future<void> verifyId(String id) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_selectedRole == 'guard') {
      final userIdentifier = _userEmail ?? _userPhone;
      if (userIdentifier == null) throw Exception('User contact info missing');

      final guard = await _guardRepository.getGuardById(id);

      if (guard == null) {
        throw Exception('Invalid Guard ID');
      }

      // Guard is now a Model object, access properties directly
      final status = guard.status;

      if (status == 'created') {
        final success = await _guardRepository.linkUserToGuard(id, userIdentifier, _userName ?? 'Unknown');
        if (!success) throw Exception('Guard ID unavailable');
        throw Exception('PENDING_APPROVAL');
      } else if (status == 'pending') {
        if (guard.linkedUserEmail == userIdentifier) {
          throw Exception('PENDING_APPROVAL');
        } else {
          throw Exception('Guard ID already in use');
        }
      } else if (status == 'active') {
        if (guard.linkedUserEmail == userIdentifier) {
          _isVerified = true;
        } else if (guard.linkedUserEmail == null) {
          await _guardRepository.linkUserToGuard(id, userIdentifier, _userName ?? 'Unknown');
          await _guardRepository.updateGuardStatus(id, 'active');
          _isVerified = true;
        } else {
          throw Exception('Guard ID already in use');
        }
      } else if (status == 'rejected') {
        throw Exception('Account Rejected');
      }
    } else {
      _isVerified = true;
    }

    if (_isVerified) {
      await _repository.saveLoginStatus(
        isLoggedIn: true,
        role: _selectedRole,
        phone: _userPhone,
        name: _userName,
        email: _userEmail,
        isVerified: true,
      );
    }

    notifyListeners();
  }

  /// Toggle biometrics
  Future<bool> toggleBiometrics(bool value) async {
    if (value) {
      final canCheck = await _authService.checkBiometrics();
      if (!canCheck) return false;
      
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

  void lockApp() {
    if (_biometricsEnabled && !_isAppLocked && _isLoggedIn) {
      _isAppLocked = true;
      notifyListeners();
      _logger.info('App locked due to background state');
    }
  }

  Future<void> unlockApp() async {
    final authenticated = await _authService.authenticate();
    if (authenticated) {
      _isAppLocked = false;
      notifyListeners();
    }
  }

  void selectRole(String? role) {
    _logger.info('Role selected: $role');
    _selectedRole = role;
    notifyListeners();
  }

  void setHasSociety(bool value) {
    _hasSociety = value;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _logger.info('Logging out user: $_userName');
    
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _logger.error('Firebase signOut error', e, StackTrace.current);
    }
    
    _isLoggedIn = false;
    _selectedRole = null;
    _userPhone = null;
    _userName = null;
    _userEmail = null;
    _isVerified = false;
    _hasSociety = false;

    await _repository.clearAuth();

    notifyListeners();
  }

  /// Resend OTP (placeholder)
  Future<void> resendOTP(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Phone authentication is not yet implemented');
  }
}
