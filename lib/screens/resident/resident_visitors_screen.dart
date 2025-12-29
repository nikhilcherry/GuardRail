import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';

class ResidentVisitorsScreen extends StatelessWidget {
  const ResidentVisitorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: Text(
          'Visitors',
          style: AppTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Consumer<ResidentProvider>(
          builder: (context, residentProvider, _) {
            final visitors = residentProvider.allVisitors;

            if (visitors.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No visitors yet.\nYou’ll see your full visitor history here.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visitors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final visitor = visitors[index];

                final typeLabel = visitor.type[0].toUpperCase() +
                    visitor.type.substring(1);
                final statusLabel = visitor.status[0].toUpperCase() +
                    visitor.status.substring(1);
                final timeLabel =
                    DateFormat('MMM d, h:mm a').format(visitor.date);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderDark.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.borderDark.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppTheme.textSecondary,
                          size: 20,
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
                              '$typeLabel • $statusLabel • $timeLabel',
                              style: AppTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const _ResidentBottomNav(currentIndex: 1),
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

