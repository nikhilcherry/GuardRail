import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardrail/widgets/contact_support_dialog.dart';

void main() {
  testWidgets('ContactSupportDialog has maxLength on issue TextField', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ContactSupportDialog(),
      ),
    );

    // Find the TextField
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // Verify properties
    final TextField textField = tester.widget(textFieldFinder);
    expect(textField.maxLength, 1000, reason: 'TextField should have maxLength of 1000');
  });
}
