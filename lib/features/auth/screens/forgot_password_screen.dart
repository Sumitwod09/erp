import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(_emailController.text.trim());

      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.neutralGrey,
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(AppConstants.spaceXl),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _emailSent ? _buildSuccessView() : _buildFormView(authState),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and Title
          const Icon(
            Icons.lock_reset_rounded,
            size: 48,
            color: AppColors.actionBlue,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          const Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXxl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          const Text(
            'Enter your email to receive a password reset link',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.fontSizeBase,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // Reset Button
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleResetPassword,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceSm),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),

          const SizedBox(height: AppConstants.spaceMd),

          // Back to Login Link
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 64,
          color: AppColors.success,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXl,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        const Text(
          'Check your email for a password reset link',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppConstants.fontSizeBase,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXl),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Padding(
            padding: EdgeInsets.all(AppConstants.spaceSm),
            child: Text('Back to Login'),
          ),
        ),
      ],
    );
  }
}
