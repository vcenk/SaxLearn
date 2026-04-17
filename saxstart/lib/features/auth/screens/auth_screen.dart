import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                _isSignUp ? 'Create Account' : 'Welcome Back',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isSignUp
                    ? 'Sign up to save your progress across devices'
                    : 'Sign in to continue your journey',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 32),

              // Email field
              Text('EMAIL', style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration('Enter your email'),
              ),
              const SizedBox(height: 20),

              // Password field
              Text('PASSWORD', style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  _isSignUp ? 'Create a password' : 'Enter your password',
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              GoldButton(
                label: _isSignUp ? 'Sign Up' : 'Sign In',
                isLoading: _isLoading,
                onPressed: () async {
                  // TODO: Firebase auth integration
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (!context.mounted) return;
                  setState(() => _isLoading = false);
                  context.go('/home');
                },
              ),
              const SizedBox(height: 16),

              // Toggle sign up / sign in
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : "Don't have an account? Sign Up",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: AppColors.borderSubtle),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: AppTypography.bodySmall),
                  ),
                  const Expanded(
                    child: Divider(color: AppColors.borderSubtle),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social sign-in buttons
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Continue with Google',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.apple_rounded,
                label: 'Continue with Apple',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 24),

              // Skip
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip for now',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium
          .copyWith(color: AppColors.textDisabled),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGold),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGold),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGold),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
