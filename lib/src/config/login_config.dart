// File: src/config/login_config.dart
import 'package:flutter/material.dart';

/// Configuration for login page
class LoginConfig {
  /// Title for login page
  final String title;

  /// Subtitle for login page
  final String? subtitle;

  /// Login button text
  final String loginButtonText;

  /// Login button style
  final ButtonStyle? loginButtonStyle;

  /// Email field label
  final String emailFieldLabel;

  /// Email field hint
  final String emailFieldHint;

  /// Password field label
  final String passwordFieldLabel;

  /// Password field hint
  final String passwordFieldHint;

  /// Custom login form widget builder
  final Widget Function(BuildContext)? formBuilder;

  /// Forgot password text
  final String forgotPasswordText;

  /// Don't have account text
  final String noAccountText;

  /// Sign up text button
  final String signUpText;

  /// Remember me text
  final String rememberMeText;

  /// Show remember me checkbox
  final bool showRememberMe;

  /// Custom login validators
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? passwordValidator;

  /// Custom text input decorations
  final InputDecoration? emailDecoration;
  final InputDecoration? passwordDecoration;

  const LoginConfig({
    this.title = 'Welcome Back',
    this.subtitle,
    this.loginButtonText = 'Sign In',
    this.loginButtonStyle,
    this.emailFieldLabel = 'Email',
    this.emailFieldHint = 'Enter your email',
    this.passwordFieldLabel = 'Password',
    this.passwordFieldHint = 'Enter your password',
    this.formBuilder,
    this.forgotPasswordText = 'Forgot Password?',
    this.noAccountText = 'Don\'t have an account?',
    this.signUpText = 'Sign Up',
    this.rememberMeText = 'Remember Me',
    this.showRememberMe = true,
    this.emailValidator,
    this.passwordValidator,
    this.emailDecoration,
    this.passwordDecoration,
  });

  /// Creates a copy of this [LoginConfig] with optional field replacements
  LoginConfig copyWith({
    String? title,
    String? subtitle,
    String? loginButtonText,
    ButtonStyle? loginButtonStyle,
    String? emailFieldLabel,
    String? emailFieldHint,
    String? passwordFieldLabel,
    String? passwordFieldHint,
    Widget Function(BuildContext)? formBuilder,
    String? forgotPasswordText,
    String? noAccountText,
    String? signUpText,
    String? rememberMeText,
    bool? showRememberMe,
    FormFieldValidator<String>? emailValidator,
    FormFieldValidator<String>? passwordValidator,
    InputDecoration? emailDecoration,
    InputDecoration? passwordDecoration,
  }) {
    return LoginConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      loginButtonText: loginButtonText ?? this.loginButtonText,
      loginButtonStyle: loginButtonStyle ?? this.loginButtonStyle,
      emailFieldLabel: emailFieldLabel ?? this.emailFieldLabel,
      emailFieldHint: emailFieldHint ?? this.emailFieldHint,
      passwordFieldLabel: passwordFieldLabel ?? this.passwordFieldLabel,
      passwordFieldHint: passwordFieldHint ?? this.passwordFieldHint,
      formBuilder: formBuilder ?? this.formBuilder,
      forgotPasswordText: forgotPasswordText ?? this.forgotPasswordText,
      noAccountText: noAccountText ?? this.noAccountText,
      signUpText: signUpText ?? this.signUpText,
      rememberMeText: rememberMeText ?? this.rememberMeText,
      showRememberMe: showRememberMe ?? this.showRememberMe,
      emailValidator: emailValidator ?? this.emailValidator,
      passwordValidator: passwordValidator ?? this.passwordValidator,
      emailDecoration: emailDecoration ?? this.emailDecoration,
      passwordDecoration: passwordDecoration ?? this.passwordDecoration,
    );
  }
}
