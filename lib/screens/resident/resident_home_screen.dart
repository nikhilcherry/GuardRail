import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/resident_provider.dart';
import '../../providers/flat_provider.dart';
import '../../providers/auth_provider.dart';
import 'resident_notifications_screen.dart';
import '../../widgets/shimmer_list_item.dart';
import '../../widgets/sos_button.dart';
import 'resident_home_header.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: SOSButton(
        onAction: () => context.read<ResidentProvider>().logEmergency(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header - Extracted to separate widget with Selector to reduce rebuilds
            const ResidentHomeHeader(),

            // Main Content
            Expanded(
              child: Consumer<ResidentProvider>(
                builder: (context, residentProvider, _) {
                  final pendingVisitors = residentProvider.getPendingApprovals();
                  final hasPendingRequest = pendingVisitors.isNotEmpty;

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Pending Request Card
                            if (hasPendingRequest) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pending Request',
                                    style: theme.textTheme.titleLarge,
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
                                          style: theme.textTheme.labelSmall?.copyWith(
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
                              InkWell(
                                onTap: () => context.push(
                                  '/visitor_details/${pendingVisitors.first.id}?source=resident',
                                ),
                                child: _PendingVisitorCard(
                                  visitor: pendingVisitors.first,
                                  onApprove: () async {
                                    try {
                                      await residentProvider.approveVisitor(
                                        pendingVisitors.first.id,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Visitor approved'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: AppTheme.errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  onReject: () async {
                                    try {
                                      await residentProvider.rejectVisitor(
                                        pendingVisitors.first.id,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Visitor rejected'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: AppTheme.errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                            // Recent History Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent History',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (residentProvider.todaysVisitors.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
                                  child: Text(
                                    'No recent visitors',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),
                      // Virtualized List
                      if (residentProvider.isLoading)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return const ShimmerListItem();
                              },
                              childCount: 5,
                            ),
                          ),
                        )
                      else if (residentProvider.todaysVisitors.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final visitor =
                                    residentProvider.todaysVisitors[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => context.push(
                                      '/visitor_details/${visitor.id}?source=resident',
                                    ),
                                    child: _HistoryCard(visitor: visitor),
                                  ),
                                );
                              },
                              childCount: residentProvider.todaysVisitors.length,
                            ),
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
      bottomNavigationBar: const _ResidentBottomNav(currentIndex: 0),
    );
  }
}

class _PendingVisitorCard extends StatefulWidget {
  final Visitor visitor;
  final Future<void> Function() onApprove;
  final Future<void> Function() onReject;

  const _PendingVisitorCard({
    required this.visitor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PendingVisitorCard> createState() => _PendingVisitorCardState();
}

class _PendingVisitorCardState extends State<_PendingVisitorCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    await action();
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
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
                    color: theme.dividerColor.withOpacity(0.1), // Subtler placeholder
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: theme.textTheme.bodyMedium?.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.visitor.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.visitor.type.replaceFirst(
                            widget.visitor.type[0],
                            widget.visitor.type[0].toUpperCase(),
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
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
                Icon(
                  Icons.security,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Guard: Ramesh', // Ideally this should be dynamic too
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Arrived 1 min ago', // Ideally dynamic
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _handleAction(widget.onReject),
                    icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.close),
                    label: Text(_isProcessing ? 'Wait...' : 'Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _handleAction(widget.onApprove),
                    icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.check),
                    label: Text(_isProcessing ? 'Wait...' : 'Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Visitor visitor;

  // OPTIMIZE: Cached formatter to avoid recreation on every build
  static final _timeFormatter = DateFormat('h:mm a');

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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
            ),
            child: Icon(
              _getTypeIcon(),
              size: 20,
              color: theme.textTheme.bodySmall?.color,
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
                  _timeFormatter.format(visitor.date),
                  style: theme.textTheme.labelSmall,
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
              style: theme.textTheme.labelSmall?.copyWith(
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
