import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A secure mock authentication service for development environments.
///
/// SECURITY: This class ensures that even in fallback mode, we validate
/// credentials against a known set of test users, rather than failing open.
class MockAuthService {
  // Load credentials from .env to avoid hardcoding secrets in source code
  static String get _guardPhone => dotenv.env['GUARD_PHONE'] ?? '1234567890';
  static String get _guardOtp => dotenv.env['GUARD_OTP'] ?? '123456';

  static String get _residentPhone => dotenv.env['RESIDENT_PHONE'] ?? '0987654321';
  static String get _residentOtp => dotenv.env['RESIDENT_OTP'] ?? '654321';

  static String get _adminEmail => dotenv.env['ADMIN_EMAIL'] ?? 'admin@example.com';
  static String get _adminPassword => dotenv.env['ADMIN_PASSWORD'] ?? 'admin123';

  static const String _residentEmail = 'robert@example.com';
  static const String _residentPassword = 'password123';

  // Generic test passwords for dynamically created accounts in demo mode
  static const List<String> _allowedTestPasswords = ['password123', '123456'];

  /// Validates phone and OTP against mock users.
  /// Returns the role if valid, null otherwise.
  static String? validatePhoneLogin(String phone, String otp) {
    if (phone == _guardPhone && otp == _guardOtp) {
      return 'guard';
    }
    if (phone == _residentPhone && otp == _residentOtp) {
      return 'resident';
    }
    return null;
  }

  /// Validates email and password against mock users.
  /// Returns the role if valid, null otherwise.
  static String? validateEmailLogin(String email, String password) {
    // Admin check
    if (email == _adminEmail && password == _adminPassword) {
      return 'admin';
    }

    // Resident check
    if (email == _residentEmail && password == _residentPassword) {
      return 'resident';
    }

    return null;
  }

  /// Validates a guard login for an existing guard profile.
  /// This is used when the email matches a known guard but isn't the primary test user.
  /// In a real mock, we'd check against the specific user's password, but for this demo
  /// we allow standard test passwords for usability.
  static bool validateGuardPassword(String password) {
    return _allowedTestPasswords.contains(password);
  }
}
