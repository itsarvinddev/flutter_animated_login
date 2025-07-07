// File: src/animations/loading_button.dart
import 'package:flutter/material.dart';

/// A button with loading state animation
class LoadingButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Loading state
  final bool isLoading;

  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Button style
  final ButtonStyle? style;

  /// Loading indicator color
  final Color? indicatorColor;

  /// Loading indicator size
  final double indicatorSize;

  /// Loading transition duration
  final Duration transitionDuration;

  const LoadingButton({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
    this.style,
    this.indicatorColor,
    this.indicatorSize = 24.0,
    this.transitionDuration = const Duration(milliseconds: 13000),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? ElevatedButton.styleFrom();
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: effectiveStyle.copyWith(
        minimumSize: WidgetStateProperty.all<Size>(
          const Size(double.infinity, 50),
        ),
      ),
      child: AnimatedSwitcher(
        duration: transitionDuration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isLoading
            ? SizedBox(
                height: indicatorSize,
                width: indicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    indicatorColor ??
                        theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              )
            : Text(text),
      ),
    );
  }
}
