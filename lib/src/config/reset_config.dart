// File: src/config/reset_config.dart
import 'package:flutter/material.dart';

/// Configuration for password reset page
class ResetConfig {
  /// Title for reset page
  final String title;

  /// Subtitle for reset page
  final String? subtitle;

  /// Reset button text
  final String resetButtonText;

  /// Reset button style
  final ButtonStyle? resetButtonStyle;

  /// Email field label
  final String emailFieldLabel;

  /// Email field hint
  final String emailFieldHint;

  /// Back to login text
  final String backToLoginText;

  /// Custom reset form widget builder
  final Widget Function(BuildContext)? formBuilder;

  /// Success message after reset
  final String resetSuccessMessage;

  /// Custom email validator
  final FormFieldValidator<String>? emailValidator;

  /// Custom text input decoration
  final InputDecoration? emailDecoration;

  const ResetConfig({
    this.title = 'Reset Password',
    this.subtitle =
        'Enter your email and we will send you instructions to reset your password',
    this.resetButtonText = 'Send Reset Link',
    this.resetButtonStyle,
    this.emailFieldLabel = 'Email',
    this.emailFieldHint = 'Enter your email',
    this.backToLoginText = 'Back to Login',
    this.formBuilder,
    this.resetSuccessMessage = 'Password reset instructions sent successfully',
    this.emailValidator,
    this.emailDecoration,
  });

  /// Creates a copy of this [ResetConfig] with optional field replacements
  ResetConfig copyWith({
    String? title,
    String? subtitle,
    String? resetButtonText,
    ButtonStyle? resetButtonStyle,
    String? emailFieldLabel,
    String? emailFieldHint,
    String? backToLoginText,
    Widget Function(BuildContext)? formBuilder,
    String? resetSuccessMessage,
    FormFieldValidator<String>? emailValidator,
    InputDecoration? emailDecoration,
  }) {
    return ResetConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      resetButtonText: resetButtonText ?? this.resetButtonText,
      resetButtonStyle: resetButtonStyle ?? this.resetButtonStyle,
      emailFieldLabel: emailFieldLabel ?? this.emailFieldLabel,
      emailFieldHint: emailFieldHint ?? this.emailFieldHint,
      backToLoginText: backToLoginText ?? this.backToLoginText,
      formBuilder: formBuilder ?? this.formBuilder,
      resetSuccessMessage: resetSuccessMessage ?? this.resetSuccessMessage,
      emailValidator: emailValidator ?? this.emailValidator,
      emailDecoration: emailDecoration ?? this.emailDecoration,
    );
  }
}
