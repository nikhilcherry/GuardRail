import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keySelectedRole = 'selectedRole';
  static const String _keyUserPhone = 'userPhone';
  static const String _keyUserName = 'userName';
  static const String _keyIsVerified = 'isVerified';

  Future<void> saveLoginStatus({
    required bool isLoggedIn,
    String? role,
    String? phone,
    String? name,
    bool? isVerified,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (role != null) await prefs.setString(_keySelectedRole, role);
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    if (name != null) await prefs.setString(_keyUserName, name);
    if (isVerified != null) await prefs.setBool(_keyIsVerified, isVerified);
  }

  Future<Map<String, dynamic>> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'selectedRole': prefs.getString(_keySelectedRole),
      'userPhone': prefs.getString(_keyUserPhone),
      'userName': prefs.getString(_keyUserName),
      'isVerified': prefs.getBool(_keyIsVerified) ?? false,
    };
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    // We might want to keep some settings, but AuthProvider.logout currently clears everything.
    // However, it's safer to clear specific keys if we have other settings in SharedPreferences.
    // But since the current implementation does `prefs.clear()`, we should be careful if we mix settings in the same SharedPreferences.
    // Ideally, we should only clear auth related keys.
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keySelectedRole);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsVerified);
  }

  // Simulation methods can also reside here or remain in Provider if they are purely business logic.
  // Usually, Repository handles data fetching. So simulating an API call fits here.

  Future<void> loginWithPhoneAndOTP(String phone, String otp) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, this would validate with backend and return a token/user object.
  }

  Future<void> loginWithEmail(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> resendOTP(String phone) async {
      await Future.delayed(const Duration(seconds: 1));
  }
}
