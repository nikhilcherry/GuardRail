import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/guard_provider.dart';
import 'admin_analytics_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              l10n.adminPanel,
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
      body: SingleChildScrollView(
        child: Consumer2<AdminProvider, GuardProvider>(
          builder: (context, adminProvider, guardProvider, _) {
            // PERF: Use cached stats from AdminProvider to avoid O(N) filtering on every build
            final pendingCount = adminProvider.pendingGuardCount;
            final activeGuards = adminProvider.activeGuardCount;
            final totalFlats = adminProvider.allFlats.length;
            final pendingFlatsCount = adminProvider.pendingFlatCount;
            final recentChecks = guardProvider.checks;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.overview,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.dashboard,
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
                            label: l10n.totalFlats,
                            value: '$totalFlats',
                            icon: Icons.apartment_outlined,
                          ),
                          _StatCard(
                            label: l10n.activeGuards,
                            value: '$activeGuards',
                            icon: Icons.security_outlined,
                            highlighted: true,
                          ),
                          _StatCard(
                            label: l10n.pendingApprovals,
                            value: '$pendingCount',
                            icon: Icons.pending_actions_outlined,
                            isPrimary: true,
                            onTap: () =>
                                context.go('/admin_dashboard/guards'),
                          ),
                          if (pendingFlatsCount > 0)
                            _StatCard(
                              label: l10n.pendingFlats,
                              value: '$pendingFlatsCount',
                              icon: Icons.home_work_outlined,
                              isPrimary: true,
                              onTap: () =>
                                  context.go('/admin_dashboard/flats'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Analytics Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.analyticsMockData,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ChartContainer(
                        title: l10n.weeklyVisitorCount,
                        child: const VisitorCountChart(),
                      ),
                      const SizedBox(height: 16),
                      ChartContainer(
                        title: l10n.peakHours,
                        child: const PeakHoursChart(),
                      ),
                      const SizedBox(height: 16),
                      ChartContainer(
                        title: l10n.guardStatus,
                        child: const GuardStatusChart(),
                      ),
                      const SizedBox(height: 16),
                      ChartContainer(
                        title: l10n.approvalRates,
                        child: const ApprovalRateChart(),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Recent Guard Checks
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recentGuardChecks,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (recentChecks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Center(
                            child: Text(
                              l10n.noRecentChecks,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentChecks.length > 5
                              ? 5
                              : recentChecks.length,
                          itemBuilder: (context, index) {
                            final check = recentChecks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                title: Text(
                                    '${l10n.location}: ${check.locationId}'),
                                subtitle: Text(
                                  DateFormat('MMM d, HH:mm')
                                      .format(check.timestamp),
                                ),
                                trailing: Text(
                                  '${l10n.guard}: ${check.guardId.length > 6 ? check.guardId.substring(0, 6) : check.guardId}...',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
                  color:
                      theme.textTheme.bodySmall?.color?.withOpacity(0.3),
                  size: 28,
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(
                color: isPrimary
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
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
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.textTheme.bodySmall?.color,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: l10n.overview,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.apartment_outlined),
          label: l10n.flats,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.security),
          label: l10n.guards,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: l10n.settings,
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