import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resident_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/contact_support_dialog.dart';
import 'resident_profile_screen.dart';

class ResidentSettingsScreen extends StatefulWidget {
  const ResidentSettingsScreen({super.key});

  @override
  State<ResidentSettingsScreen> createState() => _ResidentSettingsScreenState();
}

class _ResidentSettingsScreenState extends State<ResidentSettingsScreen> {
  // Local state for biometrics toggle
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Sync with provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      setState(() {
        _biometricsEnabled = authProvider.biometricsEnabled;
      });
    });
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.logout, style: Theme.of(context).textTheme.headlineSmall),
        content: Text(
          l10n.areYouSureLogout,
        style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel, style: Theme.of(context).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      context.read<AuthProvider>().logout();
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.selectLanguage,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ListTile(
                  title: Text(l10n.english, style: Theme.of(context).textTheme.bodyLarge),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setLocale(Locale(value));
                        Navigator.pop(context);
                      }
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    settings.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(l10n.hindi, style: Theme.of(context).textTheme.bodyLarge),
                  leading: Radio<String>(
                    value: 'hi',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setLocale(Locale(value));
                        Navigator.pop(context);
                      }
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    settings.setLocale(const Locale('hi'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(l10n.telugu, style: Theme.of(context).textTheme.bodyLarge),
                  leading: Radio<String>(
                    value: 'te',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setLocale(Locale(value));
                        Navigator.pop(context);
                      }
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    settings.setLocale(const Locale('te'));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
        centerTitle: true,
      ),
      body: Consumer3<ResidentProvider, SettingsProvider, ThemeProvider>(
        builder: (context, residentProvider, settingsProvider, themeProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Account Section
                _SettingsSection(
                  title: l10n.account,
                  children: [
                    _SettingsItem(
                      icon: Icons.person,
                      title: l10n.myProfile,
                      subtitle: '${residentProvider.residentName}, Flat ${residentProvider.flatNumber}',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResidentProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.lock,
                      title: l10n.changePassword,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Access & Security Section
                _SettingsSection(
                  title: l10n.accessAndSecurity,
                  children: [
                    _SettingsItem(
                      icon: Icons.assignment_ind,
                      title: l10n.visitorManagement,
                      subtitle: l10n.preApprovalsAndGuests,
                      onTap: () {},
                    ),
                    _SettingsToggleItem(
                      icon: Icons.face,
                      title: l10n.biometrics,
                      value: _biometricsEnabled,
                      onChanged: (value) async {
                        final success = await context.read<AuthProvider>().toggleBiometrics(value);
                        if (success) {
                          if (mounted) {
                            setState(() => _biometricsEnabled = value);
                          }
                        } else {
                          // Show error and revert
                          if (mounted) {
                            setState(() => _biometricsEnabled = !value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.biometricsUpdateFailed)),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Preferences Section
                _SettingsSection(
                  title: l10n.preferences,
                  children: [
                    _SettingsItem(
                      icon: Icons.language,
                      title: l10n.language,
                      trailing: Text(
                        _getLanguageName(settingsProvider.locale.languageCode, l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _showLanguageSelector(context),
                    ),
                    _SettingsToggleItem(
                      icon: Icons.notifications,
                      title: l10n.notifications,
                      subtitle: l10n.alertsForGateRequests,
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (value) {
                        settingsProvider.setNotificationsEnabled(value);
                      },
                    ),
                    _SettingsToggleItem(
                      icon: Icons.dark_mode,
                      title: l10n.darkMode,
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Support
                _SettingsSection(
                  title: l10n.support,
                  children: [
                    _SettingsItem(
                      icon: Icons.support_agent,
                      title: l10n.contactSupport,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const ContactSupportDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
                      label: Text(
                        l10n.logout,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).dividerColor),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'hi':
        return l10n.hindi;
      case 'te':
        return l10n.telugu;
      case 'en':
      default:
        return l10n.english;
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
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
                color: Theme.of(context).dividerColor,
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
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: hasSubtitle
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Text(title, style: Theme.of(context).textTheme.bodyLarge),
              ),
              if (hasTrailing)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: subtitle != null ? Theme.of(context).dividerColor : Colors.transparent,
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
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}