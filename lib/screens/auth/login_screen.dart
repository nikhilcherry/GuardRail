import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/logger_service.dart';
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
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final l10n = AppLocalizations.of(context)!;
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
    } catch (e, stack) {
      LoggerService().error('Login failed', e, stack);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginFailed),
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
    final l10n = AppLocalizations.of(context)!;

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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            l10n.login,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.enterCredentials,
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
                                Text(l10n.email, style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 254, // SECURITY: RFC 5321 limit
                                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: Validators.validateEmail,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    hintText: l10n.emailHint,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.password, style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  maxLength: 128, // SECURITY: Prevent large input DoS
                                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                  onFieldSubmitted: (_) => _handleEmailLogin(),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: Validators.validatePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    hintText: l10n.enterPassword,
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
                                      l10n.login,
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
                              l10n.forgotPassword,
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
                              l10n.contactSupport,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.dontHaveAccount + ' ',
                                style: theme.textTheme.bodySmall,
                              ),
                              TextButton(
                                onPressed: () => context.push('/sign_up'),
                                child: Text(
                                  l10n.signUp,
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