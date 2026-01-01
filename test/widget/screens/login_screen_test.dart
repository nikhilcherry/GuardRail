import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/providers/auth_provider.dart';
import 'package:guardrail/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    Widget createLoginScreen() {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/forgot_password': (context) => const Scaffold(body: Text('Forgot Password Screen')),
            '/sign_up': (context) => const Scaffold(body: Text('Sign Up Screen')),
          },
        ),
      );
    }

    testWidgets('Displays default UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Check for title (default is User Login if role not selected)
      expect(find.text('User Login'), findsOneWidget);

      // Check for Phone input by default
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Check for "Use email instead" button
      expect(find.text('Use email instead'), findsOneWidget);
    });

    testWidgets('Switches to Email input', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap "Use email instead"
      await tester.tap(find.text('Use email instead'));
      await tester.pump();

      // Check for Email and Password inputs
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields

      // Check button changes to "Use phone instead"
      expect(find.text('Use phone instead'), findsOneWidget);
    });

    testWidgets('Shows validation error for empty phone number', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap Log In without entering phone
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // Check for SnackBar with error message
      expect(find.text('Please enter your phone number'), findsOneWidget);
    });

    testWidgets('Shows OTP input after phone entry', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter phone number
      await tester.enterText(find.byType(TextField), '1234567890');

      // Tap Log In
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // Check for OTP input field
      expect(find.text('One-Time Password'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget); // Button text changes
    });
  });
}
