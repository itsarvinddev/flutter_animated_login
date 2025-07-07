// File: src/config/signup_config.dart
import 'package:flutter/material.dart';

/// Configuration for signup page
class SignupConfig {
  /// Title for signup page
  final String title;

  /// Subtitle for signup page
  final String? subtitle;

  /// Signup button text
  final String signupButtonText;

  /// Signup button style
  final ButtonStyle? signupButtonStyle;

  /// Email field label
  final String emailFieldLabel;

  /// Email field hint
  final String emailFieldHint;

  /// Password field label
  final String passwordFieldLabel;

  /// Password field hint
  final String passwordFieldHint;

  /// Confirm password field label
  final String confirmPasswordFieldLabel;

  /// Confirm password field hint
  final String confirmPasswordFieldHint;

  /// Already have account text
  final String haveAccountText;

  /// Sign in text button
  final String signInText;

  /// Custom signup form widget builder
  final Widget Function(BuildContext)? formBuilder;

  /// Custom signup validators
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? passwordValidator;
  final FormFieldValidator<String>? confirmPasswordValidator;

  /// Custom text input decorations
  final InputDecoration? emailDecoration;
  final InputDecoration? passwordDecoration;
  final InputDecoration? confirmPasswordDecoration;

  /// Additional signup fields
  final List<Widget> Function(BuildContext)? additionalFields;

  /// Field to automatically login after signup
  final bool loginAfterSignUp;

  const SignupConfig({
    this.title = 'Create Account',
    this.subtitle,
    this.signupButtonText = 'Sign Up',
    this.signupButtonStyle,
    this.emailFieldLabel = 'Email',
    this.emailFieldHint = 'Enter your email',
    this.passwordFieldLabel = 'Password',
    this.passwordFieldHint = 'Create a password',
    this.confirmPasswordFieldLabel = 'Confirm Password',
    this.confirmPasswordFieldHint = 'Confirm your password',
    this.haveAccountText = 'Already have an account?',
    this.signInText = 'Sign In',
    this.formBuilder,
    this.emailValidator,
    this.passwordValidator,
    this.confirmPasswordValidator,
    this.emailDecoration,
    this.passwordDecoration,
    this.confirmPasswordDecoration,
    this.additionalFields,
    this.loginAfterSignUp = false,
  });

  /// Creates a copy of this [SignupConfig] with optional field replacements
  SignupConfig copyWith({
    String? title,
    String? subtitle,
    String? signupButtonText,
    ButtonStyle? signupButtonStyle,
    String? emailFieldLabel,
    String? emailFieldHint,
    String? passwordFieldLabel,
    String? passwordFieldHint,
    String? confirmPasswordFieldLabel,
    String? confirmPasswordFieldHint,
    String? haveAccountText,
    String? signInText,
    Widget Function(BuildContext)? formBuilder,
    FormFieldValidator<String>? emailValidator,
    FormFieldValidator<String>? passwordValidator,
    FormFieldValidator<String>? confirmPasswordValidator,
    InputDecoration? emailDecoration,
    InputDecoration? passwordDecoration,
    InputDecoration? confirmPasswordDecoration,
    List<Widget> Function(BuildContext)? additionalFields,
    bool? loginAfterSignUp,
  }) {
    return SignupConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      signupButtonText: signupButtonText ?? this.signupButtonText,
      signupButtonStyle: signupButtonStyle ?? this.signupButtonStyle,
      emailFieldLabel: emailFieldLabel ?? this.emailFieldLabel,
      emailFieldHint: emailFieldHint ?? this.emailFieldHint,
      passwordFieldLabel: passwordFieldLabel ?? this.passwordFieldLabel,
      passwordFieldHint: passwordFieldHint ?? this.passwordFieldHint,
      confirmPasswordFieldLabel:
          confirmPasswordFieldLabel ?? this.confirmPasswordFieldLabel,
      confirmPasswordFieldHint:
          confirmPasswordFieldHint ?? this.confirmPasswordFieldHint,
      haveAccountText: haveAccountText ?? this.haveAccountText,
      signInText: signInText ?? this.signInText,
      formBuilder: formBuilder ?? this.formBuilder,
      emailValidator: emailValidator ?? this.emailValidator,
      passwordValidator: passwordValidator ?? this.passwordValidator,
      confirmPasswordValidator:
          confirmPasswordValidator ?? this.confirmPasswordValidator,
      emailDecoration: emailDecoration ?? this.emailDecoration,
      passwordDecoration: passwordDecoration ?? this.passwordDecoration,
      confirmPasswordDecoration:
          confirmPasswordDecoration ?? this.confirmPasswordDecoration,
      additionalFields: additionalFields ?? this.additionalFields,
      loginAfterSignUp: loginAfterSignUp ?? this.loginAfterSignUp,
    );
  }
}
