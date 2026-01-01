import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/auth_provider.dart';
import 'package:guardrail/providers/resident_provider.dart';
import 'package:guardrail/screens/resident/resident_home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('ResidentHomeScreen Widget Tests', () {
    late ResidentProvider residentProvider;
    late AuthProvider authProvider;

    setUp(() {
      residentProvider = ResidentProvider();
      authProvider = AuthProvider();
    });

    Widget createScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: residentProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: ResidentHomeScreen(),
        ),
      );
    }

    testWidgets('Displays greeting and flat number', (WidgetTester tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Good Evening,'), findsOneWidget);
      expect(find.text('Flat 101'), findsOneWidget); // Default flat number
    });

    testWidgets('Displays empty state when no pending requests', (WidgetTester tester) async {
      // Clear pending requests
      residentProvider.pendingVisitors.clear();

      await tester.pumpWidget(createScreen());

      expect(find.text('Pending Request'), findsNothing);
    });

    testWidgets('Displays bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Visitors'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
