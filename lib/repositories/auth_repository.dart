import 'package:firebase_auth/firebase_auth.dart';
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
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    if (name != null) await prefs.setString(_keyUserName, name);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (isVerified != null) await prefs.setBool(_keyIsVerified, isVerified);
    if (flatId != null) await prefs.setString(_keyFlatId, flatId);
  }

  /// Get login status from local storage
  Future<Map<String, dynamic>> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'selectedRole': prefs.getString(_keySelectedRole),
      'userPhone': prefs.getString(_keyUserPhone),
      'userName': prefs.getString(_keyUserName),
      'userEmail': prefs.getString(_keyUserEmail),
      'isVerified': prefs.getBool(_keyIsVerified) ?? false,
      'flatId': prefs.getString(_keyFlatId),
    };
  }

  /// Clear all auth data
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keySelectedRole);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsVerified);
    await prefs.remove(_keyFlatId);
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
      await _firestoreService.saveUserProfile(
        name: name,
        email: email,
        role: role,
        phone: phone,
        flatId: flatId,
        isVerified: false,
      );

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
      final profile = await _firestoreService.getUserProfile();
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
    return _firestoreService.getUserProfile();
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    await _firestoreService.updateUserProfile(updates);
  }

  // Legacy methods for backward compatibility
  Future<void> loginWithPhoneAndOTP(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> resendOTP(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
