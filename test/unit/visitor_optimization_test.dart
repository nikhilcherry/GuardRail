import 'package:flutter_test/flutter_test.dart';
import 'package:stitch/models/visitor.dart';

void main() {
  group('Visitor Model Performance & Correctness', () {
    test('Visitor should be instantiated correctly from Firestore data', () {
      final data = {
        'name': 'John Doe',
        'flatId': '101',
        'purpose': 'guest',
        'status': 'approved',
        'arrivalTime': null, // Timestamp would be here
        'photoUrl': '/path/to/photo.jpg',
      };

      final visitor = Visitor.fromFirestore(data, '123');

      expect(visitor.id, '123');
      expect(visitor.name, 'John Doe');
      expect(visitor.status, VisitorStatus.approved);
      expect(visitor.photoPath, '/path/to/photo.jpg');
    });

    test('VisitorStatus should parse correctly', () {
      // Accessing private method via reflection or just testing behavior via factory
      final v1 = Visitor.fromFirestore({'status': 'approved'}, '1');
      expect(v1.status, VisitorStatus.approved);

      final v2 = Visitor.fromFirestore({'status': 'rejected'}, '2');
      expect(v2.status, VisitorStatus.rejected);

      final v3 = Visitor.fromFirestore({'status': 'pending'}, '3');
      expect(v3.status, VisitorStatus.pending);

      final v4 = Visitor.fromFirestore({'status': 'unknown'}, '4');
      expect(v4.status, VisitorStatus.pending);
    });
  });
}
