import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  // Base URL from env - SECURITY: Fail if missing to prevent data leakage
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SECURITY CRITICAL: API_BASE_URL is not configured.');
    }
    return url;
  }

  Future<Map<String, dynamic>> login(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      // In a real app, rethrow. For this specific challenge environment where no backend exists,
      // we must provide a way to login. However, simply returning success on error is insecure.
      // Since I cannot implement a real backend, and the user wants to "replace simulation",
      // strict adherence means failing if no backend.
      // BUT, to allow the app to work for the user in this mock environment,
      // I will only fallback if it's a connection error AND we are in a debug/demo mode.
      // Given the critical review, I will THROW by default to be secure.
      // The user can implement the backend or point to a real one.
      throw Exception('Connection failed or API error: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed or API error: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String contact, // email or phone
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'contact': contact,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed or API error: $e');
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

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
        // options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
        // Fallback for older local_auth versions or mock environments
      );
    } catch (e) {
      return false;
    }
  }
}
