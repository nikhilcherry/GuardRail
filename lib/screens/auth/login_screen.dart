import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/contact_support_dialog.dart';

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
      // SECURITY: Prevents leaking internal error details to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your OTP and try again.')),
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
      // SECURITY: Prevents leaking internal error details to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend OTP. Please try again later.')),
      );
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final selectedRole = authProvider.selectedRole;
    final roleTitle = selectedRole != null ? _capitalize(selectedRole) : 'User';

    return WillPopScope(
      onWillPop: () async {
        context.read<AuthProvider>().selectRole(null);
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        Icons.security_outlined,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Headline
                    Text(
                      '$roleTitle Login',
                      style: theme.textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().selectRole(null);
                      },
                      child: Text(
                        'Change Role',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Phone or Email Input
                    if (!_useEmail) ...[
                      // Phone Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone Number', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !_showOTPInput,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.call),
                              hintText: '(555) 000-0000',
                            ),
                            style: theme.textTheme.bodyLarge,
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
                                Text(
                                  'One-Time Password',
                                  style: theme.textTheme.labelLarge,
                                ),
                                TextButton(
                                  onPressed: _resendOTP,
                                  child: Text(
                                    'Resend Code',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
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
                                activeFillColor: theme.cardColor,
                                inactiveFillColor: theme.cardColor,
                                selectedFillColor: theme.cardColor,
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: theme.dividerColor,
                                selectedColor: theme.colorScheme.primary,
                              ),
                              textStyle: theme.textTheme.titleLarge,
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
                          Text('Email', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'your@email.com',
                            ),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outlined),
                              hintText: 'Enter password',
                            ),
                            style: theme.textTheme.bodyLarge,
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
                                ? _handleEmailLogin
                                : (_showOTPInput
                                    ? _handleOTPVerification
                                    : _handlePhoneLogin)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
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
                                    style: theme.textTheme.titleLarge?.copyWith(
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
                          child: Text(
                            _useEmail ? 'Use phone instead' : 'Use email instead',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          icon: Icon(Icons.help_outline, color: theme.iconTheme.color),
                          label: Text(
                            'Forgot Password?',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => showContactSupportDialog(context),
                          icon: Icon(Icons.support_agent, color: theme.iconTheme.color),
                          label: Text(
                            'Contact Support',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/sign_up');
                              },
                              child: Text(
                                'Sign Up',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }
}
