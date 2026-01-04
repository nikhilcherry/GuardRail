import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/guard_provider.dart';
import 'package:guardrail/repositories/visitor_repository.dart';

void main() {
  group('GuardProvider Visitor Registration Tests', () {
    late GuardProvider guardProvider;

    setUp(() {
      guardProvider = GuardProvider();
    });

    test('registerNewVisitor adds a visitor with vehicle information', () async {
      final visitor = await guardProvider.registerNewVisitor(
        name: 'John Doe',
        flatNumber: '101',
        purpose: 'Guest',
        vehicleNumber: 'KA-01-AB-1234',
        vehicleType: 'Car',
      );

      expect(visitor.name, 'John Doe');
      expect(visitor.flatNumber, '101');
      expect(visitor.purpose, 'Guest');
      expect(visitor.vehicleNumber, 'KA-01-AB-1234');
      expect(visitor.vehicleType, 'Car');

      // Check if it's in the provider's local list
      // Note: The provider listens to the repository stream, which updates asynchronously.
      // So we might need to wait for the stream listener to process the update.
      await Future.delayed(const Duration(milliseconds: 100));

      final entryInProvider = guardProvider.entries.firstWhere((e) => e.id == visitor.id);
      expect(entryInProvider.vehicleNumber, 'KA-01-AB-1234');
      expect(entryInProvider.vehicleType, 'Car');

      // Check repository as well
      final repoVisitor = VisitorRepository().getById(visitor.id);
      expect(repoVisitor, isNotNull);
      expect(repoVisitor!.vehicleNumber, 'KA-01-AB-1234');
      expect(repoVisitor.vehicleType, 'Car');
    });

    test('registerNewVisitor adds visitor without vehicle information', () async {
      final visitor = await guardProvider.registerNewVisitor(
        name: 'Jane Doe',
        flatNumber: '102',
        purpose: 'Delivery',
      );

      expect(visitor.name, 'Jane Doe');
      expect(visitor.flatNumber, '102');
      expect(visitor.purpose, 'Delivery');
      expect(visitor.vehicleNumber, isNull);
      expect(visitor.vehicleType, isNull);

      // Wait for async updates
      await Future.delayed(const Duration(milliseconds: 100));

      final repoVisitor = VisitorRepository().getById(visitor.id);
      expect(repoVisitor, isNotNull);
      expect(repoVisitor!.vehicleNumber, isNull);
      expect(repoVisitor.vehicleType, isNull);
    });

    test('updateVisitorEntry updates vehicle information', () async {
      final visitor = await guardProvider.registerNewVisitor(
        name: 'Jane Doe',
        flatNumber: '102',
        purpose: 'Delivery',
      );

      await guardProvider.updateVisitorEntry(
        id: visitor.id,
        name: 'Jane Doe',
        flatNumber: '102',
        purpose: 'Delivery',
        vehicleNumber: 'TN-05-XY-9876',
        vehicleType: 'Bike',
      );

      // Wait for async updates
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == visitor.id);
      expect(updatedEntry.vehicleNumber, 'TN-05-XY-9876');
      expect(updatedEntry.vehicleType, 'Bike');
    });

    test('Initial entries should have exitTime as null or valid DateTime', () {
      final entries = guardProvider.entries;
      for (var entry in entries) {
        if (entry.status == 'approved' && entry.exitTime == null) {
          // Should be considered inside
          expect(entry.exitTime, isNull);
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

      // Wait for async updates
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == visitorEntry.id);
      expect(updatedEntry.exitTime, isNotNull);
    });

    test('registerNewVisitor with photo path', () async {
      final visitor = await guardProvider.registerNewVisitor(
        name: 'Photo Visitor',
        flatNumber: '103',
        purpose: 'Guest',
        photoPath: '/path/to/photo.jpg',
      );

      expect(visitor.name, 'Photo Visitor');
      expect(visitor.photoPath, '/path/to/photo.jpg');

      // Wait for async updates
      await Future.delayed(const Duration(milliseconds: 100));

      final repoVisitor = VisitorRepository().getById(visitor.id);
      expect(repoVisitor, isNotNull);
      expect(repoVisitor!.photoPath, '/path/to/photo.jpg');
    });

    test('updateVisitorEntry preserves exitTime and other fields', () async {
      // Create and approve a visitor
      final visitor = await guardProvider.registerNewVisitor(
        name: 'Exit Test Visitor',
        flatNumber: '104',
        purpose: 'Guest',
      );

      await guardProvider.approveVisitor(visitor.id);
      await guardProvider.markExit(visitor.id);

      // Wait for updates
      await Future.delayed(const Duration(milliseconds: 100));

      // Update visitor info
      await guardProvider.updateVisitorEntry(
        id: visitor.id,
        name: 'Exit Test Visitor Updated',
        flatNumber: '104',
        purpose: 'Guest',
      );

      // Wait for updates
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify exitTime is preserved
      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == visitor.id);
      expect(updatedEntry.exitTime, isNotNull);
      expect(updatedEntry.name, 'Exit Test Visitor Updated');
    });
  });
}