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
import 'l10n/app_localizations.dart';
import 'services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fallback if .env is missing (e.g. first run without setup)
    await dotenv.load(fileName: ".env.example");
  }

  // Initialize Firebase FIRST - before any Firebase services are used
  await Firebase.initializeApp();

  // Initialize crash reporting
  await CrashReportingService().init();

  // Now create repositories (after Firebase is initialized)
  final authRepository = AuthRepository();
  final settingsRepository = SettingsRepository();

  // Pre-load critical state
  final authProvider = AuthProvider(repository: authRepository);
  authProvider.checkLoginStatus();

  runApp(GuardrailApp(
    authProvider: authProvider,
    settingsRepository: settingsRepository,
  ));
}

class GuardrailApp extends StatefulWidget {
  final AuthProvider authProvider;
  final SettingsRepository settingsRepository;

  const GuardrailApp({
    Key? key,
    required this.authProvider,
    required this.settingsRepository,
  }) : super(key: key);

  @override
  State<GuardrailApp> createState() => _GuardrailAppState();
}

class _GuardrailAppState extends State<GuardrailApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.authProvider.lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(repository: widget.settingsRepository)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(repository: widget.settingsRepository)),
        ChangeNotifierProvider(create: (_) => FlatProvider()),
        ChangeNotifierProxyProvider<FlatProvider, AdminProvider>(
          create: (context) => AdminProvider(context.read<FlatProvider>()),
          update: (context, flatProvider, previous) => AdminProvider(flatProvider),
        ),
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
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
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
