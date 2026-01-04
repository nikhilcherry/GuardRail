import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail_app/providers/guard_provider.dart';
import 'package:guardrail_app/repositories/visitor_repository.dart';

void main() {
  group('GuardProvider', () {
    late GuardProvider guardProvider;

    setUp(() {
      guardProvider = GuardProvider();
    });

    test('Initial entries should have exitTime as null or valid DateTime', () {
      final entries = guardProvider.entries;
      for (var entry in entries) {
        if (entry.status == 'approved' && entry.exitTime == null) {
          // Should be considered inside
        }
      }
    });

    test('markExit updates visitor entry', () async {
      // Create a test visitor
      final visitorEntry = await guardProvider.registerNewVisitor(
        name: 'Test Visitor',
        flatNumber: '101',
        purpose: 'Guest',
      );

      // Approve it
      await guardProvider.approveVisitor(visitorEntry.id);

      // Mark exit
      await guardProvider.markExit(visitorEntry.id);

      // Verify
      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == visitorEntry.id);
      expect(updatedEntry.exitTime, isNotNull);
    });
  });
}
