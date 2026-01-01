import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    test('Initial state is logged out', () {
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.selectedRole, null);
    });

    test('selectRole updates selectedRole', () {
      authProvider.selectRole('guard');
      expect(authProvider.selectedRole, 'guard');

      authProvider.selectRole(null);
      expect(authProvider.selectedRole, null);
    });

    test('loginWithEmail updates state correctly', () async {
      authProvider.selectRole('resident');
      await authProvider.loginWithEmail(email: 'test@example.com', password: 'password');

      expect(authProvider.isLoggedIn, true);
      expect(authProvider.selectedRole, 'resident');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      expect(prefs.getString('selectedRole'), 'resident');
    });

    test('loginWithPhoneAndOTP updates state correctly', () async {
      authProvider.selectRole('guard');
      await authProvider.loginWithPhoneAndOTP(phone: '1234567890', otp: '123456');

      expect(authProvider.isLoggedIn, true);
      expect(authProvider.selectedRole, 'guard');
      expect(authProvider.userPhone, '1234567890');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true);
      expect(prefs.getString('selectedRole'), 'guard');
      expect(prefs.getString('userPhone'), '1234567890');
    });

    test('logout clears state and preferences', () async {
      // Setup logged in state
      authProvider.selectRole('resident');
      await authProvider.loginWithEmail(email: 'test@example.com', password: 'password');

      // Perform logout
      await authProvider.logout();

      expect(authProvider.isLoggedIn, false);
      expect(authProvider.selectedRole, null);
      expect(authProvider.userPhone, null);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('isLoggedIn'), false); // clear() removes keys
      expect(prefs.containsKey('selectedRole'), false);
    });
  });
}
