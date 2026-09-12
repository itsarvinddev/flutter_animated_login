import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// One place to brand every screen the package renders.
///
/// Register it on your [ThemeData] and every [FlutterAnimatedLogin] below
/// picks it up:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     colorSchemeSeed: Colors.indigo,
///     extensions: const [
///       AnimatedLoginTheme(
///         cardRadius: BorderRadius.all(Radius.circular(28)),
///         fieldGap: 20,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Or hand one straight to the widget with [FlutterAnimatedLogin.theme], which
/// wins over the one on [ThemeData].
///
/// Resolution order for any single property: the matching field on a specific
/// config object (`PageConfig.cardPadding`, `LoginConfig.buttonTextStyle`, …)
/// beats [FlutterAnimatedLogin.theme], which beats
/// `Theme.of(context).extension<AnimatedLoginTheme>()`, which beats the
/// package's [ColorScheme]-derived defaults. Nothing you already configure
/// changes behaviour by adding a theme.
@immutable
class AnimatedLoginTheme extends ThemeExtension<AnimatedLoginTheme> {
  /// Fill colour of the card holding the form.
  final Color? cardColor;

  /// First colour of the background gradient.
  final Color? backgroundGradientStart;

  /// Last colour of the background gradient.
  final Color? backgroundGradientEnd;

  /// Corner radius of the card.
  final BorderRadius? cardRadius;

  /// Corner radius of every text field.
  final BorderRadius? fieldRadius;

  /// Corner radius of the primary button.
  final BorderRadius? buttonRadius;

  /// Padding inside the card.
  final EdgeInsetsGeometry? cardPadding;

  /// Vertical space between stacked fields.
  final double? fieldGap;

  /// Widest the card grows on a large window.
  final double? maxCardWidth;

  /// Shadow cast by the card on a large window.
  final List<BoxShadow>? cardShadow;

  /// Style of the screen title.
  final TextStyle? titleStyle;

  /// Style of the screen subtitle.
  final TextStyle? subtitleStyle;

  /// Style of the primary button's label.
  final TextStyle? buttonTextStyle;

  /// Style of secondary links such as "Sign Up" and "Forgot Password?".
  final TextStyle? linkStyle;

  /// Style of the primary button.
  final ButtonStyle? primaryButtonStyle;

  /// Style of secondary text buttons.
  final ButtonStyle? secondaryButtonStyle;

  /// Style of the social login buttons.
  final ButtonStyle? providerButtonStyle;

  /// Theme of the one-time-code cells at rest.
  final PinTheme? defaultPinTheme;

  /// Theme of the focused one-time-code cell.
  final PinTheme? focusedPinTheme;

  /// Theme of a filled-in one-time-code cell.
  final PinTheme? submittedPinTheme;

  /// Theme of the one-time-code cells while showing an error.
  final PinTheme? errorPinTheme;

  /// Background of the success notification.
  final Color? successColor;

  /// Background of the error notification.
  final Color? errorColor;

  /// Background of the informational notification.
  final Color? infoColor;

  /// Background of the warning notification.
  final Color? warningColor;

  /// How long a move between screens takes.
  final Duration? pageTransitionDuration;

  /// The curve a move between screens follows.
  final Curve? pageTransitionCurve;

  /// Builds the transition between screens. Defaults to a cross-fade.
  final Widget Function(Widget child, Animation<double> animation)?
      pageTransitionBuilder;

  /// Creates a theme. Every property is optional; anything left null falls
  /// back to the package's [ColorScheme]-derived default.
  const AnimatedLoginTheme({
    this.cardColor,
    this.backgroundGradientStart,
    this.backgroundGradientEnd,
    this.cardRadius,
    this.fieldRadius,
    this.buttonRadius,
    this.cardPadding,
    this.fieldGap,
    this.maxCardWidth,
    this.cardShadow,
    this.titleStyle,
    this.subtitleStyle,
    this.buttonTextStyle,
    this.linkStyle,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.providerButtonStyle,
    this.defaultPinTheme,
    this.focusedPinTheme,
    this.submittedPinTheme,
    this.errorPinTheme,
    this.successColor,
    this.errorColor,
    this.infoColor,
    this.warningColor,
    this.pageTransitionDuration,
    this.pageTransitionCurve,
    this.pageTransitionBuilder,
  });

