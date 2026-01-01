import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';

class ResidentVisitorsScreen extends StatefulWidget {
  const ResidentVisitorsScreen({Key? key}) : super(key: key);

  @override
  State<ResidentVisitorsScreen> createState() => _ResidentVisitorsScreenState();
}

class _ResidentVisitorsScreenState extends State<ResidentVisitorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPreApproveDialog(BuildContext context, ResidentProvider provider) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    String selectedType = 'guest';
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 4));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Pre-Approve Guest', style: theme.textTheme.headlineSmall),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Visitor Name',
                      labelStyle: theme.textTheme.bodyMedium,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Visitor Type', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: theme.cardColor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: ['guest', 'delivery', 'service']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type[0].toUpperCase() + type.substring(1),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Valid Until', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                         final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                         );
                         if (time != null) {
                           setState(() {
                             selectedDate = DateTime(
                               date.year, date.month, date.day, time.hour, time.minute);
                           });
                         }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, h:mm a').format(selectedDate),
                            style: theme.textTheme.bodyLarge,
                          ),
                          Icon(Icons.calendar_today, color: theme.iconTheme.color),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: theme.textTheme.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    provider.preApproveVisitor(
                      name: nameController.text,
                      type: selectedType,
                      validUntil: selectedDate,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Visitor Pre-Approved')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Pre-Approve'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Visitors',
          style: theme.textTheme.headlineSmall,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Pre-Approved'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<ResidentProvider>(
          builder: (context, residentProvider, _) {
            return TabBarView(
              controller: _tabController,
              children: [
                // History Tab
                _buildHistoryList(context, residentProvider),
                // Pre-Approved Tab
                _buildPreApprovedList(context, residentProvider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPreApproveDialog(context, context.read<ResidentProvider>()),
        label: const Text('Pre-Approve Guest'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: const _ResidentBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHistoryList(BuildContext context, ResidentProvider residentProvider) {
    final theme = Theme.of(context);
    final visitors = residentProvider.allVisitors;

    if (visitors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No visitors yet.\nYou’ll see your full visitor history here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
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
            color: theme.cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
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
                      visitor.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$typeLabel • $statusLabel • $timeLabel',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreApprovedList(BuildContext context, ResidentProvider residentProvider) {
    final theme = Theme.of(context);
    final visitors = residentProvider.preApprovedVisitors;

    if (visitors.isEmpty) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No pre-approved visitors.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
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
        final typeLabel = visitor.type[0].toUpperCase() + visitor.type.substring(1);
        final timeLabel = DateFormat('MMM d, h:mm a').format(visitor.validUntil);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: theme.colorScheme.primary,
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
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$typeLabel • Valid until $timeLabel',
                      style: theme.textTheme.labelSmall,
                    ),
                    if (visitor.code != null) ...[
                      const SizedBox(height: 4),
                       Text(
                        'Code: ${visitor.code}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResidentBottomNav extends StatelessWidget {
  final int currentIndex;

  const _ResidentBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      backgroundColor: theme.cardColor,
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
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.textTheme.bodySmall?.color,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          context.go('/resident_home');
        } else if (index == 1) {
          context.go('/resident_home/visitors');
        } else if (index == 2) {
          context.go('/resident_home/settings');
        }
      },
    );
  }
}
