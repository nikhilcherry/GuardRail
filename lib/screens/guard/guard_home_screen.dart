import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';

class GuardHomeScreen extends StatefulWidget {
  const GuardHomeScreen({Key? key}) : super(key: key);

  @override
  State<GuardHomeScreen> createState() => _GuardHomeScreenState();
}

class _GuardHomeScreenState extends State<GuardHomeScreen> {
  // Mock time for the static display "21:45" in design or real time
  String get _timeString => DateFormat('HH:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    // Primary Color for Guard Dashboard is Blue #135BEC in design
    // But theme defines primary as Yellow. The design specifically overrides colors.
    // We should respect the design provided in `guard_home_dashboard/code.html`
    // which uses `primary: #135bec`.
    // I will use local overrides where necessary or update theme if global.
    // Since AppTheme defines `secondary` as `primaryBlue`, I can use that.

    final guardBlue = AppTheme.primaryBlue;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          Column(
            children: [
              // Top App Bar
              Container(
                color: AppTheme.backgroundDark,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1c1f27),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Icon(
                        Icons.shield, // shield_person equivalent
                        color: guardBlue,
                        size: 24,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        'Gate Control',
                        textAlign: TextAlign.center,
                        style: AppTheme.headlineMedium.copyWith(fontSize: 22),
                      ),
                    ),
                    // Status & Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1c1f27),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successGreen.withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _timeString,
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Bottom padding for sticky footer
                  child: Column(
                    children: [
                      // Register New Visitor Button
                      _buildRegisterButton(guardBlue),

                      const SizedBox(height: 32),

                      // Recent Entries Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Entries', style: AppTheme.titleLarge),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: AppTheme.bodyMedium.copyWith(color: guardBlue),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // List
                      _buildEntryItem(
                        name: 'John Doe',
                        flat: 'Flat 4B',
                        time: '21:30',
                        status: 'Approved',
                        statusColor: AppTheme.successGreen,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildEntryItem(
                        name: 'Delivery Driver',
                        flat: 'Flat 12A',
                        time: '21:15',
                        status: 'Pending',
                        statusColor: AppTheme.pendingYellow, // Yellow
                        icon: Icons.local_shipping_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildEntryItem(
                        name: 'Unknown Male',
                        flat: 'Flat 2C',
                        time: '21:00',
                        status: 'Rejected',
                        statusColor: AppTheme.errorRed,
                        icon: Icons.help_outline,
                      ),
                       const SizedBox(height: 12),
                      _buildEntryItem(
                        name: 'Sarah Smith',
                        flat: 'Flat 8A',
                        time: '20:42',
                        status: 'Approved',
                        statusColor: AppTheme.successGreen,
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Sticky Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.95),
                border: const Border(top: BorderSide(color: AppTheme.borderDark)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patrol Checkpoint', style: AppTheme.titleSmall),
                        Text('Last check: 45m ago', style: AppTheme.bodySmall),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.fact_check_outlined, color: guardBlue),
                      label: const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1c1f27),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.borderDark),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(Color primaryColor) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      child: Material(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.borderDark),
        ),
        child: InkWell(
          onTap: () {
            // Logic to register visitor
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text('Register New Visitor', style: AppTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Tap when a visitor arrives', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryItem({
    required String name,
    required String flat,
    required String time,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF374151)),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                Text(flat, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  status,
                  style: AppTheme.labelSmall.copyWith(color: statusColor, fontSize: 10),
                ),
              ),
              const SizedBox(height: 4),
              Text(time, style: AppTheme.labelSmall.copyWith(color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}
