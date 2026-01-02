import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.security_outlined,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Panel',
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Icon(
                  Icons.logout,
                  color: theme.textTheme.bodySmall?.color,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final pendingCount = adminProvider.guards.where((g) => g['status'] == 'pending').length;
          final activeGuards = adminProvider.guards.where((g) => g['status'] == 'active').length;
          final totalFlats = adminProvider.flats.length;

          return Column(
            children: [
              // Dashboard Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dashboard',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          label: 'Total Flats',
                          value: '$totalFlats',
                          icon: Icons.apartment_outlined,
                        ),
                        _StatCard(
                          label: 'Active Guards',
                          value: '$activeGuards',
                          icon: Icons.security_outlined,
                          highlighted: true,
                        ),
                        // Removed Visitor Stats as we are cleaning up placeholders
                        _StatCard(
                          label: 'Pending Approvals',
                          value: '$pendingCount',
                          icon: Icons.pending_actions_outlined,
                          isPrimary: true,
                          onTap: () => context.go('/admin_dashboard/guards'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const _AdminBottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlighted;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlighted = false,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isPrimary
        ? theme.colorScheme.primary.withOpacity(0.1)
        : highlighted
            ? theme.cardColor
            : theme.cardColor;

    final borderColor = isPrimary
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.dividerColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                  ),
                ),
                Icon(
                  icon,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
                  size: 28,
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(
                color: isPrimary ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const _AdminBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.textTheme.bodySmall?.color,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment_outlined),
          label: 'Flats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.security),
          label: 'Guards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            context.go('/admin_dashboard');
            break;
          case 1:
            context.go('/admin_dashboard/flats');
            break;
          case 2:
            context.go('/admin_dashboard/guards');
            break;
          case 3:
            context.go('/admin_dashboard/settings');
            break;
        }
      },
    );
  }
}
