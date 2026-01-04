import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/guard_provider.dart';
import 'visitor_status_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isDisposed = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isDisposed) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Pause scanner
        _controller.stop();
        
        // In a real app, we would parse this QR code (e.g. from a Resident's Pre-approval)
        // For this demo, we'll simulate finding a visitor linked to this QR.
        
        if (mounted) {
           // Show loading or immediately register
           final guardProvider = context.read<GuardProvider>();
           
           // Mock logic: 
           // If code contains 'resident', it's a pre-approval
           // If not, it's just a generic scan
           
           try {
             final entry = await guardProvider.registerNewVisitor(
               name: 'QR Visitor (${code.substring(0, code.length > 5 ? 5 : code.length)})',
               flatNumber: 'A-101', // Mock flat
               purpose: 'Pre-approved',
             );
             
             if (mounted) {
               Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                   builder: (context) => VisitorStatusScreen(entryId: entry.id),
                 ),
               );
             }
           } catch (e) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Error processing QR: $e')),
               );
               _controller.start();
             }
           }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Visitor QR'),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
