import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/guard_provider.dart';
import 'providers/resident_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/settings_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/guard/guard_home_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/resident/resident_visitors_screen.dart';
import 'screens/resident/resident_settings_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_additional_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositories
  final authRepository = AuthRepository();
  final settingsRepository = SettingsRepository();

  // Pre-load critical state
  final authProvider = AuthProvider(repository: authRepository);
  await authProvider.checkLoginStatus();

  runApp(GuardrailApp(
    authProvider: authProvider,
    settingsRepository: settingsRepository,
  ));
}

class GuardrailApp extends StatelessWidget {
  final AuthProvider? authProvider;
  final SettingsRepository settingsRepository;

  const GuardrailApp({
    Key? key,
    this.authProvider,
    required this.settingsRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider ?? AuthProvider()),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(repository: settingsRepository)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(repository: settingsRepository)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Guardrail',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const RootScreen(),
            routes: {
              '/role_selection': (_) => const RoleSelectionScreen(),
              '/sign_up': (_) => const SignUpScreen(),
              '/forgot_password': (_) => const ForgotPasswordScreen(),
              '/guard_home': (_) => const GuardHomeScreen(),
              '/resident_home': (_) => const ResidentHomeScreen(),
              '/admin_dashboard': (_) => const AdminDashboardScreen(),
              '/resident_visitors': (_) => const ResidentVisitorsScreen(),
              '/resident_settings': (_) => const ResidentSettingsScreen(),
              '/admin_flats': (_) => const AdminFlatsScreen(),
              '/admin_guards': (_) => const AdminGuardsScreen(),
              '/admin_visitor_logs': (_) => const AdminVisitorLogsScreen(),
              '/admin_activity_logs': (_) => const AdminActivityLogsScreen(),
              '/admin_settings': (_) => const AdminSettingsScreen(),
            },
          );
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
        // Navigation logic based on auth state
        if (authProvider.selectedRole == null) {
          return const RoleSelectionScreen();
        }

        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
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
            return const LoginScreen();
        }
      },
    );
  }
}
