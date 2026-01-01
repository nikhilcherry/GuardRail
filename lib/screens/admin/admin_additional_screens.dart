import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';

class AdminFlatsScreen extends StatelessWidget {
  const AdminFlatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold(
      title: 'Flats',
      body: ComingSoonView(
        title: 'Flats Management',
        message: 'Configure families, units, and resident details here.',
        icon: Icons.apartment_outlined,
      ),
      currentIndex: 1,
    );
  }
}

class AdminGuardsScreen extends StatelessWidget {
  const AdminGuardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold(
      title: 'Guards',
      body: ComingSoonView(
        title: 'Guard Management',
        message: 'Assign, enable or disable guard accounts and manage shifts.',
        icon: Icons.security_outlined,
      ),
      currentIndex: 2,
    );
  }
}

class AdminVisitorLogsScreen extends StatelessWidget {
  const AdminVisitorLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold(
      title: 'Visitor Logs',
      body: ComingSoonView(
        title: 'Visitor Logs',
        message: 'Review all visitor entries and filter by flat, guard or status.',
        icon: Icons.history_outlined,
      ),
      currentIndex: 3,
    );
  }
}

class AdminActivityLogsScreen extends StatelessWidget {
  const AdminActivityLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold(
      title: 'Activity Logs',
      body: ComingSoonView(
        title: 'System Activity',
        message: 'Full audit trail of system activity will appear here.',
        icon: Icons.list_alt_outlined,
      ),
      currentIndex: 3,
    );
  }
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _AdminScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsTile(
            icon: Icons.tune,
            label: 'Gate configuration',
            onTap: () {
              showComingSoonDialog(
                context,
                title: 'Gate Configuration',
                message: 'Advanced gate settings and hardware integration options are coming soon.',
              );
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            label: 'Alerts & notifications',
            onTap: () {
              showComingSoonDialog(
                context,
                title: 'Alert Settings',
                message: 'Customize system-wide alerts and notification preferences.',
              );
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.security_outlined,
            label: 'Security policies',
            onTap: () {
              showComingSoonDialog(
                context,
                title: 'Security Policies',
                message: 'Define and manage security protocols and access levels.',
              );
            },
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Logout',
            isDestructive: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.dialogBackgroundColor,
                  title: Text(
                    'Logout',
                    style: theme.textTheme.headlineSmall,
                  ),
                  content: Text(
                    'Are you sure you want to logout as Admin?',
                    style: theme.textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pop(context);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const RootScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Logout',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      currentIndex: 4,
    );
  }
}

class _AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;

  const _AdminScaffold({
    required this.title,
    required this.body,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.textTheme.bodySmall?.color,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
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
            icon: Icon(Icons.group_outlined),
            label: 'Visitors',
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
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/admin_flats');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/admin_guards');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/admin_visitor_logs');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/admin_settings');
              break;
          }
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? theme.colorScheme.error : theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDestructive
                        ? theme.colorScheme.error
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
