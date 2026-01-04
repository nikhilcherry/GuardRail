import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/guard_provider.dart';
import 'package:guardrail/repositories/visitor_repository.dart';

void main() {
  group('GuardProvider Photo Tests', () {
    late GuardProvider guardProvider;

    setUp(() {
      // Clear repository for each test if possible, or just create new provider
      // Since VisitorRepository is singleton, we should be careful.
      // Ideally we would reset it, but it doesn't expose a reset.
      // We will rely on unique IDs or just appending.
      guardProvider = GuardProvider();
    });

    test('registerNewVisitor should store photoPath', () async {
      const name = 'Test Visitor';
      const flatNumber = '101';
      const purpose = 'Guest';
      const photoPath = '/path/to/photo.jpg';

      final entry = await guardProvider.registerNewVisitor(
        name: name,
        flatNumber: flatNumber,
        purpose: purpose,
        photoPath: photoPath,
      );

      expect(entry.photoPath, equals(photoPath));
      expect(entry.name, equals(name));

      // Verify it's in the repository
      final shared = VisitorRepository().getById(entry.id);
      expect(shared, isNotNull);
      expect(shared!.photoPath, equals(photoPath));
    });

    test('updateVisitorEntry should update photoPath via repository', () async {
      // Create initial visitor
      final entry = await guardProvider.registerNewVisitor(
        name: 'Update Test',
        flatNumber: '102',
        purpose: 'Delivery',
        photoPath: '/original/path.jpg',
      );

      // Wait for initial registration to propagate
      await Future.delayed(Duration.zero);

      const newPhotoPath = '/new/path.jpg';

      // We need to wait for the listener to fire after update
      // We can listen to guardProvider or just check repository directly
      // Checking guardProvider.entries requires waiting for the stream

      await guardProvider.updateVisitorEntry(
        id: entry.id,
        name: 'Updated Name',
        flatNumber: '102',
        purpose: 'Delivery',
        photoPath: newPhotoPath,
      );

      // Wait for stream propagation
      // Since `updateVisitorEntry` has a delay and then calls repo, and repo notifies stream...
      // The `updateVisitorEntry` await finishes AFTER the delay but BEFORE the stream might have fully propogated back to `GuardProvider` if there was async gap.
      // However, `VisitorRepository.updateVisitor` is synchronous in adding to stream.
      // `GuardProvider` listener is synchronous.
      // So checking `guardProvider.entries` should be safe if we allow microtasks.
      await Future.delayed(Duration.zero);

      final updatedEntry = guardProvider.entries.firstWhere((e) => e.id == entry.id);
      expect(updatedEntry.photoPath, equals(newPhotoPath));
      expect(updatedEntry.name, equals('Updated Name'));

      // Verify repository
      final shared = VisitorRepository().getById(entry.id);
      expect(shared!.photoPath, equals(newPhotoPath));
    });
  });
}
