import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).resetPassword(
          _emailController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);
    } else {
      final errorMsg =
          ref.read(authProvider).errorMessage ?? 'Reset password failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.04),
                Icon(
                  Icons.lock_reset_rounded,
                  size: AppSizes.xxl,
                  color: AppColors.primary,
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'Enter your email to receive a reset link',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                if (_isSuccess)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 48,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'Reset link sent!',
                          style: TextStyle(
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Please check your email for further instructions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.email_outlined),
                    onSubmitted: (_) => _onReset(),
                  ),
                  SizedBox(height: size.height * 0.02),
                  AppButton(
                    text: 'Send Reset Link',
                    isLoading: isLoading,
                    onPressed: _onReset,
                  ),
                ],
                SizedBox(height: size.height * 0.03),
                if (_isSuccess)
                  AppButton(
                    text: 'Back to Login',
                    onPressed: () => context.go(AppRouter.login),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRouter.login),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.fontSm,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
