// File: src/widgets/common/messages.dart
import 'package:flutter/material.dart';

import '../../animations/fade_slide.dart';
import '../../theme/auth_theme_extension.dart';

/// Types of message severity
enum MessageType {
  /// Error message (typically red)
  error,

  /// Warning message (typically yellow/orange)
  warning,

  /// Success message (typically green)
  success,

  /// Information message (typically blue)
  info,
}

/// A styled animated message widget
class AuthMessage extends StatelessWidget {
  /// Message text
  final String message;

  /// Message type
  final MessageType type;

  /// Custom text style
  final TextStyle? textStyle;

  /// Whether to show icon
  final bool showIcon;

  /// Whether to show background
  final bool showBackground;

  /// Animation duration
  final Duration animationDuration;

  const AuthMessage({
    super.key,
    required this.message,
    this.type = MessageType.info,
    this.textStyle,
    this.showIcon = true,
    this.showBackground = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    // Determine colors based on message type
    late final Color backgroundColor;
    late final Color textColor;
    late final IconData iconData;

    switch (type) {
      case MessageType.error:
        backgroundColor = authTheme.textFieldErrorColor.withValues(alpha: 0.1);
        textColor = authTheme.textFieldErrorColor;
        iconData = Icons.error_outline;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        iconData = Icons.warning_amber_outlined;
        break;
      case MessageType.success:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case MessageType.info:
        backgroundColor = authTheme.linkColor.withValues(alpha: 0.1);
        textColor = authTheme.linkColor;
        iconData = Icons.info_outline;
        break;
    }

    return FadeSlideTransition(
      duration: animationDuration,
      beginOffset: const Offset(0, 0.5),
      child: showBackground
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (showIcon) ...[
                    Icon(
                      iconData,
                      color: textColor,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: textStyle ??
                          TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                if (showIcon) ...[
                  Icon(
                    iconData,
                    color: textColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: textStyle ??
                        TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
