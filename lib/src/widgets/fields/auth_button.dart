// File: src/widgets/fields/auth_button.dart
import 'package:flutter/material.dart';

import '../../animations/loading_button.dart';
import '../../theme/auth_theme_extension.dart';

/// A styled authentication button with loading state
class AuthButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Loading state
  final bool isLoading;

  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Button style
  final ButtonStyle? style;

  /// Button type (primary, secondary or outlined)
  final AuthButtonType type;

  const AuthButton({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
    this.style,
    this.type = AuthButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    // Determine button colors based on type
    late final Color backgroundColor;
    late final Color textColor;

    switch (type) {
      case AuthButtonType.primary:
        backgroundColor = authTheme.primaryButtonColor;
        textColor = authTheme.primaryButtonTextColor;
        break;
      case AuthButtonType.secondary:
        backgroundColor = authTheme.secondaryButtonColor;
        textColor = authTheme.secondaryButtonTextColor;
        break;
      case AuthButtonType.outlined:
        backgroundColor = Colors.transparent;
        textColor = authTheme.borderButtonTextColor;
        break;
    }

    // Create appropriate button style
    final effectiveStyle = style ??
        _createButtonStyle(
          context,
          backgroundColor,
          textColor,
          type,
          authTheme,
        );

    return LoadingButton(
      text: text,
      isLoading: isLoading,
      onPressed: onPressed,
      style: effectiveStyle,
      indicatorColor: textColor,
    );
  }

  ButtonStyle _createButtonStyle(
    BuildContext context,
    Color backgroundColor,
    Color textColor,
    AuthButtonType type,
    AuthThemeExtension authTheme,
  ) {
    final baseStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 50),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    switch (type) {
      case AuthButtonType.primary:
      case AuthButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        )
            .copyWith(
              elevation: WidgetStateProperty.all<double>(2),
            )
            .merge(baseStyle);

      case AuthButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: authTheme.borderButtonColor),
        ).merge(baseStyle);
    }
  }
}

/// Button types for auth buttons
enum AuthButtonType {
  /// Primary accent button
  primary,

  /// Secondary accent button
  secondary,

  /// Outlined button
  outlined,
}
