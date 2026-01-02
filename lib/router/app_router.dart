import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/id_verification_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/guard/guard_home_screen.dart';
import '../screens/resident/resident_home_screen.dart';
import '../screens/resident/resident_visitors_screen.dart';
import '../screens/resident/resident_settings_screen.dart';
import '../screens/resident/flat_management_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_additional_screens.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/id_verification',
        builder: (context, state) => const IDVerificationScreen(),
      ),
      GoRoute(
        path: '/guard_home',
        builder: (context, state) => const GuardHomeScreen(),
      ),
      GoRoute(
        path: '/resident_home',
        builder: (context, state) => const ResidentHomeScreen(),
        routes: [
          GoRoute(
            path: 'visitors',
            builder: (context, state) => const ResidentVisitorsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const ResidentSettingsScreen(),
          ),
          GoRoute(
            path: 'flat',
            builder: (context, state) => const FlatManagementScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'flats',
            builder: (context, state) => const AdminFlatsScreen(),
          ),
          GoRoute(
            path: 'guards',
            builder: (context, state) => const AdminGuardsScreen(),
          ),
          GoRoute(
            path: 'visitor_logs',
            builder: (context, state) => const AdminVisitorLogsScreen(),
          ),
          GoRoute(
            path: 'activity_logs',
            builder: (context, state) => const AdminActivityLogsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isVerified = authProvider.isVerified;
      final selectedRole = authProvider.selectedRole;

      final currentPath = state.uri.toString();
      final isLoggingIn = currentPath == '/login';
      final isRoleSelection = currentPath == '/';
      final isSignUp = currentPath == '/sign_up';
      final isVerification = currentPath == '/id_verification';

      // If logged in
      if (isLoggedIn) {
        // If not verified and trying to go somewhere other than verification, redirect to verification.
        // We exclude admin from this check if we assume admins don't need this flow,
        // but based on implementation, register sets isVerified=false.
        // If role is admin, let's assume auto-verified or handled elsewhere, but for now we enforce it if it's false.
        // Actually, let's assume only Guard and Resident need this screen as requested.
        bool requiresVerification = selectedRole == 'guard' || selectedRole == 'resident';

        if (requiresVerification && !isVerified) {
           if (!isVerification) {
             return '/id_verification';
           }
           return null; // Stay on verification
        }

        // If verified (or not required), but trying to access auth/verification screens, redirect to home.
        if (isLoggingIn || isRoleSelection || isSignUp || isVerification) {
          switch (selectedRole) {
            case 'guard':
              return '/guard_home';
            case 'resident':
              return '/resident_home';
            case 'admin':
              return '/admin_dashboard';
            default:
              return '/resident_home';
          }
        }
      } else {
        // If not logged in
        // If trying to access protected routes, redirect to welcome screen
        final publicRoutes = ['/', '/login', '/sign_up', '/forgot_password'];
        if (!publicRoutes.contains(currentPath)) {
           return '/';
        }
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
