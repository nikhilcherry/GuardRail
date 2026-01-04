import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_entry_card.dart';
import 'guard_check_screen.dart';
import 'qr_scanner_screen.dart';
import 'visitor_status_screen.dart';

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
  String purpose = 'guest';
  bool loading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Track if the image has been modified during this session
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.entry?.name ?? '');
    flatCtrl = TextEditingController(text: widget.entry?.flatNumber ?? '');
    purpose = widget.entry?.purpose ?? 'guest';
    if (widget.entry?.photoPath != null) {
      _imageFile = XFile(widget.entry!.photoPath!);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    flatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _imageFile = photo;
          _imageChanged = true;
        });
      }
    } catch (e) {
      // Handle camera error or permission denial gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open camera: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.entry != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(editing ? 'Edit Visitor' : 'Register Visitor',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),

              // Photo Capture Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(File(_imageFile!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Icon(Icons.camera_alt,
                          size: 40, color: theme.disabledColor)
                      : null,
                ),
              ),
              if (_imageFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Tap to take photo',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.disabledColor)),
                ),

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

                        try {
                          String? savedPhotoPath;

                          if (_imageFile != null) {
                             if (_imageChanged) {
                               // Only save if changed (new photo)
                               final directory = await getApplicationDocumentsDirectory();
                               final fileName = 'visitor_${DateTime.now().millisecondsSinceEpoch}.jpg';
                               final savedImage = await File(_imageFile!.path).copy(path.join(directory.path, fileName));
                               savedPhotoPath = savedImage.path;
                             } else {
                               // Keep existing path
                               savedPhotoPath = widget.entry?.photoPath;
                             }
                          } else {
                             // _imageFile is null, so photo might have been removed or never existed
                             savedPhotoPath = null;
                          }

                          final guard = context.read<GuardProvider>();
                          VisitorEntry? entry;
                          if (editing) {
                            await guard.updateVisitorEntry(
                              id: widget.entry!.id,
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              photoPath: savedPhotoPath,
                            );
                            entry = widget.entry; // This is actually the old entry object, provider will update list
                          } else {
                            entry = await guard.registerNewVisitor(
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              photoPath: savedPhotoPath,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                            if (entry != null && !editing) {
                              // Only navigate for new entries, or maybe both?
                              // Original code navigated for new/edit. Let's keep it consistent.
                              // But wait, updateVisitorEntry returns void.
                              // So we can't easily get the updated entry object without fetching it again.
                              // The previous logic for edit: entry = widget.entry
                              // But widget.entry is stale.
                              // However, for navigation to StatusScreen, ID is enough.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitorStatusScreen(entryId: editing ? widget.entry!.id : entry!.id),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => loading = false);
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
