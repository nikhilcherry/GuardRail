import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../services/firestore_service.dart';
import '../services/logger_service.dart';

/// Authentication service using Firebase Auth.
class AuthService {
  // SECURITY: Use encryptedSharedPreferences on Android for consistent secure storage
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  final _localAuth = LocalAuthentication();
  
  // Use getter to avoid initialization before Firebase.initializeApp()
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  FirestoreService get _firestoreService => FirestoreService();

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Login with email and password using Firebase Auth
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user profile from Firestore
      final profile = await _firestoreService.getUserProfile(credential.user?.uid);
      
      return {
        'success': true,
        'token': await credential.user?.getIdToken(),
        'userId': credential.user?.uid,
        'email': credential.user?.email,
        'name': profile?['name'] ?? credential.user?.displayName,
        'role': profile?['role'] ?? 'resident',
        'isVerified': profile?['isVerified'] ?? true,
      };
    } on FirebaseAuthException catch (e) {
      LoggerService().error('Firebase login failed', e, StackTrace.current);
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    }
  }

  /// Register with email and password using Firebase Auth
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? societyId,
    bool isVerified = false,
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
        societyId: societyId,
        isVerified: isVerified,
      );

      return {
        'success': true,
        'token': await credential.user?.getIdToken(),
        'userId': credential.user?.uid,
        'email': credential.user?.email,
        'name': name,
        'role': role,
        'isVerified': false,
      };
    } on FirebaseAuthException catch (e) {
      LoggerService().error('Firebase registration failed', e, StackTrace.current);
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    }
  }

  /// Login with phone and OTP (placeholder - Firebase Phone Auth requires additional setup)
  Future<Map<String, dynamic>> login(String phone, String otp) async {
    // For now, throw - phone auth requires additional setup in Firebase Console
    throw Exception('Phone authentication requires Firebase Phone Auth setup');
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await deleteToken();
  }

  /// Save auth token to secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Get auth token from secure storage
  Future<String?> getToken() async {
    // First check if user is signed in with Firebase
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    // Fallback to stored token
    return await _storage.read(key: 'auth_token');
  }

  /// Delete auth token from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Biometrics
  Future<bool> checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Verify your identity to access GuardRail',
      );
    } catch (e) {
      return false;
    }
  }

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed: $code';
    }
  }
}
