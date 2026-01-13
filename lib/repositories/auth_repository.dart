import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

class AuthRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keySelectedRole = 'selectedRole';
  static const String _keyUserPhone = 'userPhone';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyIsVerified = 'isVerified';
  static const String _keyFlatId = 'flatId';

  final _storage = const FlutterSecureStorage();

  // Use getters to avoid initialization before Firebase.initializeApp()
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  FirestoreService get _firestoreService => FirestoreService();

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated with Firebase
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Save login status to local storage
  Future<void> saveLoginStatus({
    required bool isLoggedIn,
    String? role,
    String? phone,
    String? name,
    String? email,
    bool? isVerified,
    String? flatId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (role != null) await prefs.setString(_keySelectedRole, role);
    if (isVerified != null) await prefs.setBool(_keyIsVerified, isVerified);

    // SECURITY: Store PII in secure storage
    if (phone != null) await _storage.write(key: _keyUserPhone, value: phone);
    if (name != null) await _storage.write(key: _keyUserName, value: name);
    if (email != null) await _storage.write(key: _keyUserEmail, value: email);
    if (flatId != null) await _storage.write(key: _keyFlatId, value: flatId);
  }

  /// Get login status from local storage
  Future<Map<String, dynamic>> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'selectedRole': prefs.getString(_keySelectedRole),
      'isVerified': prefs.getBool(_keyIsVerified) ?? false,
      // SECURITY: Read PII from secure storage, fallback to prefs for migration
      'userPhone': await _readAndMigrate(_keyUserPhone, prefs),
      'userName': await _readAndMigrate(_keyUserName, prefs),
      'userEmail': await _readAndMigrate(_keyUserEmail, prefs),
      'flatId': await _readAndMigrate(_keyFlatId, prefs),
    };
  }

  Future<String?> _readAndMigrate(String key, SharedPreferences prefs) async {
    String? val = await _storage.read(key: key);
    if (val == null && prefs.containsKey(key)) {
      val = prefs.getString(key);
      if (val != null) {
        await _storage.write(key: key, value: val);
        await prefs.remove(key);
      }
    }
    return val;
  }

  /// Clear all auth data
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keySelectedRole);
    await prefs.remove(_keyIsVerified);

    // SECURITY: Clear only PII keys managed by this repository
    await _storage.delete(key: _keyUserPhone);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyFlatId);
  }

  /// Register with Firebase Auth and create Firestore profile
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? flatId,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create Firestore user profile
      if (credential.user != null) {
        await _firestoreService.saveUserProfileWithId(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          phone: phone,
          flatId: flatId,
          isVerified: false,
        );
      }

      // Save to local storage
      await saveLoginStatus(
        isLoggedIn: true,
        role: role,
        name: name,
        email: email,
        phone: phone,
        isVerified: false,
        flatId: flatId,
      );

      LoggerService().info('User registered: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      LoggerService().error('Registration failed', e, StackTrace.current);
      rethrow;
    }
  }

  /// Login with Firebase Auth
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user profile from Firestore
      final profile = await _firestoreService.getUserProfile(credential.user?.uid);
      if (profile != null) {
        await saveLoginStatus(
          isLoggedIn: true,
          role: profile['role'],
          name: profile['name'],
          email: profile['email'],
          phone: profile['phone'],
          isVerified: profile['isVerified'] ?? false,
          flatId: profile['flatId'],
        );
      }

      LoggerService().info('User logged in: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      LoggerService().error('Login failed', e, StackTrace.current);
      rethrow;
    }
  }

  /// Logout from Firebase
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await clearAuth();
      LoggerService().info('User logged out');
    } catch (e) {
      LoggerService().error('Logout failed', e, StackTrace.current);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    return _firestoreService.getUserProfile(_firebaseAuth.currentUser?.uid);
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_firebaseAuth.currentUser != null) {
      await _firestoreService.updateUserProfileWithId(_firebaseAuth.currentUser!.uid, updates);
    }
  }

  // Legacy methods for backward compatibility
  Future<void> loginWithPhoneAndOTP(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> resendOTP(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
