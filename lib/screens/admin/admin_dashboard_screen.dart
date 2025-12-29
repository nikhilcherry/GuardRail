import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOverviewTab(),
            _buildPlaceholderTab('Flats Management', Icons.apartment),
            _buildPlaceholderTab('Guards Management', Icons.shield),
            _buildPlaceholderTab('Visitor Logs', Icons.group),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          border: Border(top: BorderSide(color: AppTheme.borderDark)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, 'Overview', 0),
                _buildNavItem(Icons.apartment, 'Flats', 1),
                _buildNavItem(Icons.shield, 'Guards', 2),
                _buildNavItem(Icons.group, 'Visitors', 3),
                _buildNavItem(Icons.settings, 'Settings', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    const primary = AppTheme.primary;
    return Column(
      children: [
        // Top App Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security, color: primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      color: Colors.grey[800],
                    ),
                    child: const Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      context.read<AuthProvider>().logout();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Color(0xFFB5B5B5), size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome / Date
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERVIEW', style: AppTheme.labelSmall.copyWith(fontSize: 12, letterSpacing: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dashboard', style: AppTheme.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: primary.withOpacity(0.2)),
                            ),
                            child: Text('Live System', style: AppTheme.labelSmall.copyWith(color: primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Total Flats', '120', Icons.apartment, false),
                      _buildStatCard('Active Guards', '4', Icons.local_police, false, hasPulse: true),
                      _buildStatCard("Today's Visitors", '45', Icons.group, false),
                      _buildStatCard('Pending', '3', Icons.pending_actions, true),
                    ],
                  ),
                ),

                // Live Activity Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live Gate Activity', style: AppTheme.titleLarge),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.sync, size: 12, color: primary),
                              const SizedBox(width: 4),
                              Text('Auto-refreshing every 10s', style: AppTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('View All', style: AppTheme.labelSmall.copyWith(color: primary)),
                      ),
                    ],
                  ),
                ),

                // Activity List
                _buildActivityItem('Delivery for Flat 401', '10:02 AM', 'Approved', Colors.green, Icons.local_shipping),
                _buildActivityItem('Guest: John Doe', '09:55 AM', 'Waiting Approval (102)', primary, Icons.person, isPulse: true),
                _buildActivityItem('Taxi Drop-off', '09:45 AM', 'Exited', const Color(0xFFB5B5B5), Icons.local_taxi),
                _buildActivityItem('Unknown Vehicle', '09:30 AM', 'Entry Denied', AppTheme.errorRed, Icons.block),
                _buildActivityItem('Housekeeping Staff', '08:15 AM', 'Entry Approved', Colors.green, Icons.cleaning_services),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Coming soon.', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Admin Settings', style: AppTheme.headlineMedium),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.logout, color: AppTheme.errorRed),
          title: const Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
          onTap: () => context.read<AuthProvider>().logout(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool highlighted, {bool hasPulse = false}) {
    final bgColor = highlighted
        ? AppTheme.primary.withOpacity(0.05) // Gradient simulation
        : AppTheme.surfaceDark;
    final borderColor = highlighted ? AppTheme.primary : Colors.white.withOpacity(0.1);
    final iconColor = highlighted ? AppTheme.primary : Colors.white;
    final textColor = highlighted ? AppTheme.primary : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 60, color: iconColor.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTheme.monoNum.copyWith(fontSize: 32, color: textColor)),
                  if (hasPulse) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String status, Color statusColor, IconData icon, {bool isPulse = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: statusColor == AppTheme.errorRed ? statusColor : AppTheme.textSecondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(time, style: AppTheme.bodySmall),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(status, style: AppTheme.labelSmall.copyWith(color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
          if (isPulse)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: statusColor.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primary : AppTheme.textSecondary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelSmall.copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