  /// A theme that overrides nothing.
  static const AnimatedLoginTheme fallback = AnimatedLoginTheme();

  /// The theme in effect for the nearest enclosing [FlutterAnimatedLogin].
  ///
  /// Resolution order: a theme passed to [FlutterAnimatedLogin.theme], then
  /// the one registered on [ThemeData.extensions], then [fallback].
  static AnimatedLoginTheme of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AnimatedLoginThemeScope>();
    if (scope != null) return scope.theme;
    return Theme.of(context).extension<AnimatedLoginTheme>() ?? fallback;
  }

  /// This theme with [other]'s non-null properties layered on top.
  AnimatedLoginTheme merge(AnimatedLoginTheme? other) {
    if (other == null) return this;
    return AnimatedLoginTheme(
      cardColor: other.cardColor ?? cardColor,
      backgroundGradientStart:
          other.backgroundGradientStart ?? backgroundGradientStart,
      backgroundGradientEnd:
          other.backgroundGradientEnd ?? backgroundGradientEnd,
      cardRadius: other.cardRadius ?? cardRadius,
      fieldRadius: other.fieldRadius ?? fieldRadius,
      buttonRadius: other.buttonRadius ?? buttonRadius,
      cardPadding: other.cardPadding ?? cardPadding,
      fieldGap: other.fieldGap ?? fieldGap,
      maxCardWidth: other.maxCardWidth ?? maxCardWidth,
      cardShadow: other.cardShadow ?? cardShadow,
      titleStyle: other.titleStyle ?? titleStyle,
      subtitleStyle: other.subtitleStyle ?? subtitleStyle,
      buttonTextStyle: other.buttonTextStyle ?? buttonTextStyle,
      linkStyle: other.linkStyle ?? linkStyle,
      primaryButtonStyle: other.primaryButtonStyle ?? primaryButtonStyle,
      secondaryButtonStyle: other.secondaryButtonStyle ?? secondaryButtonStyle,
      providerButtonStyle: other.providerButtonStyle ?? providerButtonStyle,
      defaultPinTheme: other.defaultPinTheme ?? defaultPinTheme,
      focusedPinTheme: other.focusedPinTheme ?? focusedPinTheme,
      submittedPinTheme: other.submittedPinTheme ?? submittedPinTheme,
      errorPinTheme: other.errorPinTheme ?? errorPinTheme,
      successColor: other.successColor ?? successColor,
      errorColor: other.errorColor ?? errorColor,
      infoColor: other.infoColor ?? infoColor,
      warningColor: other.warningColor ?? warningColor,
      pageTransitionDuration:
          other.pageTransitionDuration ?? pageTransitionDuration,
      pageTransitionCurve: other.pageTransitionCurve ?? pageTransitionCurve,
      pageTransitionBuilder:
          other.pageTransitionBuilder ?? pageTransitionBuilder,
    );
  }

  @override
  AnimatedLoginTheme copyWith({
    Color? cardColor,
    Color? backgroundGradientStart,
    Color? backgroundGradientEnd,
    BorderRadius? cardRadius,
    BorderRadius? fieldRadius,
    BorderRadius? buttonRadius,
    EdgeInsetsGeometry? cardPadding,
    double? fieldGap,
    double? maxCardWidth,
    List<BoxShadow>? cardShadow,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? buttonTextStyle,
    TextStyle? linkStyle,
    ButtonStyle? primaryButtonStyle,
    ButtonStyle? secondaryButtonStyle,
    ButtonStyle? providerButtonStyle,
    PinTheme? defaultPinTheme,
    PinTheme? focusedPinTheme,
    PinTheme? submittedPinTheme,
    PinTheme? errorPinTheme,
    Color? successColor,
    Color? errorColor,
    Color? infoColor,
    Color? warningColor,
    Duration? pageTransitionDuration,
    Curve? pageTransitionCurve,
    Widget Function(Widget, Animation<double>)? pageTransitionBuilder,
  }) {
    return AnimatedLoginTheme(
      cardColor: cardColor ?? this.cardColor,
      backgroundGradientStart:
          backgroundGradientStart ?? this.backgroundGradientStart,
      backgroundGradientEnd:
          backgroundGradientEnd ?? this.backgroundGradientEnd,
      cardRadius: cardRadius ?? this.cardRadius,
      fieldRadius: fieldRadius ?? this.fieldRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      fieldGap: fieldGap ?? this.fieldGap,
      maxCardWidth: maxCardWidth ?? this.maxCardWidth,
      cardShadow: cardShadow ?? this.cardShadow,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      primaryButtonStyle: primaryButtonStyle ?? this.primaryButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
      providerButtonStyle: providerButtonStyle ?? this.providerButtonStyle,
      defaultPinTheme: defaultPinTheme ?? this.defaultPinTheme,
      focusedPinTheme: focusedPinTheme ?? this.focusedPinTheme,
      submittedPinTheme: submittedPinTheme ?? this.submittedPinTheme,
      errorPinTheme: errorPinTheme ?? this.errorPinTheme,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      infoColor: infoColor ?? this.infoColor,
      warningColor: warningColor ?? this.warningColor,
      pageTransitionDuration:
          pageTransitionDuration ?? this.pageTransitionDuration,
      pageTransitionCurve: pageTransitionCurve ?? this.pageTransitionCurve,
      pageTransitionBuilder:
          pageTransitionBuilder ?? this.pageTransitionBuilder,
    );
  }

  @override
  AnimatedLoginTheme lerp(
    covariant ThemeExtension<AnimatedLoginTheme>? other,
    double t,
  ) {
    if (other is! AnimatedLoginTheme) return this;
    return AnimatedLoginTheme(
      cardColor: Color.lerp(cardColor, other.cardColor, t),
      backgroundGradientStart:
          Color.lerp(backgroundGradientStart, other.backgroundGradientStart, t),
      backgroundGradientEnd:
          Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t),
      cardRadius: BorderRadius.lerp(cardRadius, other.cardRadius, t),
      fieldRadius: BorderRadius.lerp(fieldRadius, other.fieldRadius, t),
      buttonRadius: BorderRadius.lerp(buttonRadius, other.buttonRadius, t),
      cardPadding: EdgeInsetsGeometry.lerp(cardPadding, other.cardPadding, t),
      fieldGap: _lerpDouble(fieldGap, other.fieldGap, t),
      maxCardWidth: _lerpDouble(maxCardWidth, other.maxCardWidth, t),
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t),
      buttonTextStyle:
          TextStyle.lerp(buttonTextStyle, other.buttonTextStyle, t),
      linkStyle: TextStyle.lerp(linkStyle, other.linkStyle, t),
      primaryButtonStyle:
          ButtonStyle.lerp(primaryButtonStyle, other.primaryButtonStyle, t),
      secondaryButtonStyle:
          ButtonStyle.lerp(secondaryButtonStyle, other.secondaryButtonStyle, t),
      providerButtonStyle:
          ButtonStyle.lerp(providerButtonStyle, other.providerButtonStyle, t),
      // PinTheme has no lerp; snap at the halfway point.
      defaultPinTheme: t < 0.5 ? defaultPinTheme : other.defaultPinTheme,
      focusedPinTheme: t < 0.5 ? focusedPinTheme : other.focusedPinTheme,
      submittedPinTheme: t < 0.5 ? submittedPinTheme : other.submittedPinTheme,
      errorPinTheme: t < 0.5 ? errorPinTheme : other.errorPinTheme,
      successColor: Color.lerp(successColor, other.successColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      pageTransitionDuration:
          t < 0.5 ? pageTransitionDuration : other.pageTransitionDuration,
      pageTransitionCurve:
          t < 0.5 ? pageTransitionCurve : other.pageTransitionCurve,
      pageTransitionBuilder:
          t < 0.5 ? pageTransitionBuilder : other.pageTransitionBuilder,
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return ((a ?? b!) * (1.0 - t)) + ((b ?? a!) * t);
  }
}

/// Carries the theme passed to [FlutterAnimatedLogin.theme] down to the
/// screens, so it wins over the one on [ThemeData] without the widget having
/// to rewrite the host's [ThemeData].
class AnimatedLoginThemeScope extends InheritedWidget {
  /// Makes [theme] the one [AnimatedLoginTheme.of] returns below this point.
  const AnimatedLoginThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  /// The theme in effect below this widget.
  final AnimatedLoginTheme theme;

  @override
  bool updateShouldNotify(AnimatedLoginThemeScope oldWidget) =>
      !identical(theme, oldWidget.theme);
}
