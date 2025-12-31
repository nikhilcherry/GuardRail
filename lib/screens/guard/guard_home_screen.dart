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
  late TimeOfDay currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1f27),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: const Icon(
                      Icons.security_outlined,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  // Title
                  Text(
                    'Gate Control',
                    style: AppTheme.headlineMedium,
                  ),
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1f27),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderDark),
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
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
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
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                style: AppTheme.headlineSmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('History view coming soon')),
                                  );
                                },
                                child: Text(
                                  'View All',
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.primary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: AppTheme.surfaceDark.withOpacity(0.95),
                border: Border(
                  top: BorderSide(color: AppTheme.borderDark),
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
                            style: AppTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last check: ${minutesAgo}m ago',
                            style: AppTheme.labelSmall,
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
                          backgroundColor: const Color(0xFF1c1f27),
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: AppTheme.borderDark),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
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
                    color: AppTheme.primary,
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
                  style: AppTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap when a visitor arrives',
                  style: AppTheme.labelSmall,
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register Visitor', style: AppTheme.headlineSmall),
              const SizedBox(height: 24),
              Text('Flat Number', style: AppTheme.labelLarge),
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
              Text('Visitor Name', style: AppTheme.labelLarge),
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
              Text('Purpose', style: AppTheme.labelLarge),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Column(
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
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        flatController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    }

                    await context.read<GuardProvider>().registerNewVisitor(
                          name: nameController.text,
                          flatNumber: flatController.text,
                          purpose: selectedPurpose,
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Visitor registered successfully'),
                      ),
                    );
                  },
                  child: const Text('Register Visitor'),
                ),
              ),
            ],
          ),
        ),
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
    return Material(
      color: selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceDark,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.borderDark,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTheme.titleSmall.copyWith(
                  color: selected ? AppTheme.primary : AppTheme.textPrimary,
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
    final statusColor = _getStatusColor(entry.status);

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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF374151)),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppTheme.textTertiary,
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
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Flat ${entry.flatNumber}',
                  style: AppTheme.labelSmall,
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
                  style: AppTheme.labelSmall.copyWith(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeFormatter.format(entry.time),
                style: AppTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
