
// File: src/constants/defaults.dart

import 'package:flutter/material.dart';

/// Default values for the auth package
class Defaults {
  /// Default animation durations
  static const Duration shortAnimation = Duration(milliseconds: 250);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  /// Default OTP length
  static const int otpLength = 6;
  
  /// Default OTP resend cooldown (in seconds)
  static const int resendCooldown = 60;
  
  /// Default card border radius
  static const double cardBorderRadius = 16.0;
  
  /// Default button border radius
  static const double buttonBorderRadius = 12.0;
  
  /// Default field border radius
  static const double fieldBorderRadius = 8.0;
  
  /// Default spacing values
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 32.0;
  
  /// Default text field heights
  static const double textFieldHeight = 56.0;
  
  /// Default button height
  static const double buttonHeight = 50.0;
  
  /// Default card width constraints
  static const double minCardWidth = 300.0;
  static const double maxCardWidth = 450.0;
  
  /// Default card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);
  
  /// Default page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
  
  /// Default OAuth button sizes
  static const double oauthButtonSize = 44.0;
  static const double oauthIconSize = 24.0;
  
  /// Private constructor
  Defaults._();
}