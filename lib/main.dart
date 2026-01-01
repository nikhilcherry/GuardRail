import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/guard_provider.dart';
import 'providers/resident_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/settings_repository.dart';
import 'router/app_router.dart';
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
import 'services/crash_reporting_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositories
  final authRepository = AuthRepository();
  final settingsRepository = SettingsRepository();

  // Pre-load critical state
  final authProvider = AuthProvider(repository: authRepository);
  await Firebase.initializeApp();
  runApp(const GuardrailApp());

  // Initialize crash reporting
  await CrashReportingService().init();

  final authProvider = AuthProvider();
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
  const GuardrailApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(repository: settingsRepository)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(repository: settingsRepository)),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.read<AuthProvider>();
          final appRouter = AppRouter(authProvider);

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp.router(
                title: 'Guardrail',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                debugShowCheckedModeBanner: false,
                routerConfig: appRouter.router,
              );
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
        // Show loading if auth status is not yet determined
        if (authProvider.isInitializing) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigation logic based on auth state
        if (authProvider.selectedRole == null) {
          return const RoleSelectionScreen();
        }

        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }
      ),
    );
  }
}
