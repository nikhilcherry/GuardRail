import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_entry_card.dart';

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
                  Text('Gate Control', style: theme.textTheme.headlineMedium),
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
                          'Logout',
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
                        children: const [
                          _RegisterVisitorButton(),
                          SizedBox(height: 32),
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

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = guardProvider.entries[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _showVisitorDialog(context, entry: entry),
                                  child: _EntryCard(entry: entry),
                                ),
                              );
                            },
                            childCount: guardProvider.entries.length,
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
      ),
    );
  }

  void _showVisitorDialog(BuildContext context, {VisitorEntry? entry}) {
    showDialog(
      context: context,
      builder: (context) => _VisitorDialog(entry: entry),
    );
  }
}

class _RegisterVisitorButton extends StatelessWidget {
  const _RegisterVisitorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => const _VisitorDialog(),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(Icons.add, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text('Register New Visitor', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _VisitorDialog extends StatefulWidget {
  final VisitorEntry? entry;
  const _VisitorDialog({this.entry});

  @override
  State<_VisitorDialog> createState() => _VisitorDialogState();
}

class _VisitorDialogState extends State<_VisitorDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController flatCtrl;
  String purpose = 'guest';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.entry?.name ?? '');
    flatCtrl = TextEditingController(text: widget.entry?.flatNumber ?? '');
    purpose = widget.entry?.purpose ?? 'guest';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    flatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.entry != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? 'Edit Visitor' : 'Register Visitor',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextField(
              controller: flatCtrl,
              decoration: const InputDecoration(labelText: 'Flat Number'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Visitor Name'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: purpose,
              items: const [
                DropdownMenuItem(value: 'guest', child: Text('Guest')),
                DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                DropdownMenuItem(value: 'service', child: Text('Service')),
              ],
              onChanged: (v) => setState(() => purpose = v!),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final guard = context.read<GuardProvider>();
                      if (editing) {
                        await guard.updateVisitorEntry(
                          id: widget.entry!.id,
                          name: nameCtrl.text,
                          flatNumber: flatCtrl.text,
                          purpose: purpose,
                        );
                      } else {
                        await guard.registerNewVisitor(
                          name: nameCtrl.text,
                          flatNumber: flatCtrl.text,
                          purpose: purpose,
                        );
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(editing ? 'Save' : 'Register'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: theme.textTheme.titleSmall),
                Text('Flat ${entry.flatNumber}',
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Text(DateFormat('HH:mm').format(entry.time),
              style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
