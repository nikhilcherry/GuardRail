import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/flat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class FlatManagementScreen extends StatefulWidget {
  const FlatManagementScreen({Key? key}) : super(key: key);

  @override
  State<FlatManagementScreen> createState() => _FlatManagementScreenState();
}

class _FlatManagementScreenState extends State<FlatManagementScreen> {
  final _flatNameController = TextEditingController();
  final _flatIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userPhone ?? authProvider.userEmail ?? 'user';
      // Refresh flat status when entering screen to ensure we have latest data
      context.read<FlatProvider>().checkUserFlatStatus(userId);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _flatNameController.dispose();
    _flatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final flatProvider = context.watch<FlatProvider>();
    final userId = authProvider.userPhone ?? authProvider.userEmail ?? 'user';

    // Determine user status in current flat
    FlatMember? currentUserMember;
    if (flatProvider.currentFlat != null) {
      try {
        currentUserMember = flatProvider.members.firstWhere((m) => m.userId == userId);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Manage Flat',
          style: theme.textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
        actions: [
           if (flatProvider.currentFlat != null)
             IconButton(
               icon: const Icon(Icons.refresh),
               color: theme.iconTheme.color,
               onPressed: () => flatProvider.refreshFlatData(),
             ),
        ],
      ),
      body: SafeArea(
        child: flatProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(context, theme, flatProvider, authProvider, currentUserMember),
              ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    FlatProvider flatProvider,
    AuthProvider authProvider,
    FlatMember? currentUserMember,
  ) {
    // 1. No Flat -> Show Create/Join
    if (flatProvider.currentFlat == null) {
      return _buildCreateOrJoin(context, theme, flatProvider, authProvider);
    }

    // 2. Pending Member -> Show Pending Status (Waiting for Owner)
    if (currentUserMember != null && currentUserMember.status == MemberStatus.pending) {
       return _buildPendingState(context, theme, 'Membership Request Pending',
         'You have requested to join ${flatProvider.currentFlat?.name ?? "a flat"}.\nWaiting for flat owner approval.');
    }

    // 3. Pending Flat -> Show Pending Flat Status (Waiting for Admin)
    if (flatProvider.currentFlat!.status == FlatStatus.pending) {
       return _buildPendingState(context, theme, 'Flat Creation Pending',
         'Your flat "${flatProvider.currentFlat?.name}" is waiting for Admin approval.');
    }

    // 4. Rejected Flat
    if (flatProvider.currentFlat!.status == FlatStatus.rejected) {
       return _buildRejectedState(context, theme, flatProvider);
    }

    // 5. Accepted -> Show Details
    return _buildFlatDetails(context, theme, flatProvider, authProvider);
  }

  Widget _buildPendingState(BuildContext context, ThemeData theme, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.hourglass_empty, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () {
              // Optionally allow canceling request or going back
               context.pop();
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedState(BuildContext context, ThemeData theme, FlatProvider flatProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 24),
          Text(
            'Request Rejected',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your request for flat "${flatProvider.currentFlat?.name}" was rejected.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () {
               flatProvider.clearState(); // Allow user to try again
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, String flatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this Flat ID with your family members to let them join:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                flatId,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'They can enter this ID when creating their account or in the "Join Flat" section.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOrJoin(
    BuildContext context,
    ThemeData theme,
    FlatProvider flatProvider,
    AuthProvider authProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (flatProvider.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    flatProvider.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Join your family',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Create a new flat or join an existing one using the Flat ID.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 32),

        // Create Flat Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Flat',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _flatNameController,
                  validator: Validators.validateFlatNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Flat Name (e.g. "Flat 402")',
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                         await flatProvider.createFlat(
                          _flatNameController.text,
                          authProvider.userPhone ?? authProvider.userEmail ?? 'user',
                          authProvider.userName ?? 'User',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create Flat'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: theme.textTheme.bodySmall),
            ),
            Expanded(child: Divider(color: theme.dividerColor)),
          ],
        ),
        const SizedBox(height: 24),

        // Join Flat Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Existing Flat',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Flat ID',
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_flatIdController.text.isNotEmpty) {
                      await flatProvider.joinFlat(
                        _flatIdController.text.toUpperCase(),
                        authProvider.userPhone ?? authProvider.userEmail ?? 'user',
                        authProvider.userName ?? 'User',
                      );
                      // On success, the UI will rebuild and show Pending State because checkUserFlatStatus is called inside joinFlat
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Join Flat'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlatDetails(
    BuildContext context,
    ThemeData theme,
    FlatProvider flatProvider,
    AuthProvider authProvider,
  ) {
    final flat = flatProvider.currentFlat!;
    final userId = authProvider.userPhone ?? authProvider.userEmail ?? 'user';
    final isOwner = flat.ownerId == userId;
    final pendingMembers = flatProvider.pendingMembers;
    final activeMembers = flatProvider.activeMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flat.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy, size: 16, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${flat.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Add Family Member Button (Owner Only)
        if (isOwner)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Family Member'),
              onPressed: () {
                _showShareDialog(context, flat.id);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

        const SizedBox(height: 32),

        // Pending Requests (Only for Owner)
        if (isOwner && pendingMembers.isNotEmpty) ...[
          Text(
            'Pending Requests',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingMembers.length,
            itemBuilder: (context, index) {
              final member = pendingMembers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Request to join',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle),
                      color: AppTheme.successGreen,
                      onPressed: () => flatProvider.approveMember(member.userId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: AppTheme.errorRed,
                      onPressed: () => flatProvider.rejectMember(member.userId),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],

        // Active Members
        Text(
          'Family Members',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeMembers.length,
          itemBuilder: (context, index) {
            final member = activeMembers[index];
            final isMe = member.userId == userId;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                    child: Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              member.name,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'YOU',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          member.role == MemberRole.owner ? 'Admin' : 'Member',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
