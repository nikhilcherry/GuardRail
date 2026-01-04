import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready and to avoid blocking build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.unlockApp();
    } catch (e) {
      // Handle error if needed
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'GuardRail Locked',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Please authenticate to continue',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
