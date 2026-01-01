import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/guard_provider.dart';

class AdminFlatsScreen extends StatefulWidget {
  const AdminFlatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminFlatsScreen> createState() => _AdminFlatsScreenState();
}

class _AdminFlatsScreenState extends State<AdminFlatsScreen> {
  void _showAddEditFlatDialog(AdminProvider provider, {Map<String, String>? flat, int? index}) {
    final isEditing = flat != null;
    final flatController = TextEditingController(text: flat?['flat'] ?? '');
    final residentController = TextEditingController(text: flat?['resident'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Flat' : 'Add Flat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: flatController,
              decoration: const InputDecoration(labelText: 'Flat Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: residentController,
              decoration: const InputDecoration(labelText: 'Resident Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isEditing) {
                provider.updateFlat(
                  index!,
                  flatController.text,
                  residentController.text,
                );
              } else {
                provider.addFlat(
                  flatController.text,
                  residentController.text,
                );
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return _AdminScaffold(
          title: 'Flats',
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.flats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flat = adminProvider.flats[index];
              return ListTile(
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.home),
                title: Text('Flat ${flat['flat']}'),
                subtitle: Text(flat['resident']!),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditFlatDialog(adminProvider, flat: flat, index: index),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditFlatDialog(adminProvider),
            child: const Icon(Icons.add),
          ),
          currentIndex: 1,
        );
      },
    );
  }
}

class AdminGuardsScreen extends StatefulWidget {
  const AdminGuardsScreen({Key? key}) : super(key: key);

  @override
  State<AdminGuardsScreen> createState() => _AdminGuardsScreenState();
}

class _AdminGuardsScreenState extends State<AdminGuardsScreen> {
  void _showAddEditGuardDialog(AdminProvider provider, {Map<String, String>? guard, int? index}) {
    final isEditing = guard != null;
    final nameController = TextEditingController(text: guard?['name'] ?? '');
    final idController = TextEditingController(text: guard?['id'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Guard' : 'Add Guard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Guard ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isEditing) {
                provider.updateGuard(
                  index!,
                  nameController.text,
                  idController.text,
                );
              } else {
                provider.addGuard(
                  nameController.text,
                  idController.text,
                );
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return _AdminScaffold(
          title: 'Guards',
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.guards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final guard = adminProvider.guards[index];
              return ListTile(
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.security),
                title: Text(guard['name']!),
                subtitle: Text('ID: ${guard['id']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditGuardDialog(adminProvider, guard: guard, index: index),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditGuardDialog(adminProvider),
            child: const Icon(Icons.add),
          ),
          currentIndex: 2,
        );
      },
    );
  }
}

class AdminVisitorLogsScreen extends StatelessWidget {
  const AdminVisitorLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final guardProvider = Provider.of<GuardProvider>(context);

    // Combine logs from different sources
    final List<Map<String, dynamic>> logs = [];

    // Add Patrol Logs
    for (var date in guardProvider.patrolLogs) {
      logs.add({
        'action': 'Patrol Check',
        'user': 'Guard',
        'details': 'Checkpoint Recorded',
        'time': date,
      });
    }

    // Add Entry Logs
    for (var entry in guardProvider.entries) {
      logs.add({
        'action': 'Visitor ${entry.status == 'approved' ? 'Entry' : 'Request'}',
        'user': entry.guardName ?? 'Guard',
        'details': '${entry.name} (${entry.purpose}) -> Flat ${entry.flatNumber}',
        'time': entry.time,
      });
    }

    // Sort by time descending
    logs.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return _AdminScaffold(
      title: 'Audit Logs',
      body: logs.isEmpty
        ? Center(child: Text('No activity logs found', style: Theme.of(context).textTheme.bodyMedium))
        : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = logs[index];
            return ListTile(
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
              title: Text(log['action']),
              subtitle: Text('${log['user']} • ${log['details']}'),
              trailing: Text(
                DateFormat('MMM d, h:mm a').format(log['time']),
                style: Theme.of(context).textTheme.bodySmall
              ),
            );
          },
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
  final FloatingActionButton? floatingActionButton;

  const _AdminScaffold({
    required this.title,
    required this.body,
    required this.currentIndex,
    this.floatingActionButton,
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
      floatingActionButton: floatingActionButton,
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
            icon: Icon(Icons.history), // Changed from group_outlined to history
            label: 'Logs', // Changed from Visitors to Logs
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
