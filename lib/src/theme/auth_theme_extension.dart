import 'dart:ui';

import 'package:flutter/material.dart';

/// Theme extension for authentication UI
class AuthThemeExtension extends ThemeExtension<AuthThemeExtension> {
  /// Main background color
  final Color backgroundColor;

  /// Background gradient
  final LinearGradient? backgroundGradient;

  /// Card background color
  final Color cardBackgroundColor;

  /// Card border color
  final Color cardBorderColor;

  /// Card border width
  final double cardBorderWidth;

  /// Card border radius
  final double cardBorderRadius;

  /// Card elevation
  final double cardElevation;

  /// Card shadow color
  final Color cardShadowColor;

  /// Primary button color
  final Color primaryButtonColor;

  /// Primary button text color
  final Color primaryButtonTextColor;

  /// Secondary button color
  final Color secondaryButtonColor;

  /// Secondary button text color
  final Color secondaryButtonTextColor;

  /// Border button color
  final Color borderButtonColor;

  /// Border button text color
  final Color borderButtonTextColor;

  /// Text field border color
  final Color textFieldBorderColor;

  /// Text field focus color
  final Color textFieldFocusColor;

  /// Text field background color
  final Color textFieldBackgroundColor;

  /// Text field text color
  final Color textFieldTextColor;

  /// Text field hint color
  final Color textFieldHintColor;

  /// Text field error color
  final Color textFieldErrorColor;

  /// Title text color
  final Color titleColor;

  /// Subtitle text color
  final Color subtitleColor;

  /// Link text color
  final Color linkColor;

  /// Divider color
  final Color dividerColor;

  /// Social button background colors
  final Map<String, Color> socialButtonColors;

  /// Social button icon colors
  final Map<String, Color> socialIconColors;

  /// OTP field background color
  final Color otpFieldBackgroundColor;

  /// OTP field border color
  final Color otpFieldBorderColor;

  /// OTP field active color
  final Color otpFieldActiveColor;

  /// OTP field text color
  final Color otpFieldTextColor;

  /// Constructor
  const AuthThemeExtension({
    required this.backgroundColor,
    this.backgroundGradient,
    required this.cardBackgroundColor,
    required this.cardBorderColor,
    this.cardBorderWidth = 1.0,
    this.cardBorderRadius = 16.0,
    this.cardElevation = 4.0,
    required this.cardShadowColor,
    required this.primaryButtonColor,
    required this.primaryButtonTextColor,
    required this.secondaryButtonColor,
    required this.secondaryButtonTextColor,
    required this.borderButtonColor,
    required this.borderButtonTextColor,
    required this.textFieldBorderColor,
    required this.textFieldFocusColor,
    required this.textFieldBackgroundColor,
    required this.textFieldTextColor,
    required this.textFieldHintColor,
    required this.textFieldErrorColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.linkColor,
    required this.dividerColor,
    this.socialButtonColors = const {},
    this.socialIconColors = const {},
    required this.otpFieldBackgroundColor,
    required this.otpFieldBorderColor,
    required this.otpFieldActiveColor,
    required this.otpFieldTextColor,
  });

  /// Default theme extension based on current theme
  factory AuthThemeExtension.defaults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Default social button colors
    final defaultSocialButtonColors = {
      'google': Colors.white,
      'apple': isDark ? Colors.white : Colors.black,
      'facebook': const Color(0xFF1877F2),
      'twitter': const Color(0xFF1DA1F2),
      'github': isDark ? Colors.white : Colors.black87,
      'microsoft': const Color(0xFF2F2F2F),
    };

    // Default social icon colors
    final defaultSocialIconColors = {
      'google': Colors.black87,
      'apple': isDark ? Colors.black87 : Colors.white,
      'facebook': Colors.white,
      'twitter': Colors.white,
      'github': isDark ? Colors.black87 : Colors.white,
      'microsoft': Colors.white,
    };

