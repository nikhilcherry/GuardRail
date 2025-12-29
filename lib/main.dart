import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/guard_provider.dart';
import 'providers/resident_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/guard/guard_home_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
// Note: ResidentVisitorsScreen, ResidentSettingsScreen, etc. are placeholders
// or to be implemented. I will create placeholder classes for them if they were used in main.dart
// But for now, I'll rely on the dashboard screens handling internal nav state or routes.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuardrailApp());
}

class GuardrailApp extends StatelessWidget {
  const GuardrailApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
      ],
      child: MaterialApp(
        title: 'Guardrail',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const RootScreen(),
        // Define routes if necessary, but RootScreen handles auth state.
        routes: {
          '/role_selection': (_) => const RoleSelectionScreen(),
          '/guard_home': (_) => const GuardHomeScreen(),
          '/resident_home': (_) => const ResidentHomeScreen(),
          '/admin_dashboard': (_) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If not logged in, show Role Selection (The "Entry" screen)
        if (!authProvider.isLoggedIn) {
          return const RoleSelectionScreen();
        }
        
        // If logged in, check role
        if (authProvider.selectedRole == null) {
          // Should not happen if isLoggedIn is true, but fallback
          return const RoleSelectionScreen();
        }

        // Route based on selected role
        switch (authProvider.selectedRole) {
          case 'guard':
            return const GuardHomeScreen();
          case 'resident':
            return const ResidentHomeScreen();
          case 'admin':
            return const AdminDashboardScreen();
          default:
            return const RoleSelectionScreen();
        }
      },
    );
  }
}
