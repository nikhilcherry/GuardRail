import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../providers/guard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/guard_check.dart';

class GuardCheckScreen extends StatefulWidget {
  const GuardCheckScreen({Key? key}) : super(key: key);

  @override
  State<GuardCheckScreen> createState() => _GuardCheckScreenState();
}

class _GuardCheckScreenState extends State<GuardCheckScreen> {
  bool _isScanning = false;
  MobileScannerController? _scannerController;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _scannerController?.dispose();
      _scannerController = null;
    });
  }

  Future<void> _handleScan(String code) async {
    // Stop scanning immediately to prevent multiple triggers
    _stopScanning();

    // Now capture a photo for verification
    // In a real device scenario, we might want to capture this automatically from the camera feed
    // but MobileScanner doesn't easily support taking a picture while scanning without custom implementation.
    // For this MVP, we will ask the user to take a verification photo or simulate it.

    // We will simulate taking a photo or try to open camera for photo
    try {
       // Since we are in the flow, let's just simulate the photo capture or ask user
       // "Scan valid! Taking verification photo..."

       if (!mounted) return;

       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('QR Code Valid. Taking verification photo...')),
       );

       // Simulate or use ImagePicker
       final XFile? photo = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

       if (photo == null) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification photo required. Check cancelled.')),
            );
          }
          return;
       }

       if (!mounted) return;

       final guardId = context.read<AuthProvider>().userId;


       await context.read<GuardProvider>().processScan(
         qrCode: code,
         photoPath: photo.path,
         guardId: guardId,
       );

       if (!mounted) return;

       // Show Success Dialog
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Row(
             children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Check Complete'),
             ],
           ),
           content: const Text('Guard check has been verified and logged successfully.'),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('OK'),
             ),
           ],
         ),
       );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Checkpoint'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _stopScanning,
          ),
        ),
        body: MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue;
              if (code != null) {
                _handleScan(code);
              }
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guard Checks', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Scan checkpoints to verify your patrol route.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Scan Button
              Center(
                child: InkWell(
                  onTap: _startScanning,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan QR Code',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text('Recent Checks', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              Expanded(
                child: Consumer<GuardProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.checks.isEmpty) {
                      return Center(
                        child: Text(
                          'No checks performed today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider.checks.length,
                      itemBuilder: (context, index) {
                        // PERF: Extracted widget to reduce rebuild scope
                        return _CheckCard(check: provider.checks[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final GuardCheck check;

  const _CheckCard({
    Key? key,
    required this.check,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.green),
        ),
        title: Text('Location: ${check.locationId}'),
        subtitle: Text(
          'Verified at ${TimeOfDay.fromDateTime(check.timestamp).format(context)}',
        ),
        trailing: const Icon(Icons.photo_camera_outlined),
      ),
    );
  }
}
