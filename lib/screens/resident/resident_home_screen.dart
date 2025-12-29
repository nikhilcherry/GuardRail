import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';
import '../../providers/auth_provider.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<ResidentProvider>(
          builder: (context, residentProvider, _) {
            final pendingVisitors = residentProvider.getPendingApprovals();
            final hasPendingRequest = pendingVisitors.isNotEmpty;

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Evening,',
                                style: AppTheme.displayMedium,
                              ),
                              Text(
                                residentProvider.residentName,
                                style: AppTheme.displayMedium.copyWith(
                                  color: AppTheme.textPrimary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.borderDark,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.textPrimary,
                                ),
                                if (residentProvider.pendingRequests > 0)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorRed,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppTheme.backgroundDark,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.borderDark,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.home_outlined,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flat ${residentProvider.flatNumber}',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Pending Request Card
                        if (hasPendingRequest) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Request',
                                style: AppTheme.titleLarge,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.errorRed.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorRed,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Live',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: AppTheme.errorRed,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _PendingVisitorCard(
                            visitor: pendingVisitors.first,
                            onApprove: () {
                              residentProvider.approveVisitor(
                                pendingVisitors.first.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Visitor approved'),
                                ),
                              );
                            },
                            onReject: () {
                              residentProvider.rejectVisitor(
                                pendingVisitors.first.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Visitor rejected'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                        // Recent History
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent History',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...(residentProvider.todaysVisitors.isNotEmpty
                            ? residentProvider.todaysVisitors.map(
                                (visitor) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _HistoryCard(visitor: visitor),
                                ),
                              )
                            : [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Text(
                                      'No recent visitors',
                                      style: AppTheme.labelMedium,
                                    ),
                                  ),
                                ),
                              ]),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _ResidentBottomNav(currentIndex: 0),
    );
  }
}

class _PendingVisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingVisitorCard({
    required this.visitor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.borderDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDark.withOpacity(0.5)),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppTheme.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style: AppTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        visitor.type.replaceFirst(
                          visitor.type[0],
                          visitor.type[0].toUpperCase(),
                        ),
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.security,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Guard: Ramesh',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Arrived 1 min ago',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Visitor visitor;

  const _HistoryCard({required this.visitor});

  Color _getStatusColor() {
    switch (visitor.status) {
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (visitor.type) {
      case 'guest':
        return Icons.person;
      case 'delivery':
        return Icons.local_shipping;
      case 'service':
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark.withOpacity(0.3)),
      ),
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
              _getTypeIcon(),
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(visitor.date),
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.2),
              ),
            ),
            child: Text(
              visitor.status.replaceFirst(
                visitor.status[0],
                visitor.status[0].toUpperCase(),
              ),
              style: AppTheme.labelSmall.copyWith(
                color: _getStatusColor(),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentBottomNav extends StatelessWidget {
  final int currentIndex;

  const _ResidentBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
          activeIcon: Icon(Icons.home_filled),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          label: 'Visitors',
          activeIcon: Icon(Icons.groups),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
          activeIcon: Icon(Icons.settings),
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/resident_home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/resident_visitors');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/resident_settings');
        }
      },
    );
  }
}

