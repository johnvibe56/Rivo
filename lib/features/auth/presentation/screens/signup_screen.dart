import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'dart:async';

import 'package:rivo/features/auth/utils/validators.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

// Form field keys
const _kNameFieldKey = Key('name');
const _kUsernameFieldKey = Key('username');
const _kEmailFieldKey = Key('email');
const _kPasswordFieldKey = Key('password');
const _kConfirmPasswordFieldKey = Key('confirmPassword');

// Validation patterns
final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Debounce for username availability check
  Timer? _usernameDebounce;

  bool _isCreatingAccount = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name is too short';
    }
    return null;
  }
  
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please choose a username';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    
    if (!_usernameRegex.hasMatch(value)) {
      return 'Only letters, numbers, and underscores are allowed';
    }
    
    return null;
  }
  

  
  // Debounced username validation
  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // Only validate if the form is dirty
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.validate();
      }
    });
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String _getErrorMessage(String error) {
    if (error.contains('already registered') || 
        error.contains('already in use') ||
        error.contains('user already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (error.contains('network-request-failed') ||
               error.contains('Failed host lookup')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.contains('weak-password') || 
               error.contains('password should be at least')) {
      return 'Please choose a stronger password with at least 6 characters.';
    } else if (error.contains('invalid email') || 
               error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('was canceled')) {
      return 'Sign up was canceled. Please try again.';
    } else if (error.contains('Failed to sign in with Google')) {
      return 'Failed to sign up with Google. Please try again.';
    } else {
      // Clean up the error message for display
      return error
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', '');
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isCreatingAccount = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim();
      
      // Double-check username availability as a final check
      try {
        final isAvailable = await ref.read(userProfileRepositoryProvider).isUsernameAvailable(username);
        if (!mounted) return;
        
        if (!isAvailable) {
          setState(() => _errorMessage = 'This username is already taken');
          return;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _errorMessage = 'Error checking username availability');
        return;
      }

      // Sign up the user
      await ref.read(authControllerProvider).signUpWithEmail(
            email: email,
            password: password,
            username: username,
            fullName: name,
          );

      if (mounted) {
        // Clear form fields
        _nameController.clear();
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please check your email to verify your account.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 5),
            ),
          );

          // Navigate to login screen after successful signup
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingAccount = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider).signInWithGoogle();
      
      if (mounted) {
        // Navigate to feed on successful Google sign in
        if (context.mounted) {
          context.go('/feed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and welcome text
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.createAnAccount,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.fillInYourDetails,
                      style: textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

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

                // Name field
                TextFormField(
                  key: _kNameFieldKey,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fullName,
                    hintText: AppLocalizations.of(context)!.enterYourFullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  key: _kUsernameFieldKey,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.username,
                    hintText: AppLocalizations.of(context)!.chooseAUsername,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _usernameController,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            // Store context and localizations before async gap
                            final currentContext = context;
                            final availableText = AppLocalizations.of(currentContext)!.usernameAvailable;
                            final takenText = AppLocalizations.of(currentContext)!.usernameTaken;
                            final errorText = AppLocalizations.of(currentContext)!.errorCheckingUsername;
                            
                            try {
                              final isAvailable = await ref.read(userProfileRepositoryProvider).isUsernameAvailable(value.text);
                              if (!mounted) return;
                              
                              if (scaffoldMessenger.mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isAvailable ? availableText : takenText,
                                    ),
                                    backgroundColor: isAvailable ? AppColors.success : AppColors.error,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              if (scaffoldMessenger.mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(errorText),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: _onUsernameChanged,
                  validator: _validateUsername,
                ),
                const SizedBox(height: 16),

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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: FormValidators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  key: _kPasswordFieldKey,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.createAStrongPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: FormValidators.validatePassword,
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  key: _kConfirmPasswordFieldKey,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.confirmPassword,
                    hintText: AppLocalizations.of(context)!.reEnterYourPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),

                // Sign up button
                AppButton.primary(
                  onPressed: _isCreatingAccount ? null : _submit,
                  label: AppLocalizations.of(context)!.createAccount,
                  isLoading: _isCreatingAccount,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google sign in button
                AppButton.secondary(
                  onPressed: (_isCreatingAccount || _isGoogleLoading) ? null : _signInWithGoogle,
                  label: AppLocalizations.of(context)!.continueWithGoogle,
                  icon: Icons.g_mobiledata,
                  fullWidth: true,
                  isLoading: _isGoogleLoading,
                  enableHapticFeedback: true,
                ),
                const SizedBox(height: 32),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.alreadyHaveAnAccount,
                      style: textTheme.bodyLarge,
                    ),
                    AppButton.text(
                      onPressed: (_isCreatingAccount || _isGoogleLoading)
                          ? null
                          : () => context.go('/login'),
                      label: AppLocalizations.of(context)!.signIn,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Terms and privacy notice
                Text.rich(
                  TextSpan(
                    text: '${AppLocalizations.of(context)!.byCreatingAnAccount} ',
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.termsOfService,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        // Add onTap handler for terms of service
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: AppLocalizations.of(context)!.and),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        // Add onTap handler for privacy policy
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
