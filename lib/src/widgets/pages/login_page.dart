import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/login_config.dart';
import '../../constants/enums.dart';
import '../../controllers/form_controller.dart';
import '../../models/auth_data.dart';
import '../../models/auth_result.dart';
import '../../theme/auth_theme_extension.dart';
import '../../utils/validation.dart';
import '../common/auth_title.dart';
import '../common/divider.dart';
import '../common/messages.dart';
import '../fields/adaptive_input_field.dart';
import '../fields/auth_button.dart';
import '../fields/password_field.dart';
import '../oauth/oauth_row.dart';

/// The login page widget
class LoginPage extends ConsumerStatefulWidget {
  /// Configuration for login page
  final LoginConfig config;

  /// Callback when signup is tapped
  final VoidCallback onSignupTap;

  /// Callback when forgot password is tapped
  final VoidCallback onForgotPasswordTap;

  /// Callback when login is submitted
  final Future<AuthResult> Function(LoginData data)? onLoginSubmit;

  /// Login type (password, OTP, or both)
  final LoginType loginType;

  const LoginPage({
    super.key,
    required this.config,
    required this.onSignupTap,
    required this.onForgotPasswordTap,
    required this.onLoginSubmit,
    required this.loginType,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;
  late final FormController _formController;

  // Used only for otpAndPassword mode to track which method the user selected
  final bool _usingOtp = false;

  @override
  void initState() {
    super.initState();
    _formController = ref.read(loginFormProvider);
  }

  @override
  void dispose() {
    // We don't dispose the form controller here as it's managed by the provider
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formController.validateForm()) {
      return;
    }

    // Create login data
    final loginData = LoginData(
      identifier: _formController.emailController.text.trim(),
      password: isOtpLogin ? "" : _formController.passwordController.text,
      rememberMe: _formController.rememberMe.value,
    );

    if (widget.onLoginSubmit == null) {
      setState(() {
        _errorMessage = 'Login functionality not implemented';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onLoginSubmit!(loginData);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = result.success ? null : result.errorMessage;
        });

        // Check if verification is required (for OTP flow)
        if (!result.success &&
            result.additionalData != null &&
            result.additionalData!['requiresVerification'] == true) {
          // OTP sent, redirect to verification page will be handled by controller
        } else if (result.success) {
          // Normal success path
          _formController.resetFields();
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

  // Helper properties to determine login type
  bool get isOtpLogin =>
      widget.loginType == LoginType.otp ||
      (widget.loginType == LoginType.otpAndPassword && _usingOtp);

  bool get isPasswordLogin =>
      widget.loginType == LoginType.password ||
      (widget.loginType == LoginType.otpAndPassword && !_usingOtp);

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
          AdaptiveInputField(
            controller: _formController.emailController,
            // label: widget.config.emailFieldLabel,
            // hint: widget.config.emailFieldHint,
            // validator:
            //     widget.config.emailValidator ?? ValidationUtils.validateEmail,
            decoration: widget.config.emailDecoration,
            // textInputAction:
            //     isOtpLogin ? TextInputAction.done : TextInputAction.next,
          ),

          // Show password field only if not OTP login
          if (isPasswordLogin) ...[
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
            ),
          ],

          const SizedBox(height: 8),

          // Show different buttons based on login type
          if (isPasswordLogin) ...[
            // Show remember me and forgot password options for password login
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.config.showRememberMe)
                  ValueListenableBuilder<bool>(
                    valueListenable: _formController.rememberMe,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: value,
                              onChanged: (v) =>
                                  _formController.rememberMe.value = v ?? false,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                _formController.rememberMe.value = !value,
                            child: Text(
                              widget.config.rememberMeText,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                TextButton(
                  onPressed: widget.onForgotPasswordTap,
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: authTheme.linkColor,
                  ),
                  child: Text(widget.config.forgotPasswordText),
                ),
              ],
            ),
          ] else ...[
            // For OTP login, just show a message about verification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will receive a verification code to continue',
                style: TextStyle(
                  color: authTheme.subtitleColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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

          // Login button
          AuthButton(
            onPressed: _handleLogin,
            isLoading: _isLoading,
            text: isOtpLogin
                ? 'Send Verification Code'
                : widget.config.loginButtonText,
            style: widget.config.loginButtonStyle,
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.config.noAccountText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: widget.onSignupTap,
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: authTheme.linkColor,
                ),
                child: Text(widget.config.signUpText),
              ),
            ],
          ),

          // OAuth providers
          AuthDivider(
            text: 'OR',
            color: authTheme.dividerColor,
          ),

          const SizedBox(height: 16),

          // OAuth buttons row
          OAuthButtonRow(isLoading: _isLoading),
        ],
      ),
    );
  }
}
