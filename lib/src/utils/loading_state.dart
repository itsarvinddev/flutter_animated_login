import 'package:flutter/material.dart';

/// Mixin to handle loading state for a widget
///
/// This mixin provides a [isLoading] notifier and a [runLoading] method to
/// handle loading state for a widget.
///
/// The [isLoading] notifier can be used to display a loading indicator when
/// the widget is in a loading state.
///
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  /// Whether [runLoading] is currently awaiting a callback.
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Runs [callback] with [isLoading] held true for its duration.
  Future<void> runLoading(Future<void> Function()? callback) async {
    if (callback == null) return;

    isLoading.value = true;
    try {
      await callback();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }
}

/// Which Material button [AutoLoadingButton] renders.
enum AutoLoadingButtonVariant {
  /// A filled, high-emphasis button — the primary action.
  filled,

  /// A low-emphasis text button — secondary actions such as "Resend OTP".
  text,
}

/// A button that shows a spinner while its callback runs.
///
/// Drive it externally with [isLoading], or leave that null and let the button
/// track its own [onPressed] future.
class AutoLoadingButton extends StatefulWidget {
  /// The label shown when not loading.
  final Widget child;

  /// Runs when the button is pressed. A null callback disables the button.
  final Future<void> Function()? onPressed;

  /// Shown in place of [child] while loading. Defaults to a small spinner.
  final Widget? loading;

  /// The button's style.
  final ButtonStyle? style;

  /// How long the swap between [child] and [loading] takes.
  final Duration? transitionDuration;

  /// The curve that swap follows.
  final Curve? transitionCurve;

  /// Fixed width, or null to size to the content.
  final double? width;

  /// Fixed height, or null to size to the content.
  final double? height;

  /// The colour of the default spinner.
  final Color? loadingColor;

  /// Drives the loading state from outside. Null lets the button track its
  /// own [onPressed] future.
  final bool? isLoading;

  /// Called whenever the loading state changes.
  final VoidCallback? onLoadingStateChanged;

  /// Which Material button to render. A text-styled [ButtonStyle] on a
  /// [FilledButton] painted a filled button with text-button metrics.
  final AutoLoadingButtonVariant variant;

  /// Announced by a screen reader in place of [child].
  final String? semanticLabel;

  /// Simple button that automatically handles loading state and transitions
  ///
  /// The [child] is the widget to display when not loading.
  ///
  /// The [onPressed] callback is called when the button is pressed.
  ///
  /// The [loading] widget is displayed when the button is loading.
  ///
  /// The [style] is the button style to use.
  ///
  /// The [transitionDuration] is the duration of the transition animation.
  ///
  /// The [transitionCurve] is the curve of the transition animation.
  ///
  /// The [width] is the width of the button.
  ///
  /// The [height] is the height of the button.
  ///
  /// The [loadingColor] is the color of the loading indicator.
  ///
  /// The [isLoading] is the loading state of the button.
  ///
  /// The [onLoadingStateChanged] is called when the loading state changes.
  ///
  const AutoLoadingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.loading,
    this.style,
    this.transitionDuration,
    this.transitionCurve,
    this.width,
    this.height,
    this.loadingColor,
    this.isLoading,
    this.onLoadingStateChanged,
    this.variant = AutoLoadingButtonVariant.filled,
    this.semanticLabel,
  });

  @override
  State<AutoLoadingButton> createState() => _AutoLoadingButtonState();
}

class _AutoLoadingButtonState extends State<AutoLoadingButton>
    with LoadingStateMixin {
  @override
  void initState() {
    super.initState();
    // Set initial loading state if provided
    if (widget.isLoading != null) {
      isLoading.value = widget.isLoading!;
    }
  }

  @override
  void didUpdateWidget(AutoLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update loading state if it's controlled externally
    if (widget.isLoading != null && widget.isLoading != isLoading.value) {
      isLoading.value = widget.isLoading!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        // Notify parent about loading state changes
        if (widget.onLoadingStateChanged != null &&
            ((widget.isLoading == null) || (widget.isLoading != loading))) {
          // Use Future.microtask to avoid build-phase setState errors
          Future.microtask(() => widget.onLoadingStateChanged!());
        }

        // Container to maintain consistent size during transitions
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: child,
        );
      },
      child: _buildButton(),
    );
  }

  Widget _button(
    BuildContext context, {
    required Key key,
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    final button = switch (widget.variant) {
      AutoLoadingButtonVariant.filled => FilledButton(
          key: key,
          onPressed: onPressed,
          style: widget.style,
          child: child,
        ),
      AutoLoadingButtonVariant.text => TextButton(
          key: key,
          onPressed: onPressed,
          style: widget.style,
          child: child,
        ),
    };
    if (widget.semanticLabel == null) return button;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: ExcludeSemantics(child: button),
    );
  }

  /// Build the appropriate button widget based on button type
  Widget _buildButton() {
    // Create onPressed callback only if widget.onPressed is provided
    VoidCallback? onPressedCallback =
        widget.onPressed != null ? () => runLoading(widget.onPressed) : null;

    // Don't allow button press if externally controlled and in loading state
    if (widget.isLoading != null && widget.isLoading!) {
      onPressedCallback = null;
    }

    // Create content with AnimatedSwitcher for smooth transitions
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        return AnimatedSwitcher(
          duration: widget.transitionDuration ?? kThemeAnimationDuration,
          switchInCurve: widget.transitionCurve ?? Curves.easeInOut,
          switchOutCurve: widget.transitionCurve ?? Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(begin: 0.95, end: 1.0),
                ),
                child: child,
              ),
            );
          },
          child: _button(
            context,
            // Keyed on the state being switched between; a constant key gave
            // AnimatedSwitcher nothing to notice, so it never animated.
            key: ValueKey<bool>(loading),
            onPressed: loading ? null : onPressedCallback,
            child: loading
                ? (widget.loading ??
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: widget.loadingColor ??
                            Theme.of(context).colorScheme.onSurface,
                        strokeWidth: 2,
                      ),
                    ))
                : widget.child,
          ),
        );
      },
    );
  }
}
