import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // If true, we are in "Sign Up" mode (displaying "Sign Up as...")
  // If false, we are in "Login" mode (displaying "Continue as...")
  bool _isSignUpMode = false;

  void _onRoleSelected(String role) {
    if (_isSignUpMode) {
      // In a real app, this would go to a Registration Screen.
      // For now, we will navigate to the LoginScreen but with an flag or logic
      // to show it's a sign up context, or just let the user log in.
      // The prompt says "Sign up as Guard... The user simply taps one of these buttons to choose their role."
      // Let's navigate to the LoginScreen but handle it as a Sign Up entry point
      // or assume the LoginScreen has a "Sign Up" toggle.
      // Actually, let's pass a mode to LoginScreen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(role: role, isSignUp: true),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(role: role, isSignUp: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Column(
                    children: [
                      // Logo
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                           // Logo image placeholder logic if needed, using Icon for now as per previous code
                        ),
                        child: const Icon(
                          Icons.security_outlined, // Fallback for the shield logo image
                          size: 80,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24), // space-y-6
                      Text(
                        _isSignUpMode ? 'Sign up as' : 'Continue as',
                        style: AppTheme.displayMedium.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40), // space-y-10

                  // Role Cards
                  Column(
                    children: [
                      _RoleCard(
                        icon: Icons.home_outlined,
                        title: 'Resident',
                        description: 'Access your home and manage guests',
                        onTap: () => _onRoleSelected('resident'),
                      ),
                      const SizedBox(height: 16), // space-y-4
                      _RoleCard(
                        icon: Icons.security_outlined,
                        title: 'Guard',
                        description: 'Monitor entries and verify visitors',
                        onTap: () => _onRoleSelected('guard'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin',
                        description: 'System configuration and logs',
                        onTap: () => _onRoleSelected('admin'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Bottom Link
                  if (!_isSignUpMode)
                    Column(
                      children: [
                         TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUpMode = true;
                            });
                          },
                          child: Text(
                            "New here? Create an account",
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          'Need help with your account?',
                          style: AppTheme.bodySmall.copyWith(color: Color(0xFF525252)),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Contact Support',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUpMode = false;
                        });
                      },
                      child: Text(
                        "Already have an account? Log In",
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovered ? Matrix4.identity().scaled(1.02) : Matrix4.identity(),
          padding: const EdgeInsets.all(20), // p-5
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border.all(
              color: _isHovered ? AppTheme.primary.withOpacity(0.5) : AppTheme.borderDark,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(999), // rounded-full
                ),
                child: Icon(
                  widget.icon,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.description,
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              // Arrow (visible on hover/active in CSS, we'll just show it always or animate opacity)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
