import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class IDVerificationScreen extends StatefulWidget {
  const IDVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  final _idController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPendingApproval = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _handleVerification() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verifyId(id);
      // Navigation is handled by AppRouter based on isVerified state change
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'PENDING_APPROVAL') {
        setState(() {
          _isPendingApproval = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuard = authProvider.selectedRole == 'guard';
    final roleTitle = isGuard ? 'Guard' : 'Resident';

    // Theme colors extracted from user request
    const backgroundColor = Color(0xFF0F0F0F);
    const primaryColor = Color(0xFFF5C400);
    const surfaceInput = Color(0xFF141414);
    const borderSubtle = Color(0xFF2A2A2A);
    const textSecondary = Color(0xFFB5B5B5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Grid Pattern (Simplified)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(color: borderSubtle.withOpacity(0.3)),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isPendingApproval
              ? _buildPendingState(primaryColor, textSecondary)
              : Column(
                children: [
                   const Spacer(flex: 1),

                   // Header
                   Text(
                     'Enter $roleTitle ID',
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 28,
                       fontWeight: FontWeight.w600,
                       fontFamily: 'Inter',
                       letterSpacing: -0.5,
                     ),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Your unique $roleTitle ID for Guardrail access.',
                     style: const TextStyle(
                       color: textSecondary,
                       fontSize: 15,
                       fontFamily: 'Inter',
                     ),
                     textAlign: TextAlign.center,
                   ),

                   const SizedBox(height: 32),

                   // Input Field
                   Container(
                     decoration: BoxDecoration(
                       color: surfaceInput,
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: borderSubtle),
                     ),
                     child: TextField(
                       controller: _idController,
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 16,
                         fontFamily: 'Inter',
                       ),
                       textAlign: TextAlign.center,
                       decoration: InputDecoration(
                         hintText: '$roleTitle ID',
                         hintStyle: const TextStyle(color: textSecondary),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                       ),
                       cursorColor: primaryColor,
                     ),
                   ),

                   if (_errorMessage != null) ...[
                     const SizedBox(height: 8),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.error_outline, color: Colors.red, size: 16),
                         const SizedBox(width: 4),
                         Text(
                           _errorMessage!,
                           style: const TextStyle(color: Colors.red, fontSize: 14),
                         ),
                       ],
                     ),
                   ],

                   const Spacer(flex: 2),

                   // Button
                   SizedBox(
                     width: double.infinity,
                     height: 52,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : _handleVerification,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: primaryColor,
                         foregroundColor: Colors.black,
                         elevation: 0,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                         disabledBackgroundColor: primaryColor.withOpacity(0.5),
                       ),
                       child: _isLoading
                         ? const SizedBox(
                             width: 24,
                             height: 24,
                             child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                           )
                         : const Text(
                             'Verify ID',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w500,
                               fontFamily: 'Inter',
                             ),
                           ),
                     ),
                   ),
                   const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState(Color primaryColor, Color textSecondary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hourglass_empty, size: 64, color: primaryColor),
        const SizedBox(height: 24),
        const Text(
          'Verification Pending',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your ID has been submitted and is waiting for Admin approval. You will be able to access the dashboard once approved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () {
            // Check status again
            _handleVerification();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryColor),
            foregroundColor: primaryColor,
          ),
          child: const Text('Check Status'),
        )
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add a radial fade
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final fadePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
           Colors.transparent,
           const Color(0xFF0F0F0F).withOpacity(0.8),
           const Color(0xFF0F0F0F)
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, fadePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
