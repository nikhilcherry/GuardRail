import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/contact_support_dialog.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Navigation handled by AppRouter listening to AuthProvider
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => context.pop(),
          ),
        ),
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
                      const SizedBox(height: 20),

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

                      // Title
                      Column(
                        children: [
                          Text(
                            'Login',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your credentials to continue',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email', style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: Validators.validateEmail,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined),
                                    hintText: 'your@email.com',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Password', style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  // We apply the same strict password policy here as per request ("All form screens")
                                  validator: Validators.validatePassword,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outlined),
                                    hintText: 'Enter password',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Log In',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Links
                      Column(
                        children: [
                          TextButton.icon(
                            onPressed: () => context.push('/forgot_password'),
                            icon: Icon(
                              Icons.help_outline,
                              color: theme.iconTheme.color,
                            ),
                            label: Text(
                              'Forgot Password?',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => showContactSupportDialog(context),
                            icon: Icon(
                              Icons.support_agent,
                              color: theme.iconTheme.color,
                            ),
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
                                onPressed: () => context.push('/sign_up'),
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
    );
  }
}
