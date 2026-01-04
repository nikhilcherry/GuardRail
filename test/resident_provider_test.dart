
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/resident_provider.dart';

void main() {
  group('ResidentProvider Optimization Tests', () {
    late ResidentProvider provider;

    setUp(() {
      provider = ResidentProvider();
    });

    test('allVisitors should return sorted list', () {
      final visitors = provider.allVisitors;
      expect(visitors, isNotEmpty);

      // Verify sorting (descending date)
      for (int i = 0; i < visitors.length - 1; i++) {
        expect(
          visitors[i].date.isAfter(visitors[i + 1].date) ||
          visitors[i].date.isAtSameMomentAs(visitors[i + 1].date),
          isTrue
        );
      }
    });

    test('allVisitors should be cached (identity check)', () {
      final list1 = provider.allVisitors;
      final list2 = provider.allVisitors;

      // Bolt optimization: The list should now be cached, so subsequent calls return the exact same instance.
      expect(list1, same(list2), reason: "Optimized: Subsequent calls should return the cached list instance");
    });
  });
}
