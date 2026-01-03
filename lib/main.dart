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
import 'providers/admin_provider.dart';
import 'providers/flat_provider.dart';
import 'router/app_router.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositories
  final authRepository = AuthRepository();
  final settingsRepository = SettingsRepository();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fallback if .env is missing (e.g. first run without setup)
    await dotenv.load(fileName: ".env.example");
  }

  await Firebase.initializeApp();

  // Initialize crash reporting
  await CrashReportingService().init();

  // Pre-load critical state
  final authProvider = AuthProvider(repository: authRepository);
  await authProvider.checkLoginStatus();

  runApp(GuardrailApp(
    authProvider: authProvider,
    settingsRepository: settingsRepository,
  ));
}

class GuardrailApp extends StatelessWidget {
  final AuthProvider authProvider;
  final SettingsRepository settingsRepository;

  const GuardrailApp({
    Key? key,
    required this.authProvider,
    required this.settingsRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(repository: settingsRepository)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(repository: settingsRepository)),
        ChangeNotifierProxyProvider<FlatProvider, AdminProvider>(
          create: (context) => AdminProvider(context.read<FlatProvider>()),
          update: (context, flatProvider, previous) => AdminProvider(flatProvider),
        ),
        ChangeNotifierProvider(create: (_) => FlatProvider()),
      ],
      child: Builder(
        builder: (context) {
          // We need to read AuthProvider from context to pass it to AppRouter,
          // or just use the one we have in the widget if we prefer.
          // Using context.read ensures we get the one from Provider tree.
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
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        // This widget is actually not used if we use GoRouter redirection,
        // but keeping it valid just in case.
        return const Scaffold(body: Center(child: Text("Home")));
      },
    );
  }
}
