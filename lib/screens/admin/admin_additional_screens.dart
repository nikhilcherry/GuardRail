import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/guard_provider.dart';
import '../../main.dart'; // To access RootScreen

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
          currentIndex: 1,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditFlatDialog(adminProvider),
            child: const Icon(Icons.add),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.flats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flat = adminProvider.flats[index];
              final residentId = flat['residentId'] ?? '';
              final hasId = residentId.isNotEmpty;
              return ListTile(
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.home),
                title: Text('Flat ${flat['flat']}'),
                subtitle: Text('${flat['resident']} • ID: ${hasId ? residentId : 'Not Generated'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!hasId)
                      IconButton(
                        icon: const Icon(Icons.autorenew),
                        tooltip: 'Generate ID',
                        onPressed: () => adminProvider.generateResidentId(index),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate ID',
                        onPressed: () => adminProvider.generateResidentId(index),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditFlatDialog(adminProvider, flat: flat, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Flat'),
                            content: Text('Are you sure you want to delete Flat ${flat['flat']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  adminProvider.deleteFlat(index);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
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
          currentIndex: 2,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditGuardDialog(adminProvider),
            child: const Icon(Icons.add),
          ),
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
                subtitle: Text('ID: ${guard['id']} (Status: ${guard['status']})'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditGuardDialog(adminProvider, guard: guard, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Guard'),
                            content: Text('Are you sure you want to delete ${guard['name']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  adminProvider.deleteGuard(index);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
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
      title: 'Visitor Logs',
      currentIndex: 3,
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
    );
  }
}

class AdminActivityLogsScreen extends StatelessWidget {
  const AdminActivityLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AdminScaffold(
      title: 'Activity Logs',
      currentIndex: 3, // Grouped with logs
      body: ComingSoonView(
        title: 'System Activity',
        message: 'Full audit trail of system activity will appear here.',
        icon: Icons.list_alt_outlined,
      ),
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
      currentIndex: 4,
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
                  title: Text(
                    'Logout',
                    style: theme.textTheme.headlineSmall,
                  ),
                  content: const Text(
                    'Are you sure you want to logout as Admin?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pop(context); // Close dialog
                        context.go('/');
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
        title: Text(title),
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
            icon: Icon(Icons.history),
            label: 'Logs',
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
              context.go('/admin_dashboard/visitor_logs');
              break;
            case 4:
              context.go('/admin_dashboard/settings');
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
