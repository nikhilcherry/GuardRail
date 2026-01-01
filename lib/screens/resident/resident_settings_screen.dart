import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resident_provider.dart';
import '../../widgets/contact_support_dialog.dart';

class ResidentSettingsScreen extends StatefulWidget {
  const ResidentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ResidentSettingsScreen> createState() => _ResidentSettingsScreenState();
}

class _ResidentSettingsScreenState extends State<ResidentSettingsScreen> {
  bool _biometricsEnabled = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleLogout() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: theme.textTheme.headlineSmall),
        content: Text(
          'Are you sure you want to log out?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: theme.textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      // AuthProvider listener in AppRouter will handle redirect to login
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/resident_home');
            }
          },
        ),
        title: Text(
          'Resident Settings',
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
        centerTitle: true,
      ),
      body: Consumer2<ResidentProvider, ThemeProvider>(
        builder: (context, residentProvider, themeProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Account Section
                _SettingsSection(
                  title: 'Account',
                  children: [
                    _SettingsItem(
                      icon: Icons.person,
                      title: 'My Profile',
                      subtitle: '${residentProvider.residentName}, Flat ${residentProvider.flatNumber}',
                      onTap: () {
                        // Empty state/hidden for now
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () {
                        // Empty state/hidden for now
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.apartment,
                      title: 'Flat Management',
                      onTap: () {
                         // Empty state/hidden for now
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Access & Security Section
                _SettingsSection(
                  title: 'Access & Security',
                  children: [
                    _SettingsItem(
                      icon: Icons.assignment_ind,
                      title: 'Visitor Management',
                      subtitle: 'Pre-approvals & Guests',
                      onTap: () {},
                    ),
                    _SettingsToggleItem(
                      icon: Icons.face,
                      title: 'Face ID Login',
                      value: _biometricsEnabled,
                      onChanged: (value) {
                        setState(() => _biometricsEnabled = value);
                        _savePreference('biometricsEnabled', value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Preferences Section
                _SettingsSection(
                  title: 'Preferences',
                  children: [
                    _SettingsToggleItem(
                      icon: Icons.notifications,
                      title: 'Entry Notifications',
                      subtitle: 'Alerts for gate requests',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _savePreference('notificationsEnabled', value);
                      },
                    ),
                    _SettingsToggleItem(
                      icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Support Section
                 _SettingsSection(
                  title: 'Support',
                  children: [
                     _SettingsItem(
                      icon: Icons.support_agent,
                      title: 'Contact Support',
                      onTap: () => showContactSupportDialog(context),
                    ),
                  ]
                ),
                const SizedBox(height: 40),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout, color: theme.colorScheme.primary),
                      label: Text(
                        'Log Out',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version 2.4.1 (Build 890)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubtitle = subtitle != null;
    final hasTrailing = trailing != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: hasSubtitle && !hasTrailing ? 1 : 0,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.textTheme.bodyLarge?.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: hasSubtitle
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      )
                    : Text(title, style: theme.textTheme.bodyLarge),
              ),
              if (hasTrailing)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: subtitle != null ? theme.dividerColor : Colors.transparent,
            width: subtitle != null ? 1 : 0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.textTheme.bodyLarge?.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  )
                : Text(title, style: theme.textTheme.bodyLarge),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
