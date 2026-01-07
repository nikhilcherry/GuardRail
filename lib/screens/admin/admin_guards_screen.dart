import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_scaffold.dart';

class AdminGuardsScreen extends StatefulWidget {
  const AdminGuardsScreen({Key? key}) : super(key: key);

  @override
  State<AdminGuardsScreen> createState() => _AdminGuardsScreenState();
}

class _AdminGuardsScreenState extends State<AdminGuardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final guards = adminProvider.guards;

        return AdminScaffold(
          title: 'Guards',
          currentIndex: 2,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _AdminGuardDialog(provider: adminProvider),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Guard'),
          ),
          body: guards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security_outlined,
                          size: 64,
                          color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      Text('No guards found',
                          style:
                              Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: guards.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final guard = guards[index];
                    final status = guard['status'] as String;
                    final isPending = status == 'pending';

                    Color statusColor;
                    switch (status) {
                      case 'active':
                        statusColor = Colors.green;
                        break;
                      case 'pending':
                        statusColor = Colors.orange;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return ListTile(
                      tileColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(Icons.security, color: statusColor),
                      ),
                      title: Text(guard['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${guard['id']}'),
                          if (guard['linkedUserName'] != null)
                            Text(
                                'User: ${guard['linkedUserName']} (${guard['linkedUserEmail']})'),
                          Text('Status: ${status.toUpperCase()}',
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green),
                                  tooltip: 'Approve',
                                  onPressed: () =>
                                      adminProvider.approveGuard(
                                          guard['id']),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red),
                                  tooltip: 'Reject',
                                  onPressed: () =>
                                      adminProvider.rejectGuard(
                                          guard['id']),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AdminGuardDialog(
                                        provider: adminProvider,
                                        guard: guard,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                        title: const Text(
                                            'Delete Guard'),
                                        content: Text(
                                            'Are you sure you want to delete ${guard['name']}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context),
                                            child: const Text(
                                                'Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              adminProvider.deleteGuard(
                                                  guard['id']);
                                              Navigator.pop(
                                                  context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color:
                                                      Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _AdminGuardDialog extends StatefulWidget {
  final AdminProvider provider;
  final Map<String, dynamic>? guard;

  const _AdminGuardDialog({required this.provider, this.guard});

  @override
  State<_AdminGuardDialog> createState() => _AdminGuardDialogState();
}

class _AdminGuardDialogState extends State<_AdminGuardDialog> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  bool _isManualId = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.guard != null;
    _nameController = TextEditingController(text: widget.guard?['name'] ?? '');
    _idController = TextEditingController(text: widget.guard?['id'] ?? '');
    _isManualId = isEditing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.guard != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Guard' : 'Create Guard Invite'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guard Details'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Guard Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (!isEditing) ...[
              Row(
                children: [
                  Checkbox(
                    value: _isManualId,
                    onChanged: (val) {
                      setState(() {
                        _isManualId = val ?? false;
                        if (!_isManualId) _idController.clear();
                      });
                    },
                  ),
                  const Text('Enter Manual ID'),
                ],
              ),
            ],
            if (_isManualId || isEditing)
              TextField(
                controller: _idController,
                enabled: isEditing || _isManualId,
                decoration: const InputDecoration(
                  labelText: 'Guard ID',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to auto-generate (if creating)',
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              setState(() => _error = 'Name is required');
              return;
            }

            try {
              if (isEditing) {
                widget.provider.updateGuard(
                  widget.guard!['id'],
                  name: _nameController.text.trim(),
                  newId: _idController.text.trim().isNotEmpty
                      ? _idController.text.trim()
                      : null,
                );
              } else {
                widget.provider.createGuardInvite(
                    _nameController.text.trim(),
                    manualId: _isManualId &&
                            _idController.text.trim().isNotEmpty
                        ? _idController.text.trim()
                        : null);
              }
              Navigator.pop(context);
            } catch (e) {
              setState(() =>
                  _error = e.toString().replaceAll('Exception: ', ''));
            }
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
