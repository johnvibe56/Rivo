import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/auth/utils/validators.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

// Form field key
const _kEmailFieldKey = Key('email');

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isResettingPassword = false;
  bool _isEmailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _getErrorMessage(String error) {
    if (error.contains('user not found')) {
      return AppLocalizations.of(context)!.noAccountFoundWithEmail;
    } else if (error.contains('network-request-failed')) {
      return AppLocalizations.of(context)!.networkError;
    } else {
      return error.replaceAll('Exception: ', '');
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isResettingPassword = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider);
      await authController.resetPassword(email: _emailController.text.trim());

      if (mounted) {
        setState(() {
          _isEmailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resetPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.lock_reset_outlined,
                  size: 72,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.forgotYourPassword,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _isEmailSent
                      ? AppLocalizations.of(context)!.resetPasswordInstructions
                      : AppLocalizations.of(context)!.enterYourEmailToResetPassword,
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (!_isEmailSent) ...[
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Email field
                  TextFormField(
                    key: _kEmailFieldKey,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.enterYourEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 24),

                  // Reset password button
                  AppButton.primary(
                    onPressed: _isResettingPassword ? null : _resetPassword,
                    label: AppLocalizations.of(context)!.sendResetLink,
                    isLoading: _isResettingPassword,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Success message with icon
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.checkYourEmail,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.resetPasswordEmailSent,
                    style: textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],

                // Back to login button - always visible and clickable
                AppButton.secondary(
                  onPressed: _isResettingPassword ? null : () {
                    // Use GoRouter's go to navigate to login and remove forgot password from stack
                    GoRouter.of(context).go('/login');
                  },
                  label: AppLocalizations.of(context)!.backToLogin,
                  fullWidth: true,
                  isLoading: _isResettingPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
