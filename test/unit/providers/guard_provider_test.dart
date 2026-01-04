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

      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == visitor.id);
      expect(updatedEntry.vehicleNumber, 'TN-05-XY-9876');
      expect(updatedEntry.vehicleType, 'Bike');
    });
  });
}
