import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../main.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';

class GuardHomeScreen extends StatefulWidget {
  const GuardHomeScreen({Key? key}) : super(key: key);

  @override
  State<GuardHomeScreen> createState() => _GuardHomeScreenState();
}

class _GuardHomeScreenState extends State<GuardHomeScreen> {
  late TimeOfDay currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Icon(
                      Icons.security_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  // Title
                  Text(
                    'Gate Control',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Row(
                    children: [
                      // Time
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                              '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Logout Button
                      InkWell(
                        onTap: () async {
                          await context.read<AuthProvider>().logout();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const RootScreen()),
                              (route) => false,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.colorScheme.error.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: theme.colorScheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        children: [
                          // Register New Visitor Button
                          const _RegisterVisitorButton(),
                          const SizedBox(height: 32),
                          // Recent Entries Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Entries',
                                style: theme.textTheme.headlineSmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  showComingSoonDialog(
                                    context,
                                    title: 'Visitor History',
                                    message: 'A complete history of all visitor entries will be available here.',
                                  );
                                },
                                child: Text(
                                  'View All',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  // Entries List
                  Consumer<GuardProvider>(
                    builder: (context, guardProvider, _) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Handle separator
                              if (index.isOdd) {
                                return const SizedBox(height: 12);
                              }
                              // Handle item
                              final itemIndex = index ~/ 2;
                              if (itemIndex >= guardProvider.entries.length) return null;

                              final entry = guardProvider.entries[itemIndex];
                              return _EntryCard(entry: entry);
                            },
                            childCount: guardProvider.entries.isEmpty
                                ? 0
                                : guardProvider.entries.length * 2 - 1,
                          ),
                        ),
                      );
                    },
                  ),
                  // Bottom padding for scroll
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
            // Bottom Patrol Check Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.95),
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Consumer<GuardProvider>(
                builder: (context, guardProvider, _) {
                  final lastCheck = guardProvider.lastPatrolCheck;
                  final minutesAgo = DateTime.now().difference(lastCheck).inMinutes;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patrol Checkpoint',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last check: ${minutesAgo}m ago',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await guardProvider.patrolCheckIn();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Patrol check-in recorded'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Check In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          foregroundColor: theme.textTheme.bodyLarge?.color,
                          side: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterVisitorButton extends StatelessWidget {
  const _RegisterVisitorButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showVisitorDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Register New Visitor',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap when a visitor arrives',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVisitorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    String selectedPurpose = 'guest';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return Dialog(
            backgroundColor: theme.dialogBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Register Visitor', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 24),
                Text('Flat Number', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: flatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 402',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Visitor Name', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Purpose', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _PurposeChip(
                      label: 'Guest',
                      icon: Icons.person,
                      selected: selectedPurpose == 'guest',
                      onSelected: () => setState(() => selectedPurpose = 'guest'),
                    ),
                    const SizedBox(height: 8),
                    _PurposeChip(
                      label: 'Delivery',
                      icon: Icons.local_shipping,
                      selected: selectedPurpose == 'delivery',
                      onSelected: () => setState(() => selectedPurpose = 'delivery'),
                    ),
                    const SizedBox(height: 8),
                    _PurposeChip(
                      label: 'Service',
                      icon: Icons.build,
                      selected: selectedPurpose == 'service',
                      onSelected: () => setState(() => selectedPurpose = 'service'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.isEmpty ||
                                flatController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              await context.read<GuardProvider>().registerNewVisitor(
                                    name: nameController.text,
                                    flatNumber: flatController.text,
                                    purpose: selectedPurpose,
                                  );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Visitor registered successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                                setState(() => isLoading = false);
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          )
                        : const Text('Register Visitor'),
                  ),
                ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PurposeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  const _PurposeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? theme.colorScheme.primary.withOpacity(0.2) : theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final VisitorEntry entry;

  // OPTIMIZE: Cached formatter to avoid recreation on every build
  static final _timeFormatter = DateFormat('HH:mm');

  const _EntryCard({required this.entry});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.pending;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    return status.replaceFirst(status[0], status[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(entry.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.person_outline,
              color: theme.textTheme.bodySmall?.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Flat ${entry.flatNumber}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _getStatusLabel(entry.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeFormatter.format(entry.time),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
