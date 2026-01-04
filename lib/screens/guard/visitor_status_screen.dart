import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/guard_provider.dart';

class VisitorStatusScreen extends StatelessWidget {
  final String entryId;

  const VisitorStatusScreen({Key? key, required this.entryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<GuardProvider>(
      builder: (context, guardProvider, child) {
        // Find the entry in the provider to get the latest status
        VisitorEntry? entry;
        try {
          entry = guardProvider.entries.firstWhere((e) => e.id == entryId);
        } catch (_) {
          // If not found (shouldn't happen), use a dummy or pop
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        Color statusColor;
        IconData statusIcon;
        String statusTitle;
        String statusMessage;

        switch (entry.status.toLowerCase()) {
          case 'approved':
            statusColor = const Color(0xFF2ECC71); // Successful Green
            statusIcon = Icons.check_circle_outline;
            statusTitle = 'Access Granted';
            statusMessage = 'Visitor is authorized to enter.';
            break;
          case 'rejected':
            statusColor = const Color(0xFFE74C3C); // Error Red
            statusIcon = Icons.cancel_outlined;
            statusTitle = 'Access Denied';
            statusMessage = 'Visitor has been rejected.';
            break;
          default:
            statusColor = const Color(0xFFF1C40F); // Pending Yellow
            statusIcon = Icons.hourglass_empty;
            statusTitle = 'Pending Approval';
            statusMessage = 'Waiting for resident to respond...';
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Background Glow with status-based color
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.05),
                  ),
                ),
              ).animate(key: ValueKey('glow_${entry.status}')).fadeIn(duration: 800.ms),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      
                      // Status Icon with Animated Rings (UPI style)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(), key: ValueKey('rings_${entry.status}'))
                           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2000.ms, curve: Curves.easeOut)
                           .fadeOut(),
                          
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(statusIcon, size: 56, color: statusColor),
                          ).animate(key: ValueKey('icon_${entry.status}')).scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Status Text
                      Text(
                        statusTitle,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate(key: ValueKey('title_${entry.status}')).fadeIn(delay: 300.ms).moveY(begin: 20, end: 0, duration: 400.ms),

                      const SizedBox(height: 12),

                      Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ).animate(key: ValueKey('msg_${entry.status}')).fadeIn(delay: 500.ms),

                      const SizedBox(height: 60),

                      // Visitor Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            _infoRow('Visitor', entry!.name, theme),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1),
                            ),
                            _infoRow('Flat', entry.flatNumber, theme),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1),
                            ),
                            _infoRow('Purpose', entry.purpose.toUpperCase(), theme),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1),
                            ),
                            _infoRow('Time', DateFormat('hh:mm a, dd MMM').format(entry.time), theme),
                          ],
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(duration: 400.ms, curve: Curves.easeOut),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'DONE',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ).animate().fadeIn(delay: 900.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
