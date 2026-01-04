import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guard_provider.dart';
import '../screens/guard/visitor_status_screen.dart';

class VisitorDialog extends StatefulWidget {
  final VisitorEntry? entry;
  const VisitorDialog({Key? key, this.entry}) : super(key: key);

  @override
  State<VisitorDialog> createState() => _VisitorDialogState();
}

class _VisitorDialogState extends State<VisitorDialog> {
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
                      VisitorEntry? entry;
                      if (editing) {
                        await guard.updateVisitorEntry(
                          id: widget.entry!.id,
                          name: nameCtrl.text,
                          flatNumber: flatCtrl.text,
                          purpose: purpose,
                        );
                        entry = widget.entry;
                      } else {
                        entry = await guard.registerNewVisitor(
                          name: nameCtrl.text,
                          flatNumber: flatCtrl.text,
                          purpose: purpose,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context); // Close dialog

                        // If we are editing, we might be on details screen, so just pop.
                        // If registering, we probably want to see status.
                        if (!editing && entry != null) {
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
    );
  }
}
