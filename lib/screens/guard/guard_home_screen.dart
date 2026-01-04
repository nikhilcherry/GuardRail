import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_entry_card.dart';
import '../../utils/validators.dart';
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Gate Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Guard Checks',
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        _QuickActions(),
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
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VisitorStatusScreen(entryId: entry.id)),
                                  ),
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
    );
  }

  void _showVisitorDialog(BuildContext context, {VisitorEntry? entry}) {
    showDialog(
      context: context,
      builder: (context) => _VisitorDialog(entry: entry),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Manual Registration
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.person_add_outlined,
            label: 'Register\nVisitor',
            onTap: () => showDialog(
              context: context,
              builder: (context) => const _VisitorDialog(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // QR Scanning
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.qr_code_scanner,
            label: 'Scan\nVisitor QR',
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

class _VisitorDialog extends StatefulWidget {
  final VisitorEntry? entry;
  const _VisitorDialog({this.entry});

  @override
  State<_VisitorDialog> createState() => _VisitorDialogState();
}

class _VisitorDialogState extends State<_VisitorDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController flatCtrl;
  late TextEditingController vehicleCtrl;
  final _formKey = GlobalKey<FormState>();
  String purpose = 'guest';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.entry?.name ?? '');
    flatCtrl = TextEditingController(text: widget.entry?.flatNumber ?? '');
    vehicleCtrl = TextEditingController(text: widget.entry?.vehicleNumber ?? '');
    purpose = widget.entry?.purpose ?? 'guest';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    flatCtrl.dispose();
    vehicleCtrl.dispose();
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(editing ? 'Edit Visitor' : 'Register Visitor',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),

                TextFormField(
                  controller: flatCtrl,
                  decoration: const InputDecoration(labelText: 'Flat Number'),
                  validator: Validators.validateFlatNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Visitor Name'),
                  validator: Validators.validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: vehicleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number (Optional)',
                    helperText: 'Format: KA05AB1234'
                  ),
                  validator: Validators.validateVehicleNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.characters,
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
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => loading = true);

                          final guard = context.read<GuardProvider>();
                          VisitorEntry? entry;
                          if (editing) {
                            await guard.updateVisitorEntry(
                              id: widget.entry!.id,
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              vehicleNumber: vehicleCtrl.text.isNotEmpty ? vehicleCtrl.text : null,
                            );
                            entry = widget.entry;
                          } else {
                            entry = await guard.registerNewVisitor(
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              vehicleNumber: vehicleCtrl.text.isNotEmpty ? vehicleCtrl.text : null,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                            if (entry != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitorStatusScreen(entryId: entry!.id),
                                ),
                              );
                            }
                          }
                        },
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(editing ? 'Save' : 'Register'),
                ),
              ],
            ),
          ),
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
