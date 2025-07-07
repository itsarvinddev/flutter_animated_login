// File: src/widgets/pages/verify_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../config/verify_config.dart';
import '../../controllers/form_controller.dart';
import '../../models/auth_data.dart';
import '../../models/auth_result.dart';
import '../../theme/auth_theme_extension.dart';
import '../../utils/validation.dart';
import '../common/auth_title.dart';
import '../common/messages.dart';
import '../fields/auth_button.dart';

/// The OTP verification page widget
class VerifyPage extends ConsumerStatefulWidget {
  /// Configuration for verify page
  final VerifyConfig config;

  /// Identifier (email or phone) to verify
  final String identifier;

  /// Callback when verification is submitted
  final Future<AuthResult> Function(VerifyData data)? onVerifySubmit;

  /// Callback when resend code is tapped
  final Future<AuthResult> Function()? onResendCode;

  /// Callback when back is tapped
  final VoidCallback onBackTap;

  const VerifyPage({
    super.key,
    required this.config,
    required this.identifier,
    required this.onVerifySubmit,
    required this.onResendCode,
    required this.onBackTap,
  });

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  late final FormController _formController;

  // Resend coolDown
  int _resendCoolDown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _formController = ref.read(verifyFormProvider);

    // Start resend timer
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCoolDown = widget.config.resendCoolDown;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCoolDown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {});
        }
        return;
      }

      if (mounted) {
        setState(() {
          _resendCoolDown--;
        });
      }
    });
  }

  Future<void> _handleVerify() async {
    if (!_formController.validateForm()) {
      return;
    }

    final code = _formController.otpController.text.trim();

    if (widget.onVerifySubmit == null) {
      setState(() {
        _errorMessage = 'Verification functionality not implemented';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await widget.onVerifySubmit!(
        VerifyData(
          identifier: widget.identifier,
          code: code,
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.success) {
            _successMessage = widget.config.verifySuccessMessage;
            _errorMessage = null;
          } else {
            _errorMessage =
                result.errorMessage ?? widget.config.invalidOtpMessage;
            _successMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
          _successMessage = null;
        });
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendCoolDown > 0 || widget.onResendCode == null) {
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await widget.onResendCode!();

      if (mounted) {
        setState(() {
          _isResending = false;
          if (result.success) {
            _startResendTimer();
          } else {
            _errorMessage = result.errorMessage ?? 'Failed to resend code';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
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

    // Format the identifier for display (mask email or phone)
    final formattedIdentifier = _formatIdentifier(widget.identifier);

    final subtitle =
        widget.config.subtitle.replaceAll('{identifier}', formattedIdentifier);

    return Form(
      key: _formController.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and subtitle
          AuthTitle(
            title: widget.config.title,
            subtitle: subtitle,
          ),

          const SizedBox(height: 32),

          // Pin input
          Pinput(
            controller: _formController.otpController,
            length: widget.config.otpLength,
            validator: widget.config.otpValidator ??
                (value) => ValidationUtils.validateOtp(
                      value,
                      length: widget.config.otpLength,
                    ),
            onCompleted: (_) => _handleVerify(),
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
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

          // Success message if any
          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuthMessage(
                message: _successMessage!,
                type: MessageType.success,
              ),
            ),

          // Verify button
          AuthButton(
            onPressed: _handleVerify,
            isLoading: _isLoading,
            text: widget.config.verifyButtonText,
            style: widget.config.verifyButtonStyle,
          ),

          const SizedBox(height: 16),

          // Resend code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_resendCoolDown > 0)
                Text(
                  'Resend code in ${_formatTime(_resendCoolDown)}',
                  style: TextStyle(
                    color: authTheme.subtitleColor,
                    fontSize: 14,
                  ),
                )
              else
                TextButton(
                  onPressed: _isResending ? null : _handleResendCode,
                  style: TextButton.styleFrom(
                    foregroundColor: authTheme.linkColor,
                  ),
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.config.resendCodeText),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Back button
          TextButton(
            onPressed: widget.onBackTap,
            style: TextButton.styleFrom(
              foregroundColor: authTheme.subtitleColor,
            ),
            child: Text(widget.config.backText),
          ),
        ],
      ),
    );
  }

  // Helper to format time for countdown
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper to format/mask identifier
  String _formatIdentifier(String identifier) {
    if (_isEmail(identifier)) {
      // Mask email: j***@example.com
      final parts = identifier.split('@');
      if (parts.length == 2) {
        final name = parts[0];
        final domain = parts[1];

        final maskedName =
            name.length > 1 ? '${name[0]}${'*' * (name.length - 1)}' : name;

        return '$maskedName@$domain';
      }
    } else {
      // Mask phone: +1******7890
      if (identifier.length > 4) {
        final visibleStart = identifier.length > 6 ? 2 : 1;
        final visibleEnd = 4;

        final start = identifier.substring(0, visibleStart);
        final middle = '*' * (identifier.length - visibleStart - visibleEnd);
        final end = identifier.substring(identifier.length - visibleEnd);

        return '$start$middle$end';
      }
    }

    return identifier;
  }

  // Check if string is an email
  bool _isEmail(String value) {
    return value.contains('@');
  }
}
