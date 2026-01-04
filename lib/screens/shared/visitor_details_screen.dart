import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/guard_provider.dart';
import '../../providers/resident_provider.dart';
import '../../widgets/visitor_dialog.dart';

class VisitorDetailsScreen extends StatefulWidget {
  final String visitorId;
  final String source; // 'resident' or 'guard'

  const VisitorDetailsScreen({
    Key? key,
    required this.visitorId,
    required this.source,
  }) : super(key: key);

  @override
  State<VisitorDetailsScreen> createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  // Common visitor data structure
  late String _name;
  late String _id;
  late String _status;
  late String _type;
  late DateTime _time;
  String? _flatNumber;
  String? _profileImage;
  String? _guardName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuard = widget.source == 'guard';

    // Fetch data based on source
    // We use Builder or Consumer to get the data safely
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Visitor Details',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          if (isGuard)
            IconButton(
              icon: Icon(Icons.edit, color: theme.iconTheme.color),
              onPressed: () {
                _showEditDialog(context);
              },
            ),
        ],
      ),
      body: isGuard
          ? Consumer<GuardProvider>(builder: (context, provider, _) {
              try {
                final entry = provider.entries
                    .firstWhere((e) => e.id == widget.visitorId);
                _mapGuardData(entry);
                return _buildContent(context, theme, provider.entries);
              } catch (e) {
                return const Center(child: Text('Visitor not found'));
              }
            })
          : Consumer<ResidentProvider>(builder: (context, provider, _) {
              try {
                // Check pending first, then all visitors
                var visitor = provider.allVisitors
                    .cast<Visitor?>()
                    .firstWhere((v) => v?.id == widget.visitorId,
                        orElse: () => null);

                if (visitor == null) {
                   // Fallback to checking pending specifically if not in allVisitors (though it should be)
                   final pending = provider.getPendingApprovals();
                    visitor = pending.cast<Visitor?>().firstWhere((v) => v?.id == widget.visitorId, orElse: () => null);
                }

                if (visitor == null) {
                    return const Center(child: Text('Visitor not found'));
                }

                _mapResidentData(visitor);
                return _buildContent(context, theme, provider.allVisitors);
              } catch (e) {
                return Center(child: Text('Error: $e'));
              }
            }),
    );
  }

  void _mapGuardData(VisitorEntry entry) {
    _id = entry.id;
    _name = entry.name;
    _status = entry.status;
    _type = entry.purpose;
    _time = entry.time;
    _flatNumber = entry.flatNumber;
    _guardName = entry.guardName;
  }

  void _mapResidentData(Visitor visitor) {
    _id = visitor.id;
    _name = visitor.name;
    _status = visitor.status;
    _type = visitor.type;
    _time = visitor.date;
    _profileImage = visitor.profileImage;
  }

  Widget _buildContent(BuildContext context, ThemeData theme, List<dynamic> allHistory) {
    // Filter history for this visitor (by name)
    final history = allHistory.where((v) {
      if (v is VisitorEntry) return v.name == _name && v.id != _id;
      if (v is Visitor) return v.name == _name && v.id != _id;
      return false;
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 2,
                      ),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: NetworkImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: theme.disabledColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(theme),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info Grid
            Text('Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  if (_flatNumber != null) ...[
                    _buildInfoRow(theme, 'Flat Number', _flatNumber!),
                    const Divider(height: 24),
                  ],
                  _buildInfoRow(
                    theme,
                    'Purpose',
                    _type.replaceFirst(_type[0], _type[0].toUpperCase()),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    theme,
                    'Entry Time',
                    DateFormat('MMM d, y • h:mm a').format(_time),
                  ),
                  if (_guardName != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(theme, 'Checked in by', _guardName!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Timeline (Simplified)
            Text('Timeline', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                   _buildTimelineItem(
                    theme,
                    title: 'Checked In',
                    time: _time,
                    isLast: _status != 'approved' && _status != 'rejected',
                    isActive: true,
                  ),
                  if (_status == 'approved' || _status == 'rejected')
                    _buildTimelineItem(
                      theme,
                      title: _status == 'approved' ? 'Approved' : 'Rejected',
                      time: _time.add(const Duration(minutes: 5)), // Mock delay
                      isLast: true,
                      isActive: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // History
            if (history.isNotEmpty) ...[
              Text('Visit History', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              ...history.map((h) {
                final date = h is VisitorEntry ? h.time : (h as Visitor).date;
                final status = h is VisitorEntry ? h.status : (h as Visitor).status;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                         DateFormat('MMM d, y • h:mm a').format(date),
                         style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        status.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status == 'approved'
                              ? AppTheme.successGreen
                              : (status == 'rejected' ? AppTheme.errorRed : AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),

            // Actions
            if (widget.source == 'resident' && _status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                         await context.read<ResidentProvider>().rejectVisitor(_id);
                         if (context.mounted) context.pop();
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await context.read<ResidentProvider>().approveVisitor(_id);
                        if (context.mounted) context.pop();
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),

            if (widget.source == 'resident' && _status != 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove from Log'),
                   style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: BorderSide(color: AppTheme.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                  onPressed: () {
                    // Logic to remove would go here
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
                  },
                ),
              ),

             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color color;
    IconData icon;

    switch (_status.toLowerCase()) {
      case 'approved':
        color = AppTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppTheme.errorRed;
        icon = Icons.cancel;
        break;
      default:
        color = const Color(0xFFF1C40F);
        icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _status.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(ThemeData theme, {required String title, required DateTime time, required bool isLast, required bool isActive}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? theme.colorScheme.primary : theme.disabledColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.dividerColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  Text(
                    DateFormat('h:mm a').format(time),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
         // Assuming we have access to the entry for initial values
         final entry = context.read<GuardProvider>().entries.firstWhere((e) => e.id == widget.visitorId);
         return VisitorDialog(entry: entry);
      },
    );
  }
}
