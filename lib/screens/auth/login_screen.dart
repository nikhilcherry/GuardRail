import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late PageController _pageController;
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _showOTPInput = false;
  bool _useEmail = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _showOTPInput = true);
  }

  Future<void> _handleOTPVerification() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().loginWithPhoneAndOTP(
            phone: _phoneController.text,
            otp: _otpController.text,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().loginWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    try {
      await context.read<AuthProvider>().resendOTP(_phoneController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: const Icon(
                        Icons.security_outlined,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Headline
                    Text(
                      'Guard Login',
                      style: AppTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Phone or Email Input
                    if (!_useEmail) ...[
                      // Phone Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone Number', style: AppTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !_showOTPInput,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.call),
                              hintText: '(555) 000-0000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.borderDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: AppTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // OTP Input
                      if (_showOTPInput) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('One-Time Password', style: AppTheme.labelLarge),
                                TextButton(
                                  onPressed: _resendOTP,
                                  child: Text(
                                    'Resend Code',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              onChanged: (value) {},
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(8),
                                fieldHeight: 50,
                                fieldWidth: 45,
                                activeFillColor: AppTheme.surfaceDark,
                                inactiveFillColor: AppTheme.surfaceDark,
                                selectedFillColor: AppTheme.surfaceDark,
                                activeColor: AppTheme.primary,
                                inactiveColor: AppTheme.borderDark,
                                selectedColor: AppTheme.primary,
                              ),
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              enableActiveFill: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ] else ...[
                      // Email Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email', style: AppTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'your@email.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: AppTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: AppTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outlined),
                              hintText: 'Enter password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: AppTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_useEmail
                                ? (_showOTPInput ? _handleOTPVerification : _handlePhoneLogin)
                                : (_showOTPInput
                                    ? _handleOTPVerification
                                    : _handlePhoneLogin)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showOTPInput ? 'Verify' : 'Log In',
                                    style: AppTheme.titleLarge.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Use Email/Phone Toggle
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _useEmail = !_useEmail;
                              _showOTPInput = false;
                              _phoneController.clear();
                              _otpController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                _useEmail ? 'Use phone instead' : 'Use email instead',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline),
                          label: Text(
                            'Trouble logging in?',
                            style: AppTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
