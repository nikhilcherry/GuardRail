import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/utils/security_utils.dart';

void main() {
  group('SecurityUtils', () {
    test('generateId returns string of correct length', () {
      final id = SecurityUtils.generateId(length: 10);
      expect(id.length, 10);
    });

    test('generateId respects charset', () {
      final id = SecurityUtils.generateId(length: 20, chars: SecurityUtils.digits);
      expect(id, matches(RegExp(r'^[0-9]+$')));
    });

    test('generateId respects prefix', () {
      final id = SecurityUtils.generateId(length: 6, prefix: 'PREFIX');
      expect(id, startsWith('PREFIX'));
      expect(id.length, 6 + 'PREFIX'.length);
    });

    test('generateId produces different values', () {
      final id1 = SecurityUtils.generateId();
      final id2 = SecurityUtils.generateId();
      expect(id1, isNot(equals(id2)));
    });
  });
}
