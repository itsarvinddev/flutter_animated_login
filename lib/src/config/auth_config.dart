// File: src/config/auth_config.dart
import 'package:flutter/material.dart';

import '../constants/enums.dart';
import 'login_config.dart';
import 'reset_config.dart';
import 'signup_config.dart';
import 'verify_config.dart';

/// Main configuration for the auth flow
class AuthConfig {
  /// Configuration for login page
  final LoginConfig loginConfig;

  /// Configuration for signup page
  final SignupConfig signupConfig;

  /// Configuration for password reset page
  final ResetConfig resetConfig;

  /// Configuration for OTP verification page
  final VerifyConfig verifyConfig;

  /// App logo widget
  final Widget? logoWidget;

  /// Title shown above the auth card
  final String? title;

  /// Title text style
  final TextStyle? titleStyle;

  /// Subtitle shown above the auth card
  final String? subtitle;

  /// Subtitle text style
  final TextStyle? subtitleStyle;

  /// Terms and conditions text
  final Widget? termsAndConditions;

  /// Available OAuth providers
  final List<AuthProvider>? providers;

  /// Whether to show OAuth providers
  final bool showProviders;

  /// Whether to enable social login
  final bool enableSocialLogin;

  /// Control the types of login methods available
  final LoginMethods loginMethods;

  const AuthConfig({
    this.loginConfig = const LoginConfig(),
    this.signupConfig = const SignupConfig(),
    this.resetConfig = const ResetConfig(),
    this.verifyConfig = const VerifyConfig(),
    this.logoWidget,
    this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    this.termsAndConditions,
    this.providers,
    this.showProviders = true,
    this.enableSocialLogin = true,
    this.loginMethods = LoginMethods.emailPassword,
  });

  /// Creates a copy of this [AuthConfig] with optional field replacements
  AuthConfig copyWith({
    LoginConfig? loginConfig,
    SignupConfig? signupConfig,
    ResetConfig? resetConfig,
    VerifyConfig? verifyConfig,
    Widget? logoWidget,
    String? title,
    TextStyle? titleStyle,
    String? subtitle,
    TextStyle? subtitleStyle,
    Widget? termsAndConditions,
    List<AuthProvider>? providers,
    bool? showProviders,
    bool? enableSocialLogin,
    LoginMethods? loginMethods,
  }) {
    return AuthConfig(
      loginConfig: loginConfig ?? this.loginConfig,
      signupConfig: signupConfig ?? this.signupConfig,
      resetConfig: resetConfig ?? this.resetConfig,
      verifyConfig: verifyConfig ?? this.verifyConfig,
      logoWidget: logoWidget ?? this.logoWidget,
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitle: subtitle ?? this.subtitle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      providers: providers ?? this.providers,
      showProviders: showProviders ?? this.showProviders,
      enableSocialLogin: enableSocialLogin ?? this.enableSocialLogin,
      loginMethods: loginMethods ?? this.loginMethods,
    );
  }

  /// Helper method to convert LoginMethods to LoginType
  LoginType get loginType {
    switch (loginMethods) {
      case LoginMethods.emailOtp:
      case LoginMethods.phoneOtp:
      case LoginMethods.emailPhoneOtp:
        return LoginType.otp;
      case LoginMethods.emailPhonePassword:
        return LoginType.otpAndPassword;
      case LoginMethods.emailPassword:
      case LoginMethods.all:
        return LoginType.password;
    }
  }
}
