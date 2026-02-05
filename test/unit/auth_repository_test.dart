import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardrail/repositories/auth_repository.dart';

// Fake implementation of FlutterSecureStorage for testing
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage;
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthRepository Migration Tests', () {
    late FakeSecureStorage fakeStorage;
    late AuthRepository authRepository;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      authRepository = AuthRepository(storage: fakeStorage);
      SharedPreferences.setMockInitialValues({});
    });

    test('getLoginStatus should migrate data from SharedPreferences to SecureStorage', () async {
      // Setup legacy data in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'userPhone': '1234567890',
        'userName': 'Test User',
        'userEmail': 'test@example.com',
        'flatId': 'flat123',
      });

      // Initially, secure storage is empty
      expect(await fakeStorage.read(key: 'userPhone'), isNull);

      // Call getLoginStatus to trigger migration
      final status = await authRepository.getLoginStatus();

      // Verify data is correct in the result
      expect(status['userPhone'], '1234567890');
      expect(status['userName'], 'Test User');
      expect(status['userEmail'], 'test@example.com');
      expect(status['flatId'], 'flat123');

      // Verify data is migrated to SecureStorage
      expect(await fakeStorage.read(key: 'userPhone'), '1234567890');
      expect(await fakeStorage.read(key: 'userName'), 'Test User');
      expect(await fakeStorage.read(key: 'userEmail'), 'test@example.com');
      expect(await fakeStorage.read(key: 'flatId'), 'flat123');

      // Verify data is removed from SharedPreferences (re-read prefs)
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('userPhone'), isFalse);
      expect(prefs.containsKey('userName'), isFalse);
      expect(prefs.containsKey('userEmail'), isFalse);
      expect(prefs.containsKey('flatId'), isFalse);

      // Non-sensitive data should remain
      expect(prefs.getBool('isLoggedIn'), true);
    });

    test('saveLoginStatus should save to SecureStorage and clean SharedPreferences', () async {
      // Setup initial prefs with some dummy data to ensure it gets cleaned
      SharedPreferences.setMockInitialValues({
        'userPhone': 'old_phone',
      });

      await authRepository.saveLoginStatus(
        isLoggedIn: true,
        phone: '9876543210',
        name: 'New User',
        email: 'new@example.com',
        flatId: 'flat456',
      );

      // Verify SecureStorage has the new data
      expect(await fakeStorage.read(key: 'userPhone'), '9876543210');
      expect(await fakeStorage.read(key: 'userName'), 'New User');
      expect(await fakeStorage.read(key: 'userEmail'), 'new@example.com');
      expect(await fakeStorage.read(key: 'flatId'), 'flat456');

      // Verify SharedPreferences is cleaned
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('userPhone'), isFalse);
      expect(prefs.containsKey('userName'), isFalse);
      expect(prefs.containsKey('userEmail'), isFalse);
      expect(prefs.containsKey('flatId'), isFalse);

      // Verify other flags
      expect(prefs.getBool('isLoggedIn'), true);
    });
  });
}
