// File: src/widgets/pages/reset_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/reset_config.dart';
import '../../controllers/form_controller.dart';
import '../../models/auth_result.dart';
import '../../theme/auth_theme_extension.dart';
import '../../utils/validation.dart';
import '../common/auth_title.dart';
import '../common/messages.dart';
import '../fields/auth_button.dart';
import '../fields/email_field.dart';

/// The password reset page widget
class ResetPage extends ConsumerStatefulWidget {
  /// Configuration for reset page
  final ResetConfig config;

  /// Callback when login is tapped
  final VoidCallback onLoginTap;

  /// Callback when reset is submitted
  final Future<AuthResult> Function(String email)? onResetSubmit;

  const ResetPage({
    super.key,
    required this.config,
    required this.onLoginTap,
    required this.onResetSubmit,
  });

  @override
  ConsumerState<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends ConsumerState<ResetPage> {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  late final FormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = ref.read(resetFormProvider);
  }

  Future<void> _handleReset() async {
    if (!_formController.validateForm()) {
      return;
    }

    final email = _formController.emailController.text.trim();

    if (widget.onResetSubmit == null) {
      setState(() {
        _errorMessage = 'Reset functionality not implemented';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    try {
      final result = await widget.onResetSubmit!(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = result.success;
          _errorMessage = result.success ? null : result.errorMessage;
        });

        if (result.success) {
          _formController.resetFields();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleReset(),
          ),

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

          // Success message if operation succeeded
          if (_isSuccess)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuthMessage(
                message: widget.config.resetSuccessMessage,
                type: MessageType.success,
              ),
            ),

          // Reset button
          AuthButton(
            onPressed: _handleReset,
            isLoading: _isLoading,
            text: widget.config.resetButtonText,
            style: widget.config.resetButtonStyle,
          ),

          const SizedBox(height: 16),

          // Back to login button
          TextButton(
            onPressed: widget.onLoginTap,
            style: TextButton.styleFrom(
              foregroundColor: authTheme.linkColor,
            ),
            child: Text(widget.config.backToLoginText),
          ),
        ],
      ),
    );
  }
}
