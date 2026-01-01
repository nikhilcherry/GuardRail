import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';

class AdminFlatsScreen extends StatelessWidget {
  const AdminFlatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Flats',
      body: Center(
        child: Text(
          'Flats management coming soon.\nConfigure families and units here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      currentIndex: 1,
    );
  }
}

class AdminGuardsScreen extends StatelessWidget {
  const AdminGuardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Guards',
      body: Center(
        child: Text(
          'Assign, enable or disable guard accounts here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      currentIndex: 2,
    );
  }
}

class AdminVisitorLogsScreen extends StatelessWidget {
  const AdminVisitorLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Visitor Logs',
      body: Center(
        child: Text(
          'Review all visitor entries and filter by flat, guard or status.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      currentIndex: 3,
    );
  }
}

class AdminActivityLogsScreen extends StatelessWidget {
  const AdminActivityLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Activity Logs',
      body: Center(
        child: Text(
          'Full audit trail of system activity will appear here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
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
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            icon: Icons.tune,
            label: 'Gate configuration',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gate configuration coming soon')),
              );
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            label: 'Alerts & notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alerts settings coming soon')),
              );
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.security_outlined,
            label: 'Security policies',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security policies coming soon')),
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
