import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final FloatingActionButton? floatingActionButton;

  const AdminScaffold({
    Key? key,
    required this.title,
    required this.body,
    required this.currentIndex,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.textTheme.bodySmall?.color,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
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
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
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
      ),
    );
  }
}
