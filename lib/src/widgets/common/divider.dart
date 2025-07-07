// File: src/widgets/common/divider.dart
import 'package:flutter/material.dart';

import '../../theme/auth_theme_extension.dart';

/// A styled divider with optional text
class AuthDivider extends StatelessWidget {
  /// Divider text
  final String? text;

  /// Divider color
  final Color? color;

  /// Text style
  final TextStyle? textStyle;

  /// Height from the content
  final double height;

  /// Thickness of the divider line
  final double thickness;

  const AuthDivider({
    super.key,
    this.text,
    this.color,
    this.textStyle,
    this.height = 32.0,
    this.thickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    final effectiveColor = color ?? authTheme.dividerColor;
    final effectiveTextStyle = textStyle ??
        TextStyle(
          color: authTheme.subtitleColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height / 2),
      child: text != null
          ? Row(
              children: [
                Expanded(
                  child: Divider(
                    color: effectiveColor,
                    thickness: thickness,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    text!,
                    style: effectiveTextStyle,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: effectiveColor,
                    thickness: thickness,
                  ),
                ),
              ],
            )
          : Divider(
              color: effectiveColor,
              thickness: thickness,
            ),
    );
  }
}
