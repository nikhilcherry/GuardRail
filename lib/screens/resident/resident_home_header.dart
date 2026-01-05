import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coming_soon.dart';
import '../../providers/resident_provider.dart';
import '../../providers/flat_provider.dart';
import '../../providers/auth_provider.dart';

class ResidentHomeHeader extends StatelessWidget {
  const ResidentHomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using Selector to listen only to specific changes
    // This reduces rebuilds when other parts of the providers change (like visitor lists)
    return Selector2<ResidentProvider, FlatProvider, _HeaderData>(
      selector: (context, residentProvider, flatProvider) {
        final currentFlat = flatProvider.currentFlat;
        final hasFlat = currentFlat != null;
        final pendingMembersCount = flatProvider.pendingMembers.length;

        // We need auth provider data too, but it's likely stable.
        // We can access it via context.read inside the selector calculation if needed,
        // but standard practice is to pass it or rely on parent rebuilds if it changes.
        // However, user ID rarely changes.
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.userPhone ?? authProvider.userEmail ?? 'user';
        final isOwner = hasFlat && flatProvider.members.any((m) => m.role == MemberRole.owner && m.userId == userId);

        return _HeaderData(
          residentName: residentProvider.residentName,
          pendingRequests: residentProvider.pendingRequests,
          hasFlat: hasFlat,
          pendingMembersCount: pendingMembersCount,
          isOwner: isOwner,
        );
      },
      builder: (context, data, _) {
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
                      Text(
                        data.residentName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                        ),
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
                          if (data.pendingRequests > 0 || (data.isOwner && data.pendingMembersCount > 0))
                            Positioned(
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
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
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
                            data.hasFlat ? Icons.home : Icons.add_home_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data.hasFlat ? 'Manage Family' : 'Manage Flat',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          if (data.isOwner && data.pendingMembersCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                data.pendingMembersCount.toString(),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderData {
  final String residentName;
  final int pendingRequests;
  final bool hasFlat;
  final int pendingMembersCount;
  final bool isOwner;

  _HeaderData({
    required this.residentName,
    required this.pendingRequests,
    required this.hasFlat,
    required this.pendingMembersCount,
    required this.isOwner,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HeaderData &&
          runtimeType == other.runtimeType &&
          residentName == other.residentName &&
          pendingRequests == other.pendingRequests &&
          hasFlat == other.hasFlat &&
          pendingMembersCount == other.pendingMembersCount &&
          isOwner == other.isOwner;

  @override
  int get hashCode =>
      residentName.hashCode ^
      pendingRequests.hashCode ^
      hasFlat.hashCode ^
      pendingMembersCount.hashCode ^
      isOwner.hashCode;
}
