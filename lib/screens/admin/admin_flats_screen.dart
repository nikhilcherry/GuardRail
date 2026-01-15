import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/validators.dart';
import 'widgets/admin_scaffold.dart';

class AdminFlatsScreen extends StatefulWidget {
  const AdminFlatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminFlatsScreen> createState() => _AdminFlatsScreenState();
}

class _AdminFlatsScreenState extends State<AdminFlatsScreen>
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final pendingFlats = adminProvider.pendingFlats;
        final activeFlats = adminProvider.activeFlats;

        return AdminScaffold(
          title: 'Flats',
          currentIndex: 1,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    _AdminFlatDialog(provider: adminProvider),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Container(
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.bodySmall?.color,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    Tab(text: 'Requests (${pendingFlats.length})'),
                    Tab(text: 'Active (${activeFlats.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pending Requests
                    pendingFlats.isEmpty
                        ? const Center(
                            child: Text('No pending requests'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pendingFlats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final flat = pendingFlats[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            flat.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                            ),
                                            child: const Text(
                                              'PENDING',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Owner ID: ${flat.ownerId}'),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit),
                                            tooltip: 'Edit Request',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => _EditNameDialog(
                                                  title: 'Edit Request Details',
                                                  label: 'Flat Name',
                                                  initialValue: flat.name,
                                                  maxLength: 10,
                                                  onSave: (val) {
                                                    adminProvider.updateFlatName(flat.id, val);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  adminProvider
                                                      .rejectFlat(
                                                          flat.id),
                                              style: OutlinedButton
                                                  .styleFrom(
                                                foregroundColor:
                                                    Colors.red,
                                                side: const BorderSide(
                                                    color:
                                                        Colors.red),
                                              ),
                                              child:
                                                  const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  adminProvider
                                                      .approveFlat(
                                                          flat.id),
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                    Colors.green,
                                              ),
                                              child: const Text(
                                                  'Approve'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // Active Flats
                    activeFlats.isEmpty
                        ? const Center(child: Text('No active flats'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: activeFlats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final flat = activeFlats[index];
                              return ListTile(
                                tileColor:
                                    Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                leading: const Icon(
                                    Icons.apartment),
                                title: Text(flat.name),
                                subtitle:
                                    Text('ID: ${flat.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => _EditNameDialog(
                                            title: 'Edit Flat Name',
                                            label: 'Flat Name',
                                            initialValue: flat.name,
                                              maxLength: 10,
                                            onSave: (val) {
                                              adminProvider.updateFlatName(flat.id, val);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Delete Flat'),
                                            content: Text(
                                                'Are you sure you want to delete ${flat.name}?'),
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
                                                  adminProvider
                                                      .deleteFlat(
                                                          flat.id);
                                                  Navigator.pop(
                                                      context);
                                                },
                                                child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .red)),
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

class _AdminFlatDialog extends StatefulWidget {
  final AdminProvider provider;
  final Map<String, dynamic>? flat;

  const _AdminFlatDialog({required this.provider, this.flat});

  @override
  State<_AdminFlatDialog> createState() => _AdminFlatDialogState();
}

class _AdminFlatDialogState extends State<_AdminFlatDialog> {
  late TextEditingController _flatController;
  late TextEditingController _residentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _flatController = TextEditingController(text: widget.flat?['flat'] ?? '');
    _residentController = TextEditingController(
        text: widget.flat?['resident']?.replaceFirst('Owner ID: ', '') ?? '');
  }

  @override
  void dispose() {
    _flatController.dispose();
    _residentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flat != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Flat' : 'Add Flat'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _flatController,
              maxLength: 10, // SECURITY: Prevent large input DoS
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(labelText: 'Flat Name'),
              validator: Validators.validateFlatNumber,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _residentController,
              maxLength: 100, // SECURITY: Prevent large input DoS
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              decoration: const InputDecoration(labelText: 'Owner Name'),
              validator: Validators.validateName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
            if (!_formKey.currentState!.validate()) return;
            if (isEditing) {
              widget.provider.updateFlat(
                widget.flat!['id']!,
                _flatController.text,
                _residentController.text,
              );
            } else {
              widget.provider.addFlat(
                _flatController.text,
                _residentController.text,
              );
            }
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final int maxLength;
  final Function(String) onSave;

  const _EditNameDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    this.maxLength = 100,
    required this.onSave,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: widget.maxLength, // SECURITY: Prevent large input DoS
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onSave(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
