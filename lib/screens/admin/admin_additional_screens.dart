import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../widgets/coming_soon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/guard_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../main.dart';
import '../../utils/validators.dart';

class AdminFlatsScreen extends StatefulWidget {
  const AdminFlatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminFlatsScreen> createState() => _AdminFlatsScreenState();
}

class _AdminFlatsScreenState extends State<AdminFlatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final pendingFlats = adminProvider.pendingFlats;
        final activeFlats = adminProvider.activeFlats;
        final allFlats = adminProvider.flats;

        return _AdminScaffold(
          title: 'Flats',
          currentIndex: 1,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    _AdminFlatDialog(provider: adminProvider),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Container(
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.bodySmall?.color,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    Tab(text: 'Requests (${pendingFlats.length})'),
                    Tab(text: 'Active (${activeFlats.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pending Requests
                    pendingFlats.isEmpty
                        ? const Center(
                            child: Text('No pending requests'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pendingFlats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final flat = pendingFlats[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            flat.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                            ),
                                            child: const Text(
                                              'PENDING',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Owner ID: ${flat.ownerId}'),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit),
                                            tooltip: 'Edit Request',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => _EditNameDialog(
                                                  title: 'Edit Request Details',
                                                  label: 'Flat Name',
                                                  initialValue: flat.name,
                                                  onSave: (val) {
                                                    adminProvider.updateFlatName(flat.id, val);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  adminProvider
                                                      .rejectFlat(
                                                          flat.id),
                                              style: OutlinedButton
                                                  .styleFrom(
                                                foregroundColor:
                                                    Colors.red,
                                                side: const BorderSide(
                                                    color:
                                                        Colors.red),
                                              ),
                                              child:
                                                  const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  adminProvider
                                                      .approveFlat(
                                                          flat.id),
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                    Colors.green,
                                              ),
                                              child: const Text(
                                                  'Approve'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // Active Flats
                    activeFlats.isEmpty
                        ? const Center(child: Text('No active flats'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: activeFlats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final flat = activeFlats[index];
                              return ListTile(
                                tileColor:
                                    Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                leading: const Icon(
                                    Icons.apartment),
                                title: Text(flat.name),
                                subtitle:
                                    Text('ID: ${flat.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => _EditNameDialog(
                                            title: 'Edit Flat Name',
                                            label: 'Flat Name',
                                            initialValue: flat.name,
                                            onSave: (val) {
                                              adminProvider.updateFlatName(flat.id, val);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Delete Flat'),
                                            content: Text(
                                                'Are you sure you want to delete ${flat.name}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context),
                                                child: const Text(
                                                    'Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  adminProvider
                                                      .deleteFlat(
                                                          flat.id);
                                                  Navigator.pop(
                                                      context);
                                                },
                                                child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .red)),
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
                  ],
                ),
              ),
            ],
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
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final guards = adminProvider.guards;

        return _AdminScaffold(
          title: 'Guards',
          currentIndex: 2,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _AdminGuardDialog(provider: adminProvider),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Guard'),
          ),
          body: guards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security_outlined,
                          size: 64,
                          color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      Text('No guards found',
                          style:
                              Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: guards.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final guard = guards[index];
                    final status = guard['status'] as String;
                    final isPending = status == 'pending';

                    Color statusColor;
                    switch (status) {
                      case 'active':
                        statusColor = Colors.green;
                        break;
                      case 'pending':
                        statusColor = Colors.orange;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return ListTile(
                      tileColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                            Text(
                                'User: ${guard['linkedUserName']} (${guard['linkedUserEmail']})'),
                          Text('Status: ${status.toUpperCase()}',
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green),
                                  tooltip: 'Approve',
                                  onPressed: () =>
                                      adminProvider.approveGuard(
                                          guard['id']),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red),
                                  tooltip: 'Reject',
                                  onPressed: () =>
                                      adminProvider.rejectGuard(
                                          guard['id']),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AdminGuardDialog(
                                        provider: adminProvider,
                                        guard: guard,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                        title: const Text(
                                            'Delete Guard'),
                                        content: Text(
                                            'Are you sure you want to delete ${guard['name']}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                            child: const Text(
                                                'Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              adminProvider.deleteGuard(
                                                  guard['id']);
                                              Navigator.pop(
                                                  context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color:
                                                      Colors.red),
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

    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, _) {
        return _AdminScaffold(
          title: 'Settings',
          currentIndex: 3,
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Appearance Section
              Text(
                'Appearance',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // General Section
              Text(
                'General',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Notifications',
                        style: theme.textTheme.bodyMedium,
                      ),
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (value) =>
                          settingsProvider.setNotificationsEnabled(value),
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support Section
              Text(
                'Support',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {
                        // Placeholder
                        showDialog(
                          context: context,
                          builder: (context) => const ComingSoonDialog(
                            featureName: 'Privacy Policy',
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () {
                        // Placeholder
                        showDialog(
                          context: context,
                          builder: (context) => const ComingSoonDialog(
                            featureName: 'Terms of Service',
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Guardrail',
                          applicationVersion: '1.0.0',
                          applicationIcon: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          children: [
                            const Text(
                              'Guardrail is a residential security access management system developed by ARVYO.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              Text(
                'Account',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _SettingsTile(
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
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
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
      color: Colors.transparent, // Use container color
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.textTheme.bodySmall?.color,
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

class _AdminFlatDialog extends StatefulWidget {
  final AdminProvider provider;
  final Map<String, dynamic>? flat;

  const _AdminFlatDialog({required this.provider, this.flat});

  @override
  State<_AdminFlatDialog> createState() => _AdminFlatDialogState();
}

class _AdminFlatDialogState extends State<_AdminFlatDialog> {
  late TextEditingController _flatController;
  late TextEditingController _residentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _flatController = TextEditingController(text: widget.flat?['flat'] ?? '');
    _residentController = TextEditingController(
        text: widget.flat?['resident']?.replaceFirst('Owner ID: ', '') ?? '');
  }

  @override
  void dispose() {
    _flatController.dispose();
    _residentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flat != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Flat' : 'Add Flat'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _flatController,
              decoration: const InputDecoration(labelText: 'Flat Name'),
              validator: Validators.validateFlatNumber,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _residentController,
              decoration: const InputDecoration(labelText: 'Owner Name'),
              validator: Validators.validateName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            if (isEditing) {
              widget.provider.updateFlat(
                widget.flat!['id']!,
                _flatController.text,
                _residentController.text,
              );
            } else {
              widget.provider.addFlat(
                _flatController.text,
                _residentController.text,
              );
            }
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _AdminGuardDialog extends StatefulWidget {
  final AdminProvider provider;
  final Map<String, dynamic>? guard;

  const _AdminGuardDialog({required this.provider, this.guard});

  @override
  State<_AdminGuardDialog> createState() => _AdminGuardDialogState();
}

class _AdminGuardDialogState extends State<_AdminGuardDialog> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  bool _isManualId = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.guard != null;
    _nameController = TextEditingController(text: widget.guard?['name'] ?? '');
    _idController = TextEditingController(text: widget.guard?['id'] ?? '');
    _isManualId = isEditing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.guard != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Guard' : 'Create Guard Invite'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guard Details'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Guard Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (!isEditing) ...[
              Row(
                children: [
                  Checkbox(
                    value: _isManualId,
                    onChanged: (val) {
                      setState(() {
                        _isManualId = val ?? false;
                        if (!_isManualId) _idController.clear();
                      });
                    },
                  ),
                  const Text('Enter Manual ID'),
                ],
              ),
            ],
            if (_isManualId || isEditing)
              TextField(
                controller: _idController,
                enabled: isEditing || _isManualId,
                decoration: const InputDecoration(
                  labelText: 'Guard ID',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to auto-generate (if creating)',
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              setState(() => _error = 'Name is required');
              return;
            }

            try {
              if (isEditing) {
                widget.provider.updateGuard(
                  widget.guard!['id'],
                  name: _nameController.text.trim(),
                  newId: _idController.text.trim().isNotEmpty
                      ? _idController.text.trim()
                      : null,
                );
              } else {
                widget.provider.createGuardInvite(
                    _nameController.text.trim(),
                    manualId: _isManualId &&
                            _idController.text.trim().isNotEmpty
                        ? _idController.text.trim()
                        : null);
              }
              Navigator.pop(context);
            } catch (e) {
              setState(() =>
                  _error = e.toString().replaceAll('Exception: ', ''));
            }
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final Function(String) onSave;

  const _EditNameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onSave(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
