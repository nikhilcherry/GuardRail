import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/resident_provider.dart';
import 'package:guardrail/repositories/visitor_repository.dart';
import 'package:guardrail/models/visitor.dart';

class MockVisitorRepository implements VisitorRepository {
  final _controller = StreamController<List<Visitor>>.broadcast();

  @override
  Stream<List<Visitor>> get visitorStream => _controller.stream;

  @override
  void initialize() {}

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<String> addVisitor(Visitor visitor) async => 'id';
  @override
  Visitor? getById(String id) => null;
  @override
  List<Visitor> get visitors => [];
  @override
  Future<void> loadVisitors() async {}
  @override
  Future<void> markExit(String id) async {}
  @override
  void updateVisitor(String id, {String? name, String? flatNumber, String? purpose, String? photoPath, String? vehicleNumber, String? vehicleType}) {}
  @override
  Future<void> updateStatus(String id, VisitorStatus status) async {}
}

void main() {
  group('ResidentProvider Performance', () {
    late ResidentProvider residentProvider;
    late MockVisitorRepository mockRepository;

    setUp(() {
      mockRepository = MockVisitorRepository();
      residentProvider = ResidentProvider(visitorRepository: mockRepository);
    });

    test('groupedVisitors caches results', () {
      final date1 = DateTime.utc(2024, 5, 20);
      final date2 = DateTime.utc(2024, 5, 21);

      final v1 = ResidentVisitor(
        id: '1', name: 'A', type: 'guest', status: 'approved', date: date1);
      final v2 = ResidentVisitor(
        id: '2', name: 'B', type: 'guest', status: 'approved', date: date1);
      final v3 = ResidentVisitor(
        id: '3', name: 'C', type: 'guest', status: 'approved', date: date2);

      // Use the visibleForTesting method to inject data and verify cache logic
      residentProvider.setVisitorsForTest([v1, v2, v3]);

      // First call - should compute
      final group1 = residentProvider.groupedVisitors;
      expect(group1.keys.length, 2);
      expect(group1[date1]!.length, 2);
      expect(group1[date2]!.length, 1);

      // Second call - should be same instance (cached)
      final group2 = residentProvider.groupedVisitors;
      expect(identical(group1, group2), isTrue);

      // Update visitors - should invalidate cache
      final v4 = ResidentVisitor(
        id: '4', name: 'D', type: 'guest', status: 'approved', date: date1);

      residentProvider.setVisitorsForTest([v1, v2, v3, v4]);

      final group3 = residentProvider.groupedVisitors;
      expect(group3[date1]!.length, 3);
      expect(identical(group1, group3), isFalse);
    });
  });
}
