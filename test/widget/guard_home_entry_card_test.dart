import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentinel/l10n/app_localizations.dart';
import 'package:sentinel/screens/guard/guard_home_screen.dart';
import 'package:sentinel/providers/guard_provider.dart';
import 'package:sentinel/providers/auth_provider.dart';

// Mock AuthProvider
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  Future<void> login(String email, String password, String role) async {}
  @override
  Future<void> logout() async {}
  @override
  bool get isAuthenticated => true;
  @override
  String? get role => 'guard';
  @override
  bool get isLoading => false;
  @override
  String? get userToken => 'token';

  @override
  Future<bool> checkAuthStatus() async => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock GuardProvider
class MockGuardProvider extends GuardProvider {
  @override
  bool get isLoading => false;
}

void main() {
  testWidgets('GuardHomeScreen renders entry cards', (WidgetTester tester) async {
    // Override HTTP overrides to avoid network calls during test if any image network
    HttpOverrides.global = null;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
          ChangeNotifierProvider<GuardProvider>(create: (_) => MockGuardProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const GuardHomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify at least one entry card is present (based on GuardProvider's default mock data)
    // The text 'John Doe' is in the default mock data of GuardProvider
    expect(find.text('John Doe'), findsOneWidget);

    // We can also find the image widgets.
    // Since we can't easily check ResizeImage properties in a widget test without complex reflection,
    // we primarily ensure no exceptions are thrown during build.
  });
}
