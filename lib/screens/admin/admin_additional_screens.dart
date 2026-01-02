import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/guard_provider.dart';
import '../../main.dart';

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
  void _showAddGuardDialog(AdminProvider provider) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Guard Invite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the name for the new guard profile. A unique Guard ID will be generated.'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Guard Name',
                border: OutlineInputBorder(),
              ),
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
              if (nameController.text.trim().isNotEmpty) {
                final id = provider.createGuardInvite(nameController.text.trim());
                Navigator.pop(context); // Close input dialog

                // Show Generated ID
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Guard Created'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Share this ID with the guard to allow them to enroll.'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            id,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final guards = adminProvider.guards;

        return _AdminScaffold(
          title: 'Guards',
          currentIndex: 2,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddGuardDialog(adminProvider),
            icon: const Icon(Icons.add),
            label: const Text('Create Guard'),
          ),
          body: guards.isEmpty
            ? const Center(child: Text('No guards found'))
            : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: guards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final guard = guards[index];
              final status = guard['status'] as String;
              final isPending = status == 'pending';

              Color statusColor;
              switch (status) {
                case 'active': statusColor = Colors.green; break;
                case 'pending': statusColor = Colors.orange; break;
                case 'rejected': statusColor = Colors.red; break;
                default: statusColor = Colors.grey;
              }

              return ListTile(
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.security, color: statusColor),
                ),
                title: Text(guard['name'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${guard['id']}'),
                    if (guard['linkedUserName'] != null)
                      Text('User: ${guard['linkedUserName']} (${guard['linkedUserEmail']})'),
                    Text('Status: ${status.toUpperCase()}', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                isThreeLine: true,
                trailing: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          tooltip: 'Approve',
                          onPressed: () => adminProvider.approveGuard(guard['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          tooltip: 'Reject',
                          onPressed: () => adminProvider.rejectGuard(guard['id']),
                        ),
                      ],
                    )
                  : IconButton(
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
                                  adminProvider.deleteGuard(guard['id']);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              );
            },
          ),
        );
      },
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
      currentIndex: 3, // Adjusted index since Logs are removed
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Removed "Coming Soon" settings for cleanup
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
