import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/guard_provider.dart';

void main() {
  group('GuardProvider Process Scan Tests', () {
    late GuardProvider guardProvider;

    setUp(() {
      guardProvider = GuardProvider();
    });

    test('processScan adds a check for a new location', () async {
      await guardProvider.processScan(
        qrCode: 'LOC-001',
        photoPath: '/path/to/photo.jpg',
        guardId: 'GUARD-001',
      );

      expect(guardProvider.checks.length, 1);
      expect(guardProvider.checks.first.locationId, 'LOC-001');
      expect(guardProvider.checks.first.guardId, 'GUARD-001');
    });

    test('processScan throws exception for duplicate scan on the same day', () async {
      // First scan
      await guardProvider.processScan(
        qrCode: 'LOC-002',
        photoPath: '/path/to/photo.jpg',
        guardId: 'GUARD-001',
      );

      // Duplicate scan
      expect(
        () async => await guardProvider.processScan(
          qrCode: 'LOC-002',
          photoPath: '/path/to/photo_2.jpg',
          guardId: 'GUARD-001',
        ),
        throwsException,
      );

      // Verify check count remains 1
      expect(guardProvider.checks.length, 1);
      expect(guardProvider.checks.first.locationId, 'LOC-002');
    });

    test('processScan allows same location scan for different guard', () async {
      // Guard 1 scans
      await guardProvider.processScan(
        qrCode: 'LOC-003',
        photoPath: '/path/to/photo.jpg',
        guardId: 'GUARD-001',
      );

      // Guard 2 scans same location
      await guardProvider.processScan(
        qrCode: 'LOC-003',
        photoPath: '/path/to/photo_2.jpg',
        guardId: 'GUARD-002',
      );

      expect(guardProvider.checks.length, 2);
    });

    test('processScan allows different location scan for same guard', () async {
      // Scan Loc 1
      await guardProvider.processScan(
        qrCode: 'LOC-004',
        photoPath: '/path/to/photo.jpg',
        guardId: 'GUARD-001',
      );

      // Scan Loc 2
      await guardProvider.processScan(
        qrCode: 'LOC-005',
        photoPath: '/path/to/photo_2.jpg',
        guardId: 'GUARD-001',
      );

      expect(guardProvider.checks.length, 2);
    });
  });
}
