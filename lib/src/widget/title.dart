import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/extension.dart';
import '../utils/theme.dart';

/// The logo, title and subtitle block at the top of every screen.
class TitleWidget extends StatefulWidget {
  /// Creates a title block.
  const TitleWidget({
    super.key,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.child = const FlutterLogo(size: 100),
    this.titleGap = const SizedBox(height: 20),
    this.onTap,
    this.actionLabel,
  });

  /// The heading.
  final String? title;

  /// The line under the heading.
  final String? subtitle;

  /// Style of [title].
  final TextStyle? titleStyle;

  /// Style of [subtitle].
  final TextStyle? subtitleStyle;

  /// Rendered above [title]. Defaults to a [FlutterLogo].
  final Widget? child;

  /// Space between [title] and [subtitle].
  final Widget? titleGap;

  /// When given, [actionLabel] is appended to [subtitle] as a tappable link.
  final VoidCallback? onTap;

  /// The link's label. Defaults to [FormMessages.edit].
  final String? actionLabel;

  @override
  State<TitleWidget> createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  // Owned by the State, not rebuilt per frame. Before 1.0.0 this was allocated
  // inside build(), so the verify screen — which rebuilds once a second for
  // its countdown — leaked one recognizer per second.
  TapGestureRecognizer? _recognizer;

  @override
  void didUpdateWidget(TitleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap != oldWidget.onTap) {
      _recognizer?.onTap = widget.onTap;
    }
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    super.dispose();
  }

  TapGestureRecognizer get _tapRecognizer =>
      _recognizer ??= (TapGestureRecognizer()..onTap = widget.onTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loginTheme = AnimatedLoginTheme.of(context);
    final hasTitle = widget.title.isNotEmptyOrNull;
    final hasSubtitle = widget.subtitle.isNotEmptyOrNull;

    return Column(
      children: [
        widget.child.orShrink,
        if (widget.child.isNotNull) const SizedBox(height: 20),
        if (hasTitle)
          Semantics(
            header: true,
            child: Text(
              widget.title ?? '',
              textAlign: TextAlign.center,
              style:
                  widget.titleStyle ??
                  loginTheme.titleStyle ??
                  textTheme.headlineMedium,
            ),
          ),
        if (hasTitle && hasSubtitle) widget.titleGap.orShrink,
        if (hasSubtitle)
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: widget.subtitle ?? '',
              style:
                  widget.subtitleStyle ??
                  loginTheme.subtitleStyle ??
                  textTheme.titleMedium,
              children: [
                if (widget.onTap != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: widget.actionLabel ?? 'Edit',
                    style: (loginTheme.linkStyle ?? const TextStyle()).copyWith(
                      color:
                          loginTheme.linkStyle?.color ??
                          theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _tapRecognizer,
                  ),
                ],
              ],
            ),
          ),
        if (hasTitle && hasSubtitle) const SizedBox(height: 40),
      ],
    );
  }
}
