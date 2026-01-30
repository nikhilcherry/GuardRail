import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/utils/security_utils.dart';

void main() {
  group('SecurityUtils', () {
    test('generateSecureString generates string of correct length', () {
      final str1 = SecurityUtils.generateSecureString(length: 6);
      expect(str1.length, 6);

      final str2 = SecurityUtils.generateSecureString(length: 12);
      expect(str2.length, 12);
    });

    test('generateSecureString uses custom charset', () {
      const charset = 'A';
      final str = SecurityUtils.generateSecureString(length: 5, charset: charset);
      expect(str, 'AAAAA');
    });

    test('generateSecureString generates unique strings', () {
      final str1 = SecurityUtils.generateSecureString();
      final str2 = SecurityUtils.generateSecureString();
      expect(str1, isNot(equals(str2)));
    });

    test('generateSecureString defaults to length 6 and alphanumeric', () {
      final str = SecurityUtils.generateSecureString();
      expect(str.length, 6);
      final alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');
      expect(alphaNumeric.hasMatch(str), isTrue);
    });
  });
}
