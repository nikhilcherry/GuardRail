import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/guard/guard_home_screen.dart';
import '../screens/resident/resident_home_screen.dart';
import '../screens/resident/resident_visitors_screen.dart';
import '../screens/resident/resident_settings_screen.dart';
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
        builder: (context, state) => const RoleSelectionScreen(),
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
      final selectedRole = authProvider.selectedRole;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRoleSelection = state.uri.toString() == '/';
      final isSignUp = state.uri.toString() == '/sign_up';

      // If logged in, redirect to respective home if trying to access auth screens
      if (isLoggedIn) {
        if (isLoggingIn || isRoleSelection || isSignUp) {
          switch (selectedRole) {
            case 'guard':
              return '/guard_home';
            case 'resident':
              return '/resident_home';
            case 'admin':
              return '/admin_dashboard';
            default:
              // If logged in but no role, maybe we should stay on Welcome or show an error?
              // Or force role selection? But we removed standalone role selection.
              // We'll redirect to Resident Home as a safe fallback or stay at root.
              // For now, let's assume valid role. If not, maybe log out.
              return '/resident_home';
          }
        }
      } else {
        // If not logged in
        // If trying to access protected routes, redirect to welcome screen
        final publicRoutes = ['/', '/login', '/sign_up', '/forgot_password'];
        if (!publicRoutes.contains(state.uri.toString())) {
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
