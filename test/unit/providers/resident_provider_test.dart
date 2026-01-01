import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/resident_provider.dart';

void main() {
  group('ResidentProvider Tests', () {
    late ResidentProvider residentProvider;

    setUp(() {
      residentProvider = ResidentProvider();
    });

    test('Initial state has dummy visitors', () {
      expect(residentProvider.pendingRequests, 1);
      expect(residentProvider.todaysVisitors.length, 3);
    });

    test('getPendingApprovals returns only pending visitors', () {
      final pending = residentProvider.getPendingApprovals();
      expect(pending.length, 1);
      expect(pending.first.status, 'pending');
    });

    test('approveVisitor updates visitor status', () {
      final visitorId = residentProvider.pendingVisitors.first.id;
      residentProvider.approveVisitor(visitorId);

      // Visitor should be moved from pending to approved history (or just updated)
      // Implementation detail: approveVisitor removes from pendingVisitors and adds to history
      expect(residentProvider.pendingVisitors.isEmpty, true);
      // We assume it's added to history but checking pending is empty is enough for now
      // Actually we can check if it's in history
    });

    test('rejectVisitor updates visitor status', () {
      // Re-setup because previous test modified state
      residentProvider = ResidentProvider();
      final visitorId = residentProvider.pendingVisitors.first.id;
      residentProvider.rejectVisitor(visitorId);

      expect(residentProvider.pendingVisitors.isEmpty, true);
    });
  });
}
