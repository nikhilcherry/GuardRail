// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardrail/main.dart';

void main() {
  testWidgets('App starts with Role Selection Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GuardrailApp());

    // Verify that the role selection screen is displayed.
    // The initial screen says "Continue as" (or "Sign up as" depending on default state,
    // but default is _isSignUpMode = false -> "Continue as")
    expect(find.text('Continue as'), findsOneWidget);

    // Verify roles are present
    expect(find.text('Resident'), findsOneWidget);
    expect(find.text('Guard'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
