import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';
import '../../providers/flat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/coming_soon.dart';

class ResidentHomeHeader extends StatelessWidget {
  const ResidentHomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using Selector to listen only to specific changes
    // This optimization ensures the header doesn't rebuild when the visitor list changes
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resident Portal',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Good Evening,',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Selector<ResidentProvider, String>(
                    selector: (context, provider) => provider.residentName,
                    builder: (context, residentName, child) {
                      return Text(
                        residentName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                        ),
                      );
                    },
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showComingSoonDialog(
                    context,
                    title: 'Notifications',
                    message: 'We are adding a notification center to keep you updated on all activities.',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      // Combine providers to check for badges
                      // We use a custom Selector-like approach by nesting consumers or using a Consumer2
                      // effectively, but since this is a small icon, a Consumer2 is fine here as it is isolated
                      // from the main list.
                      Consumer2<ResidentProvider, FlatProvider>(
                        builder: (context, residentProvider, flatProvider, _) {
                          final currentFlat = flatProvider.currentFlat;
                          final hasFlat = currentFlat != null;
                          final isOwner = hasFlat && flatProvider.members.any((m) => m.role == MemberRole.owner && m.userId == (context.read<AuthProvider>().userPhone ?? context.read<AuthProvider>().userEmail ?? 'user'));
                          final pendingMembersCount = flatProvider.pendingMembers.length;

                          if (residentProvider.pendingRequests > 0 || (isOwner && pendingMembersCount > 0)) {
                             return Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: theme.cardColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<FlatProvider>(
            builder: (context, flatProvider, _) {
              final currentFlat = flatProvider.currentFlat;
              final hasFlat = currentFlat != null;
              final pendingMembersCount = flatProvider.pendingMembers.length;
              // Check owner status. Note: We access AuthProvider here.
              // Since AuthProvider user info rarely changes during a session, context.read is safe for the check logic
              // but if we want to be 100% reactive to role changes, we might need it in the consumer.
              // However, typically we just need to know if the current user is owner.
              final authProvider = context.read<AuthProvider>();
              final userId = authProvider.userPhone ?? authProvider.userEmail ?? 'user';
              final isOwner = hasFlat && flatProvider.members.any((m) => m.role == MemberRole.owner && m.userId == userId);

              return Row(
                children: [
                  InkWell(
                    onTap: () => context.go('/resident_home/flat'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasFlat ? Icons.home : Icons.add_home_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasFlat ? 'Manage Family' : 'Manage Flat',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          if (isOwner && pendingMembersCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                pendingMembersCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => context.go('/resident_home/generate_qr'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'New Invite',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
