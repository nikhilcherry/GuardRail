import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Panel',
              style: AppTheme.headlineSmall,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.borderDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<AuthProvider>().logout();
                },
                borderRadius: BorderRadius.circular(16),
                child: const Icon(
                  Icons.logout,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: AppTheme.headlineLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'Live System',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.primary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
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
                      label: 'Total Flats',
                      value: '120',
                      icon: Icons.apartment_outlined,
                    ),
                    _StatCard(
                      label: 'Active Guards',
                      value: '4',
                      icon: Icons.security_outlined,
                      highlighted: true,
                    ),
                    _StatCard(
                      label: "Today's Visitors",
                      value: '45',
                      icon: Icons.group_outlined,
                    ),
                    _StatCard(
                      label: 'Pending Approvals',
                      value: '3',
                      icon: Icons.pending_actions_outlined,
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Activity Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Gate Activity',
                  style: AppTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Activity Feed
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => const Divider(
                color: AppTheme.borderDark,
                height: 1,
              ),
              itemBuilder: (context, index) {
                return _ActivityItem(index: index);
              },
            ),
          ),
        ],
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlighted = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary
        ? AppTheme.primary.withOpacity(0.1)
        : highlighted
            ? AppTheme.surfaceDark
            : AppTheme.surfaceDark;

    final borderColor = isPrimary
        ? AppTheme.primary.withOpacity(0.2)
        : AppTheme.borderDark;

    return Container(
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
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Icon(
                icon,
                color: AppTheme.textSecondary.withOpacity(0.3),
                size: 28,
              ),
            ],
          ),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(
              color: isPrimary ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final int index;

  const _ActivityItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': Icons.local_shipping_outlined,
        'color': AppTheme.successGreen,
        'title': 'Delivery for Flat 401',
        'time': '10:02 AM',
        'status': 'Approved',
        'statusColor': AppTheme.successGreen,
      },
      {
        'icon': Icons.person_outline,
        'color': AppTheme.primary,
        'title': 'Guest: John Doe',
        'time': '09:55 AM',
        'status': 'Waiting Approval (102)',
        'statusColor': AppTheme.primary,
      },
      {
        'icon': Icons.local_taxi_outlined,
        'color': AppTheme.textSecondary,
        'title': 'Taxi Drop-off',
        'time': '09:45 AM',
        'status': 'Exited',
        'statusColor': AppTheme.textSecondary,
      },
      {
        'icon': Icons.block_outlined,
        'color': AppTheme.errorRed,
        'title': 'Unknown Vehicle',
        'time': '09:30 AM',
        'status': 'Entry Denied',
        'statusColor': AppTheme.errorRed,
      },
      {
        'icon': Icons.cleaning_services_outlined,
        'color': AppTheme.textSecondary,
        'title': 'Housekeeping Staff',
        'time': '08:15 AM',
        'status': 'Entry Approved',
        'statusColor': AppTheme.successGreen,
      },
    ];

    final activity = activities[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderDark.withOpacity(0.3)),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      activity['time'] as String,
                      style: AppTheme.labelSmall,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity['status'] as String,
                      style: AppTheme.labelSmall.copyWith(
                        color: activity['statusColor'] as Color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activity['statusColor'] as Color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: (activity['statusColor'] as Color).withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const _AdminBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
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
    );
  }
}

