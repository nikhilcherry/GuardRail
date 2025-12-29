import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:ui'; // Required for ImageFilter
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final bool isSignUp;

  const LoginScreen({
    Key? key,
    required this.role,
    this.isSignUp = false,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _flatController;

  bool _showOTPInput = false;
  bool _useEmail = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _flatController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  String get _roleDisplay => widget.role.replaceFirst(widget.role[0], widget.role[0].toUpperCase());

  Future<void> _handlePhoneAction() async {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    // Simulate OTP sent
    setState(() => _showOTPInput = true);
  }

  Future<void> _handleOTPVerification() async {
    if (_otpController.text.length != 6) {
      _showError('Please enter a valid OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // In a real app, verify OTP and potentially create account if isSignUp
      await context.read<AuthProvider>().loginWithPhoneAndOTP(
            phone: _phoneController.text,
            otp: _otpController.text,
            role: widget.role, // Pass role to provider
          );
      if (mounted) {
        // Navigate based on role (Handled by RootScreen or explicit nav)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      _showError('Verification failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAction() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (widget.isSignUp && (_nameController.text.isEmpty || (widget.role == 'resident' && _flatController.text.isEmpty))) {
       _showError('Please fill in all fields');
       return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().loginWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
            role: widget.role,
          );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      _showError('Action failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      // Stack for the ambient background effect
      body: Stack(
        children: [
          // Ambient Background with Blur
          Positioned(
            top: -50,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  maxWidth: 400, // max-w-[400px]
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderDark),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getRoleIcon(),
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$_roleDisplay ${widget.isSignUp ? 'Sign Up' : 'Login'}',
                        style: AppTheme.displayMedium.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form
                      if (!_useEmail) ...[
                        // Phone Flow
                        _buildLabel('Phone Number'),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _phoneController,
                          hint: '(555) 000-0000',
                          icon: Icons.call,
                          inputType: TextInputType.phone,
                          enabled: !_showOTPInput,
                        ),
                        const SizedBox(height: 20),

                        if (_showOTPInput) ...[
                           _buildLabel('One-Time Password'),
                           const SizedBox(height: 8),
                           _buildInput(
                             controller: _otpController,
                             hint: '• • • • • •',
                             icon: Icons.password,
                             inputType: TextInputType.number,
                             isOTP: true,
                           ),
                           Align(
                             alignment: Alignment.centerRight,
                             child: TextButton(
                               onPressed: () {
                                 // Resend logic
                               },
                               child: Text(
                                 'Resend Code',
                                 style: AppTheme.labelSmall.copyWith(color: AppTheme.primary),
                               ),
                             ),
                           ),
                        ],
                      ] else ...[
                        // Email Flow
                         if (widget.isSignUp) ...[
                            _buildLabel('Full Name'),
                            const SizedBox(height: 8),
                            _buildInput(
                              controller: _nameController,
                              hint: 'John Doe',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                         ],

                         if (widget.isSignUp && widget.role == 'resident') ...[
                            _buildLabel('Flat Number'),
                            const SizedBox(height: 8),
                            _buildInput(
                              controller: _flatController,
                              hint: 'e.g. 402',
                              icon: Icons.apartment,
                            ),
                            const SizedBox(height: 16),
                         ],

                        _buildLabel('Email'),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _emailController,
                          hint: 'your@email.com',
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildInput(
                          controller: _passwordController,
                          hint: 'Enter password',
                          icon: Icons.lock_outlined,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_useEmail
                                  ? _handleEmailAction
                                  : (_showOTPInput ? _handleOTPVerification : _handlePhoneAction)),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.isSignUp
                                        ? 'Sign Up'
                                        : (_showOTPInput ? 'Verify' : 'Log In'),
                                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, color: Colors.black),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _useEmail = !_useEmail;
                            _showOTPInput = false;
                            // Clear controllers if needed
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              _useEmail ? 'Use phone instead' : 'Use email instead',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Container(height: 1, width: 100, color: AppTheme.primary), // Underline effect
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help_outline, size: 18, color: Color(0xFF555555)),
                          const SizedBox(width: 8),
                          Text(
                            'Trouble logging in?',
                            style: AppTheme.bodyMedium.copyWith(color: Color(0xFF555555)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Back to Role Selection
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Change Role',
                          style: AppTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case 'resident': return Icons.home_outlined;
      case 'guard': return Icons.security_outlined;
      case 'admin': return Icons.admin_panel_settings_outlined;
      default: return Icons.security_outlined;
    }
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
    bool isOTP = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      enabled: enabled,
      style: AppTheme.bodyLarge,
      cursorColor: AppTheme.primary,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF555555)),
        hintText: hint,
        hintStyle: TextStyle(letterSpacing: isOTP ? 4.0 : 0),
      ),
    );
  }
}
