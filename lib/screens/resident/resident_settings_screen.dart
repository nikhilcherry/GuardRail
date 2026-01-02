import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resident_provider.dart';
import '../../widgets/contact_support_dialog.dart';
import '../../widgets/coming_soon.dart';

class ResidentSettingsScreen extends StatefulWidget {
  const ResidentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ResidentSettingsScreen> createState() => _ResidentSettingsScreenState();
}

class _ResidentSettingsScreenState extends State<ResidentSettingsScreen> {
  // Local state removed, using SettingsProvider

  @override
  void initState() {
    super.initState();
    // Settings are loaded in provider initialization
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
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        // Use go_router to navigate - don't mix with Navigator
        context.go('/');
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, ResidentProvider residentProvider) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: residentProvider.residentName);
    final flatController = TextEditingController(text: residentProvider.flatNumber);
    final phoneController = TextEditingController(text: residentProvider.phoneNumber);
    final emailController = TextEditingController(text: residentProvider.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile', style: theme.textTheme.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: flatController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Flat Number',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              residentProvider.updateResidentInfo(
                name: nameController.text,
                flatNumber: flatController.text,
                phoneNumber: phoneController.text,
                email: emailController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
      body: Consumer3<ResidentProvider, ThemeProvider, SettingsProvider>(
        builder: (context, residentProvider, themeProvider, settingsProvider, _) {
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
                        _showEditProfileDialog(context, residentProvider);
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () => showComingSoonDialog(
                        context,
                        title: 'Change Password',
                        message: 'Update your security credentials here.',
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.apartment,
                      title: 'Flat Management',
                      onTap: () => showComingSoonDialog(
                        context,
                        title: 'Flat Management',
                        message: 'Manage your flat and members.',
                      ),
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
                      onTap: () => showComingSoonDialog(
                        context,
                        title: 'Visitor Management',
                        message: 'Track and manage your visitors.',
                      ),
                    ),
                    _SettingsToggleItem(
                      icon: Icons.face,
                      title: 'Face ID Login',
                      value: settingsProvider.biometricsEnabled,
                      onChanged: (value) {
                        settingsProvider.setBiometricsEnabled(value);
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
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (value) {
                        settingsProvider.setNotificationsEnabled(value);
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
