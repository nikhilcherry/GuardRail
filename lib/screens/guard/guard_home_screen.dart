import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

import '../../theme/app_theme.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_entry_card.dart';
import '../../widgets/visitor_dialog.dart';
import 'guard_check_screen.dart';
import 'qr_scanner_screen.dart';
import 'visitor_status_screen.dart';
import '../../widgets/sos_button.dart';

class GuardHomeScreen extends StatefulWidget {
  const GuardHomeScreen({Key? key}) : super(key: key);

  @override
  State<GuardHomeScreen> createState() => _GuardHomeScreenState();
}

class _GuardHomeScreenState extends State<GuardHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: SOSButton(
        onAction: () => context.read<GuardProvider>().logEmergency(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.disabledColor,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.security),
            label: l10n.gateControl,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            label: l10n.guardChecks,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _GateControlView(),
          GuardCheckScreen(),
        ],
      ),
    );
  }
}

class _GateControlView extends StatefulWidget {
  const _GateControlView();

  @override
  State<_GateControlView> createState() => _GateControlViewState();
}

class _GateControlViewState extends State<_GateControlView> {
  bool _showOnlyInside = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                  ),
                ),
                Text(l10n.gateControl, style: theme.textTheme.headlineMedium),
                InkWell(
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (mounted) context.go('/');
                  },
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: theme.colorScheme.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.logout,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const _QuickActions(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.recentActivity,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FilterChip(
                              label: Text(l10n.currentlyInside),
                              selected: _showOnlyInside,
                              onSelected: (val) => setState(() => _showOnlyInside = val),
                              checkmarkColor: theme.colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                Consumer<GuardProvider>(
                  builder: (context, guardProvider, _) {
                    if (guardProvider.isLoading) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const ShimmerEntryCard(),
                          childCount: 5,
                        ),
                      );
                    }

                    final entries = _showOnlyInside
                        ? guardProvider.entries
                            .where((e) => e.status == 'approved' && e.exitTime == null)
                            .toList()
                        : guardProvider.entries;

                    if (entries.isEmpty) {
                       return SliverToBoxAdapter(
                         child: Padding(
                           padding: const EdgeInsets.all(40),
                           child: Center(
                             child: Text(
                               l10n.noVisitorsFound,
                               style: theme.textTheme.bodyLarge?.copyWith(
                                 color: theme.disabledColor,
                               ),
                             ),
                           ),
                         ),
                       );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = entries[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => context.push(
                                    '/visitor_details/${entry.id}?source=guard',
                                  ),
                                  child: _EntryCard(entry: entry),
                                ),
                            );
                          },
                          childCount: entries.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _QuickActions extends StatelessWidget {
  const _QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Manual Registration
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.person_add_outlined,
            label: l10n.registerVisitorMultiline,
            onTap: () => showDialog(
              context: context,
              builder: (context) => const VisitorDialog(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // QR Scanning
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.qr_code_scanner,
            label: l10n.scanVisitorQRMultiline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}


class _EntryCard extends StatelessWidget {
  final VisitorEntry entry;
  const _EntryCard({required this.entry});

  // PERF: Cached formatter to avoid recreation on every build
  static final _timeFormatter = DateFormat('HH:mm');

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isApproved = entry.status == 'approved';
    final isInside = isApproved && entry.exitTime == null;
    final duration = entry.exitTime != null ? entry.exitTime!.difference(entry.time) : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          // Thumbnail
          GestureDetector(
            onTap: entry.photoPath != null
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InteractiveViewer(
                              child: Image.file(File(entry.photoPath!)),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                image: entry.photoPath != null
                    ? DecorationImage(
                        image: FileImage(File(entry.photoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: entry.photoPath == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name, style: theme.textTheme.titleSmall),
                    if (isInside) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green, width: 0.5),
                        ),
                        child: Text(
                          l10n.inside,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text('${l10n.flat} ${entry.flatNumber}',
                    style: theme.textTheme.labelSmall),
                if (entry.vehicleType != null && entry.vehicleType != 'None') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.directions_car, size: 12, color: theme.disabledColor),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.vehicleType} ${entry.vehicleNumber ?? ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (duration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${l10n.duration}: ${_formatDuration(duration)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.disabledColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_timeFormatter.format(entry.time),
                  style: theme.textTheme.labelSmall),
              if (entry.exitTime != null)
                Text(
                  '${l10n.exit}: ${_timeFormatter.format(entry.exitTime!)}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.disabledColor),
                ),
              if (isInside)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      // Prevent row tap
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.markExitTitle),
                          content: Text(l10n.markExitMessage(entry.name)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<GuardProvider>().markExit(entry.id);
                                Navigator.pop(context);
                              },
                              child: Text(l10n.confirm),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        l10n.markExitAction,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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