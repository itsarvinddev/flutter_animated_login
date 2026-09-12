import 'package:flutter/material.dart';

import '../login.dart';

/// How the social login buttons are laid out.
enum ProviderLayout {
  /// A single centred row of circular icon buttons. The historical layout;
  /// it does not wrap, so keep it for three providers or fewer.
  iconRow,

  /// Circular icon buttons that wrap onto more rows as needed. Safe for any
  /// number of providers and any text scale.
  iconWrap,

  /// Full-width labelled buttons stacked vertically — what Apple's and
  /// Google's sign-in brand guidelines ask for.
  fullWidthStacked,
}

/// One social or federated sign-in option.
///
/// Supply exactly one of [icon], [iconWidget] or [button]:
///
/// ```dart
/// LoginProvider(
///   iconWidget: Image.asset('assets/google.png', height: 20),
///   label: const Text('Continue with Google'),
///   semanticLabel: 'Sign in with Google',
///   backgroundColor: Colors.white,
///   foregroundColor: Colors.black87,
///   callback: () async => signInWithGoogle(),
/// )
/// ```
@immutable
class LoginProvider {
  /// A Material glyph for the button.
  ///
  /// Use [iconWidget] instead when the provider's brand guidelines require
  /// their own mark — Apple and Google both do.
  final IconData? icon;

  /// An arbitrary widget for the button: an [Image], an SVG, a brand logo.
  ///
  /// Takes precedence over [icon].
  final Widget? iconWidget;

  /// A fully custom button, rendered instead of anything the package builds.
  ///
  /// Takes precedence over [icon] and [iconWidget]. You are responsible for
  /// calling [callback] and for the loading state.
  final Widget? button;

  /// The label shown under the button in [ProviderLayout.iconRow] and
  /// [ProviderLayout.iconWrap], and inside it in
  /// [ProviderLayout.fullWidthStacked].
  final Widget? label;

  /// What a screen reader announces, e.g. "Sign in with Google".
  ///
  /// Strongly recommended: without it an icon-only button announces nothing
  /// useful. Falls back to the text inside [label], then to "Sign in".
  final String? semanticLabel;

  /// Runs your authentication.
  ///
  /// Return `null` or the empty string on success, or a message describing the
  /// failure — it is shown to the user unless it matches
  /// [errorsToExcludeFromErrorMessage].
  final ProviderAuthCallback callback;

  /// Asked after [callback] succeeds. When it resolves `true` the signup
  /// screen opens so the user can supply the extra details your backend needs.
  final ProviderNeedsSignUpCallback? providerNeedsSignUpCallback;

  /// How long the button's loading transition takes.
  final Duration? transitionDuration;

  /// Messages from [callback] that should not be shown.
  ///
  /// Use it to swallow "user cancelled" style results that are not really
  /// errors. Compared case-insensitively against the whole message.
  final List<String>? errorsToExcludeFromErrorMessage;

  /// Overrides the button's style entirely.
  final ButtonStyle? style;

  /// Fill colour of the button, when [style] is not given.
  final Color? backgroundColor;

  /// Colour of the icon and label, when [style] is not given.
  final Color? foregroundColor;

  /// Shown in place of the icon while [callback] runs.
  final Widget? loading;

  /// Colour of the default loading indicator.
  final Color? loadingColor;

  /// Creates a social login option.
  const LoginProvider({
    required this.callback,
    this.icon,
    this.iconWidget,
    this.button,
    this.label,
    this.semanticLabel,
    this.errorsToExcludeFromErrorMessage,
    this.providerNeedsSignUpCallback,
    this.transitionDuration = kThemeAnimationDuration,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.loading,
    this.loadingColor,
  }) : assert(
          icon != null || iconWidget != null || button != null,
          'A LoginProvider needs something to render: pass icon, iconWidget '
          'or button.',
        );

  /// Whether [message] should be hidden from the user.
  bool shouldSuppress(String? message) {
    if (message == null || message.isEmpty) return true;
    final excluded = errorsToExcludeFromErrorMessage;
    if (excluded == null || excluded.isEmpty) return false;
    final lower = message.toLowerCase();
    return excluded.any((e) => e.toLowerCase() == lower);
  }

  /// A copy of this provider with the given properties replaced.
  LoginProvider copyWith({
    IconData? icon,
    Widget? iconWidget,
    Widget? button,
    Widget? label,
    String? semanticLabel,
    ProviderAuthCallback? callback,
    ProviderNeedsSignUpCallback? providerNeedsSignUpCallback,
    Duration? transitionDuration,
    List<String>? errorsToExcludeFromErrorMessage,
    ButtonStyle? style,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? loading,
    Color? loadingColor,
  }) {
    return LoginProvider(
      icon: icon ?? this.icon,
      iconWidget: iconWidget ?? this.iconWidget,
      button: button ?? this.button,
      label: label ?? this.label,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      callback: callback ?? this.callback,
      providerNeedsSignUpCallback:
          providerNeedsSignUpCallback ?? this.providerNeedsSignUpCallback,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      errorsToExcludeFromErrorMessage: errorsToExcludeFromErrorMessage ??
          this.errorsToExcludeFromErrorMessage,
      style: style ?? this.style,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      loading: loading ?? this.loading,
      loadingColor: loadingColor ?? this.loadingColor,
    );
  }
}