    return AuthThemeExtension(
      backgroundColor: theme.scaffoldBackgroundColor,
      backgroundGradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withOpacity(0.8),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.primary.withOpacity(0.05),
              ],
            ),
      cardBackgroundColor: theme.cardColor,
      cardBorderColor: theme.dividerColor.withOpacity(0.2),
      cardShadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
      primaryButtonColor: colorScheme.primary,
      primaryButtonTextColor: colorScheme.onPrimary,
      secondaryButtonColor: colorScheme.secondary,
      secondaryButtonTextColor: colorScheme.onSecondary,
      borderButtonColor: Colors.transparent,
      borderButtonTextColor: colorScheme.primary,
      textFieldBorderColor: theme.dividerColor,
      textFieldFocusColor: colorScheme.primary,
      textFieldBackgroundColor:
          isDark ? colorScheme.surface.withOpacity(0.8) : colorScheme.surface,
      textFieldTextColor: colorScheme.onSurface,
      textFieldHintColor: colorScheme.onSurface.withOpacity(0.6),
      textFieldErrorColor: colorScheme.error,
      titleColor: colorScheme.onSurface,
      subtitleColor: colorScheme.onSurface.withOpacity(0.7),
      linkColor: colorScheme.primary,
      dividerColor: theme.dividerColor,
      socialButtonColors: defaultSocialButtonColors,
      socialIconColors: defaultSocialIconColors,
      otpFieldBackgroundColor:
          isDark ? colorScheme.surface.withOpacity(0.8) : colorScheme.surface,
      otpFieldBorderColor: theme.dividerColor,
      otpFieldActiveColor: colorScheme.primary,
      otpFieldTextColor: colorScheme.onSurface,
    );
  }

  @override
  ThemeExtension<AuthThemeExtension> copyWith({
    Color? backgroundColor,
    LinearGradient? backgroundGradient,
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    double? cardBorderWidth,
    double? cardBorderRadius,
    double? cardElevation,
    Color? cardShadowColor,
    Color? primaryButtonColor,
    Color? primaryButtonTextColor,
    Color? secondaryButtonColor,
    Color? secondaryButtonTextColor,
    Color? borderButtonColor,
    Color? borderButtonTextColor,
    Color? textFieldBorderColor,
    Color? textFieldFocusColor,
    Color? textFieldBackgroundColor,
    Color? textFieldTextColor,
    Color? textFieldHintColor,
    Color? textFieldErrorColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? linkColor,
    Color? dividerColor,
    Map<String, Color>? socialButtonColors,
    Map<String, Color>? socialIconColors,
    Color? otpFieldBackgroundColor,
    Color? otpFieldBorderColor,
    Color? otpFieldActiveColor,
    Color? otpFieldTextColor,
  }) {
    return AuthThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
      primaryButtonTextColor:
          primaryButtonTextColor ?? this.primaryButtonTextColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      secondaryButtonTextColor:
          secondaryButtonTextColor ?? this.secondaryButtonTextColor,
      borderButtonColor: borderButtonColor ?? this.borderButtonColor,
      borderButtonTextColor:
          borderButtonTextColor ?? this.borderButtonTextColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      textFieldFocusColor: textFieldFocusColor ?? this.textFieldFocusColor,
      textFieldBackgroundColor:
          textFieldBackgroundColor ?? this.textFieldBackgroundColor,
      textFieldTextColor: textFieldTextColor ?? this.textFieldTextColor,
      textFieldHintColor: textFieldHintColor ?? this.textFieldHintColor,
      textFieldErrorColor: textFieldErrorColor ?? this.textFieldErrorColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      linkColor: linkColor ?? this.linkColor,
      dividerColor: dividerColor ?? this.dividerColor,
      socialButtonColors: socialButtonColors ?? this.socialButtonColors,
      socialIconColors: socialIconColors ?? this.socialIconColors,
      otpFieldBackgroundColor:
          otpFieldBackgroundColor ?? this.otpFieldBackgroundColor,
      otpFieldBorderColor: otpFieldBorderColor ?? this.otpFieldBorderColor,
      otpFieldActiveColor: otpFieldActiveColor ?? this.otpFieldActiveColor,
      otpFieldTextColor: otpFieldTextColor ?? this.otpFieldTextColor,
    );
  }

  @override
  ThemeExtension<AuthThemeExtension> lerp(
    covariant ThemeExtension<AuthThemeExtension>? other,
    double t,
  ) {
    if (other is! AuthThemeExtension) {
      return this;
    }

    // Helper function to lerp colors in a map
    Map<String, Color> lerpColorMap(
      Map<String, Color> a,
      Map<String, Color> b,
      double t,
    ) {
      final result = <String, Color>{};
      final allKeys = <String>{...a.keys, ...b.keys};

      for (final key in allKeys) {
        final aColor = a[key] ?? b[key] ?? Colors.transparent;
        final bColor = b[key] ?? a[key] ?? Colors.transparent;
        result[key] = Color.lerp(aColor, bColor, t)!;
      }

      return result;
    }

    return AuthThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      ),
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      cardBorderWidth: lerpDouble(cardBorderWidth, other.cardBorderWidth, t)!,
      cardBorderRadius:
          lerpDouble(cardBorderRadius, other.cardBorderRadius, t)!,
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
      primaryButtonColor:
          Color.lerp(primaryButtonColor, other.primaryButtonColor, t)!,
      primaryButtonTextColor:
          Color.lerp(primaryButtonTextColor, other.primaryButtonTextColor, t)!,
      secondaryButtonColor:
          Color.lerp(secondaryButtonColor, other.secondaryButtonColor, t)!,
      secondaryButtonTextColor: Color.lerp(
          secondaryButtonTextColor, other.secondaryButtonTextColor, t)!,
      borderButtonColor:
          Color.lerp(borderButtonColor, other.borderButtonColor, t)!,
      borderButtonTextColor:
          Color.lerp(borderButtonTextColor, other.borderButtonTextColor, t)!,
      textFieldBorderColor:
          Color.lerp(textFieldBorderColor, other.textFieldBorderColor, t)!,
      textFieldFocusColor:
          Color.lerp(textFieldFocusColor, other.textFieldFocusColor, t)!,
      textFieldBackgroundColor: Color.lerp(
          textFieldBackgroundColor, other.textFieldBackgroundColor, t)!,
      textFieldTextColor:
          Color.lerp(textFieldTextColor, other.textFieldTextColor, t)!,
      textFieldHintColor:
          Color.lerp(textFieldHintColor, other.textFieldHintColor, t)!,
      textFieldErrorColor:
          Color.lerp(textFieldErrorColor, other.textFieldErrorColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      linkColor: Color.lerp(linkColor, other.linkColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      socialButtonColors:
          lerpColorMap(socialButtonColors, other.socialButtonColors, t),
      socialIconColors:
          lerpColorMap(socialIconColors, other.socialIconColors, t),
      otpFieldBackgroundColor: Color.lerp(
          otpFieldBackgroundColor, other.otpFieldBackgroundColor, t)!,
      otpFieldBorderColor:
          Color.lerp(otpFieldBorderColor, other.otpFieldBorderColor, t)!,
      otpFieldActiveColor:
          Color.lerp(otpFieldActiveColor, other.otpFieldActiveColor, t)!,
      otpFieldTextColor:
          Color.lerp(otpFieldTextColor, other.otpFieldTextColor, t)!,
    );
  }
}
