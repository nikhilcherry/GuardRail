import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: AppTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Name
              Text('Full Name', style: AppTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Contact
              Text('Email or Phone', style: AppTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  hintText: 'Enter email or phone',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Password
              Text('Password', style: AppTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sign up not implemented yet')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: AppTheme.titleLarge.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
