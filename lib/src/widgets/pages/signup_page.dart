// File: src/widgets/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/signup_config.dart';
import '../../controllers/form_controller.dart';
import '../../models/auth_data.dart';
import '../../models/auth_result.dart';
import '../../theme/auth_theme_extension.dart';
import '../../utils/validation.dart';
import '../common/auth_title.dart';
import '../common/messages.dart';
import '../fields/auth_button.dart';
import '../fields/email_field.dart';
import '../fields/password_field.dart';

/// The signup page widget
class SignupPage extends ConsumerStatefulWidget {
  /// Configuration for signup page
  final SignupConfig config;

  /// Callback when login is tapped
  final VoidCallback onLoginTap;

  /// Callback when signup is submitted
  final Future<AuthResult> Function(SignupData data)? onSignupSubmit;

  const SignupPage({
    super.key,
    required this.config,
    required this.onLoginTap,
    required this.onSignupSubmit,
  });

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isLoading = false;
  String? _errorMessage;
  late final FormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = ref.read(signupFormProvider);
  }

  Future<void> _handleSignup() async {
    if (!_formController.validateForm()) {
      return;
    }

    // Create signup data
    final signupData = SignupData(
      identifier: _formController.emailController.text.trim(),
      password: _formController.passwordController.text,
      confirmPassword: _formController.confirmPasswordController.text,
    );

    if (widget.onSignupSubmit == null) {
      setState(() {
        _errorMessage = 'Signup functionality not implemented';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onSignupSubmit!(signupData);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = result.success ? null : result.errorMessage;
        });

        // Show success message if needed
        if (result.success) {
          _formController.resetFields();

          // Auto login if configured
          if (widget.config.loginAfterSignUp) {
            widget.onLoginTap();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    return Form(
      key: _formController.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and subtitle
          AuthTitle(
            title: widget.config.title,
            subtitle: widget.config.subtitle,
          ),

          const SizedBox(height: 32),

          // Email field
          EmailField(
            controller: _formController.emailController,
            label: widget.config.emailFieldLabel,
            hint: widget.config.emailFieldHint,
            validator:
                widget.config.emailValidator ?? ValidationUtils.validateEmail,
            decoration: widget.config.emailDecoration,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Password field
          PasswordField(
            controller: _formController.passwordController,
            obscureText: _formController.obscurePassword,
            label: widget.config.passwordFieldLabel,
            hint: widget.config.passwordFieldHint,
            validator: widget.config.passwordValidator ??
                ValidationUtils.validatePassword,
            decoration: widget.config.passwordDecoration,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Confirm password field
          PasswordField(
            controller: _formController.confirmPasswordController,
            obscureText: _formController.obscureConfirmPassword,
            label: widget.config.confirmPasswordFieldLabel,
            hint: widget.config.confirmPasswordFieldHint,
            validator: widget.config.confirmPasswordValidator ??
                (value) => _formController.validateConfirmPassword(value),
            decoration: widget.config.confirmPasswordDecoration,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSignup(),
          ),

          // Additional signup fields if provided
          if (widget.config.additionalFields != null) ...[
            const SizedBox(height: 16),
            ...widget.config.additionalFields!(context),
          ],

          const SizedBox(height: 24),

          // Error message if any
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuthMessage(
                message: _errorMessage!,
                type: MessageType.error,
              ),
            ),

          // Signup button
          AuthButton(
            onPressed: _handleSignup,
            isLoading: _isLoading,
            text: widget.config.signupButtonText,
            style: widget.config.signupButtonStyle,
          ),

          const SizedBox(height: 16),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.config.haveAccountText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: widget.onLoginTap,
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: authTheme.linkColor,
                ),
                child: Text(widget.config.signInText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
