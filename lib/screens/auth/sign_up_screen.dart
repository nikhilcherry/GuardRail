import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../services/logger_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController(); // Only storing email now
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final _nameFocusNode = FocusNode();
  final _contactFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _residenceIdFocusNode = FocusNode();

  // New: Role Selection
  String? _selectedRole;
  final _residenceIdController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _residenceIdController.dispose();
    _nameFocusNode.dispose();
    _contactFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _residenceIdFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pleaseSelectRole)),
         );
         return;
      }

      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await authProvider.register(
          name: _nameController.text,
          email: _contactController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          role: _selectedRole!,
          residenceId: _residenceIdController.text.isNotEmpty ? _residenceIdController.text : null,
        );
        // AppRouter handles redirection
      } catch (e, stack) {
        LoggerService().error('Registration failed', e, stack);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.registrationFailed)),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createAccount,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signUpToGetStarted,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                Text(l10n.fullName, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  maxLength: 100, // SECURITY: Prevent large input DoS
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_contactFocusNode),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: l10n.nameHint,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                // Email
                Text(l10n.emailAddress, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  focusNode: _contactFocusNode,
                  textInputAction: TextInputAction.next,
                  maxLength: 254, // SECURITY: RFC 5321 limit
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.emailHint,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Phone
                Text(l10n.phoneNumber, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  textInputAction: TextInputAction.next,
                  maxLength: 20, // SECURITY: Prevent large input DoS (allow for formatting)
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: l10n.phoneHint,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),

                // Date of Birth
                Text(l10n.dateOfBirth, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? l10n.selectDate
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Text(l10n.password, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.next,
                  maxLength: 128, // SECURITY: Prevent large input DoS
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.createPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                Text(l10n.confirmPassword, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  textInputAction: _selectedRole == 'resident' ? TextInputAction.next : TextInputAction.done,
                  maxLength: 128, // SECURITY: Prevent large input DoS
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onFieldSubmitted: (_) {
                    if (_selectedRole == 'resident') {
                      FocusScope.of(context).requestFocus(_residenceIdFocusNode);
                    } else {
                      _handleSignUp();
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.confirmYourPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Role Selection
                Text(l10n.continueAs, style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                Row(
                   children: [
                     _buildRoleCard('resident', l10n.resident, Icons.home_outlined, theme),
                     const SizedBox(width: 12),
                     _buildRoleCard('guard', l10n.guard, Icons.security_outlined, theme),
                   ],
                ),
                const SizedBox(height: 12),
                Row(
                   children: [
                     _buildRoleCard('admin', l10n.admin, Icons.admin_panel_settings_outlined, theme),
                   ],
                ),

                // Residence ID (Optional)
                if (_selectedRole == 'resident') ...[
                  const SizedBox(height: 24),
                  Text(l10n.residenceIdOptional, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _residenceIdController,
                    focusNode: _residenceIdFocusNode,
                    textInputAction: TextInputAction.done,
                    maxLength: 50, // SECURITY: Prevent large input DoS
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    onFieldSubmitted: (_) => _handleSignUp(),
                    decoration: InputDecoration(
                      hintText: l10n.enterResidenceIdToJoin,
                      prefixIcon: const Icon(Icons.apartment),
                      helperText: l10n.leaveEmptyToCreateFlat,
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],

                const SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
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
                          child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2)
                        )
                      : Text(
                        l10n.signUp,
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String label, IconData icon, ThemeData theme) {
     final isSelected = _selectedRole == role;
     return Expanded(
       child: GestureDetector(
         onTap: () => setState(() => _selectedRole = role),
         child: Container(
           padding: const EdgeInsets.symmetric(vertical: 16),
           decoration: BoxDecoration(
             color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(
               color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
               width: 2,
             ),
           ),
           child: Column(
             children: [
               Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color),
               const SizedBox(height: 8),
               Text(
                 label,
                 style: theme.textTheme.labelLarge?.copyWith(
                   color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                 )
               ),
             ],
           ),
         ),
       ),
     );
  }
}