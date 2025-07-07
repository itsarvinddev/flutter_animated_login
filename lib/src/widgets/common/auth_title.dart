// File: src/widgets/common/auth_title.dart
import 'package:flutter/material.dart';

import '../../animations/fade_slide.dart';
import '../../theme/auth_theme_extension.dart';

/// A styled title widget for authentication pages
class AuthTitle extends StatelessWidget {
  /// Main title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Custom title style
  final TextStyle? titleStyle;

  /// Custom subtitle style
  final TextStyle? subtitleStyle;

  /// Custom icon
  final Widget? icon;

  /// Animation duration
  final Duration animationDuration;

  const AuthTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.icon,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null)
          FadeSlideTransition(
            duration: animationDuration,
            beginOffset: const Offset(0, -0.2),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: icon!,
            ),
          ),

        // Title
        FadeSlideTransition(
          duration: animationDuration,
          beginOffset: const Offset(0, 0.2),
          child: Text(
            title,
            style: titleStyle ??
                theme.textTheme.headlineMedium?.copyWith(
                  color: authTheme.titleColor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),

        // Subtitle
        if (subtitle != null)
          FadeSlideTransition(
            duration: animationDuration,
            beginOffset: const Offset(0, 0.3),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                subtitle!,
                style: subtitleStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: authTheme.subtitleColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
