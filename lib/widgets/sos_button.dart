import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback onAction;

  const SOSButton({Key? key, required this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Emergency Alert'),
            content: const Text('Are you sure you want to trigger the SOS alarm?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close confirmation dialog
                  _triggerSOS(context); // Use the parent context
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('CONFIRM SOS'),
              ),
            ],
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Long press to activate SOS')),
          );
        },
        backgroundColor: Colors.red,
        elevation: 6,
        child: const Icon(Icons.sos, color: Colors.white, size: 30),
      ),
    );
  }

  void _triggerSOS(BuildContext context) {
    // Play sound (looping alarm)
    FlutterRingtonePlayer.playAlarm();

    // Log action
    onAction();

    // Show persistent dialog to stop alarm
    showDialog(
      context: context,
      barrierDismissible: false, // User must explicitly tap STOP
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: const Text('SOS ACTIVE', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Emergency alert has been triggered.\nAlarm is sounding.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FlutterRingtonePlayer.stop();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black26,
            ),
            child: const Text('STOP ALARM'),
          ),
        ],
      ),
    );
  }
}
