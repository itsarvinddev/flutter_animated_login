// File: src/config/verify_config.dart
import 'package:flutter/material.dart';

/// Configuration for OTP verification page
class VerifyConfig {
  /// Title for verification page
  final String title;

  /// Subtitle for verification page
  final String subtitle;

  /// Verify button text
  final String verifyButtonText;

  /// Verify button style
  final ButtonStyle? verifyButtonStyle;

  /// Resend code text
  final String resendCodeText;

  /// Back text
  final String backText;

  /// Custom verify form widget builder
  final Widget Function(BuildContext)? formBuilder;

  /// OTP length
  final int otpLength;

  /// OTP field style
  final TextStyle? otpTextStyle;

  /// OTP field decoration
  final BoxDecoration? otpPinBoxDecoration;

  /// OTP field selected decoration
  final BoxDecoration? otpPinBoxSelectedDecoration;

  /// OTP resend coolDown in seconds
  final int resendCoolDown;

  /// Error message for invalid OTP
  final String invalidOtpMessage;

  /// Success message after verification
  final String verifySuccessMessage;

  /// Custom OTP validator
  final FormFieldValidator<String>? otpValidator;

  const VerifyConfig({
    this.title = 'Verification',
    this.subtitle = 'Enter the code sent to your email or phone',
    this.verifyButtonText = 'Verify',
    this.verifyButtonStyle,
    this.resendCodeText = 'Resend Code',
    this.backText = 'Back',
    this.formBuilder,
    this.otpLength = 6,
    this.otpTextStyle,
    this.otpPinBoxDecoration,
    this.otpPinBoxSelectedDecoration,
    this.resendCoolDown = 60,
    this.invalidOtpMessage = 'Invalid verification code',
    this.verifySuccessMessage = 'Verification successful',
    this.otpValidator,
  });

  /// Creates a copy of this [VerifyConfig] with optional field replacements
  VerifyConfig copyWith({
    String? title,
    String? subtitle,
    String? verifyButtonText,
    ButtonStyle? verifyButtonStyle,
    String? resendCodeText,
    String? backText,
    Widget Function(BuildContext)? formBuilder,
    int? otpLength,
    TextStyle? otpTextStyle,
    BoxDecoration? otpPinBoxDecoration,
    BoxDecoration? otpPinBoxSelectedDecoration,
    int? resendCoolDown,
    String? invalidOtpMessage,
    String? verifySuccessMessage,
    FormFieldValidator<String>? otpValidator,
  }) {
    return VerifyConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      verifyButtonText: verifyButtonText ?? this.verifyButtonText,
      verifyButtonStyle: verifyButtonStyle ?? this.verifyButtonStyle,
      resendCodeText: resendCodeText ?? this.resendCodeText,
      backText: backText ?? this.backText,
      formBuilder: formBuilder ?? this.formBuilder,
      otpLength: otpLength ?? this.otpLength,
      otpTextStyle: otpTextStyle ?? this.otpTextStyle,
      otpPinBoxDecoration: otpPinBoxDecoration ?? this.otpPinBoxDecoration,
      otpPinBoxSelectedDecoration:
          otpPinBoxSelectedDecoration ?? this.otpPinBoxSelectedDecoration,
      resendCoolDown: resendCoolDown ?? this.resendCoolDown,
      invalidOtpMessage: invalidOtpMessage ?? this.invalidOtpMessage,
      verifySuccessMessage: verifySuccessMessage ?? this.verifySuccessMessage,
      otpValidator: otpValidator ?? this.otpValidator,
    );
  }
}
