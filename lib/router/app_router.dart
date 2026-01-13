import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/id_verification_screen.dart';
import '../screens/auth/lock_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/guard/guard_home_screen.dart';
import '../screens/resident/resident_home_screen.dart';
import '../screens/resident/resident_visitors_screen.dart';
import '../screens/resident/resident_settings_screen.dart';
import '../screens/resident/flat_management_screen.dart';
import '../screens/resident/generate_qr_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_flats_screen.dart';
import '../screens/admin/admin_guards_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/society_setup_screen.dart';
import '../screens/shared/visitor_details_screen.dart';

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
        path: '/visitor_details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final source = state.uri.queryParameters['source'] ?? 'resident';
          return VisitorDetailsScreen(visitorId: id, source: source);
        },
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
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
          GoRoute(
            path: 'generate_qr',
            builder: (context, state) => const GenerateQRScreen(),
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
          // Removed Logs Routes
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin_society_setup',
        builder: (context, state) => const SocietySetupScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isVerified = authProvider.isVerified;
      final selectedRole = authProvider.selectedRole;
      final isAppLocked = authProvider.isAppLocked;

      final currentPath = state.uri.toString();

      // Lock Logic
      if (isAppLocked) {
        if (currentPath != '/lock') {
          return '/lock';
        }
        return null;
      } else if (currentPath == '/lock') {
        // If unlocked but still on lock screen, redirect to home
         if (isLoggedIn) {
            // Re-evaluate redirect logic below to find correct home
         } else {
            return '/';
         }
      }

      final isLoggingIn = currentPath == '/login';
      final isRoleSelection = currentPath == '/';
      final isSignUp = currentPath == '/sign_up';
      final isVerification = currentPath == '/id_verification';

      // If logged in
      if (isLoggedIn) {
        // If not verified and trying to go somewhere other than verification, redirect to verification.
        // For guards, isVerified is false until approved. ID Verification screen will handle the "Pending" message.
        bool requiresVerification = selectedRole == 'guard' || selectedRole == 'resident';

        if (requiresVerification && !isVerified) {
           if (!isVerification) {
             return '/id_verification';
           }
           return null; // Stay on verification
        }

        // If verified (or not required), but trying to access auth/verification screens, redirect to home.
        if (isLoggingIn || isRoleSelection || isSignUp || isVerification || currentPath == '/lock') {
          switch (selectedRole) {
            case 'guard':
              return '/guard_home';
            case 'resident':
              return '/resident_home';
            case 'admin':
              return authProvider.hasSociety ? '/admin_dashboard' : '/admin_society_setup';
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