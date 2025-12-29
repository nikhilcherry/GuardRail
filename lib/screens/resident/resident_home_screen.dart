import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';
import '../../providers/auth_provider.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  // Navigation Index
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
            _buildHomeTab(),
            _buildVisitorsTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414).withOpacity(0.95),
          border: const Border(top: BorderSide(color: AppTheme.borderDark)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.groups, 'Visitors', 1),
                _buildNavItem(Icons.settings, 'Settings', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Good Evening,\n', style: AppTheme.displayLarge.copyWith(fontSize: 30)),
                        TextSpan(text: 'Robert', style: AppTheme.displayLarge.copyWith(fontSize: 30, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home, color: AppTheme.primaryGreen, size: 18),
                        const SizedBox(width: 6),
                        Text('Flat 402', style: AppTheme.bodyMedium.copyWith(color: Colors.grey[300])),
                      ],
                    ),
                  ),
                ],
              ),

              // Notification Bell
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 20, color: Colors.white),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.backgroundDark, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Pending Request Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pending Request', style: AppTheme.titleLarge.copyWith(color: Colors.grey[300])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppTheme.errorRed, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text('LIVE', style: AppTheme.labelSmall.copyWith(color: AppTheme.errorRed, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pending Card
                _buildPendingCard(),

                const SizedBox(height: 32),

                // Recent History Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('RECENT HISTORY', style: AppTheme.labelSmall.copyWith(color: Colors.grey[500], fontSize: 12)),
                ),
                const SizedBox(height: 16),

                // History Items
                _buildHistoryItem(
                  title: 'Amazon Delivery',
                  subtitle: '10:00 AM • Approved',
                  icon: Icons.local_shipping,
                ),
                const SizedBox(height: 12),
                 _buildHistoryItem(
                  title: 'Sarah Smith (Guest)',
                  subtitle: 'Yesterday • Approved',
                  icon: Icons.group,
                  isOpacity: true,
                ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Visitor Logs',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Full history coming soon.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
     return ListView(
        padding: const EdgeInsets.all(24),
        children: [
           Text(
            'Settings',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          _buildSettingsTile(Icons.person_outline, 'My Profile'),
          _buildSettingsTile(Icons.notifications_outlined, 'Notifications'),
          _buildSettingsTile(Icons.security, 'Security & Access'),
          _buildSettingsTile(Icons.help_outline, 'Help & Support'),
          const SizedBox(height: 32),
          _buildSettingsTile(
            Icons.logout,
            'Logout',
            isDestructive: true,
            onTap: () {
               context.read<AuthProvider>().logout();
               // RootScreen handles redirection
            },
          ),
        ],
     );
  }

  Widget _buildSettingsTile(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive ? AppTheme.errorRed.withOpacity(0.1) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppTheme.errorRed : Colors.white,
          size: 20
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDestructive ? AppTheme.errorRed : Colors.white
        ),
      ),
      trailing: isDestructive ? null : Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : Colors.grey[500];

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelSmall.copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('John Doe', style: AppTheme.headlineSmall)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('DELIVERY', style: AppTheme.labelSmall.copyWith(color: AppTheme.primaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMetaRow(Icons.shield, 'Guard: Ramesh'),
                    const SizedBox(height: 4),
                    _buildMetaRow(Icons.schedule, 'Arrived 1 min ago'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
                      elevation: 8,
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(text, style: AppTheme.bodySmall.copyWith(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildHistoryItem({required String title, required String subtitle, required IconData icon, bool isOpacity = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(isOpacity ? 0.5 : 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.grey[400], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: AppTheme.bodySmall.copyWith(color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: isOpacity ? Colors.grey[600] : AppTheme.primaryGreen, size: 20),
        ],
      ),
    );
  }
}
