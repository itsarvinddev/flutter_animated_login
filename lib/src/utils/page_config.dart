import 'package:flutter/material.dart';

/// Everything about the page each screen is drawn on: the background, the card
/// the form sits in, and how it behaves inside your own layout.
@immutable
class PageConfig {
  /// Padding inside the card.
  final EdgeInsetsGeometry? cardPadding;

  /// Margin around the card.
  final EdgeInsetsGeometry? cardMargin;

  /// Size limits for the card. Defaults to a maximum width of 600.
  final BoxConstraints? cardConstraints;

  /// Replaces the card's decoration entirely.
  final Decoration? cardDecoration;

  /// Where the background gradient starts.
  final AlignmentGeometry begin;

  /// Where the background gradient ends.
  final AlignmentGeometry end;

  /// The background gradient's colours.
  ///
  /// Any number of colours works; they are spaced evenly. Before 1.0.0 a list
  /// that was not exactly two colours long threw at paint time.
  final List<Color>? colors;

  /// Replaces the gradient with your own background.
  final Widget? background;

  /// What happens to the keyboard when the form is scrolled.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Whether each screen provides its own [Scaffold].
  ///
  /// Set false when [FlutterAnimatedLogin] is already inside your own
  /// `Scaffold` — the default `true` nests one inside another, which paints a
  /// second background and gives you two [ScaffoldMessenger]s.
  final bool useScaffold;

  /// Whether to inset the card away from notches, status bars and gesture
  /// bars.
  final bool useSafeArea;

  /// Fill colour of the [Scaffold], when [useScaffold] is set.
  final Color? scaffoldBackgroundColor;

  /// Scroll physics for the form.
  final ScrollPhysics? scrollPhysics;

  /// Rendered above the card, inside the page.
  final Widget? pageHeader;

  /// Rendered below the card, inside the page.
  final Widget? pageFooter;

  /// Creates the page's configuration.
  const PageConfig({
    this.cardPadding,
    this.cardMargin,
    this.cardConstraints,
    this.cardDecoration,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.colors,
    this.background,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.useScaffold = true,
    this.useSafeArea = true,
    this.scaffoldBackgroundColor,
    this.scrollPhysics,
    this.pageHeader,
    this.pageFooter,
  });

  /// A copy of this configuration with the given properties replaced.
  PageConfig copyWith({
    EdgeInsetsGeometry? cardPadding,
    EdgeInsetsGeometry? cardMargin,
    BoxConstraints? cardConstraints,
    Decoration? cardDecoration,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<Color>? colors,
    Widget? background,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    bool? useScaffold,
    bool? useSafeArea,
    Color? scaffoldBackgroundColor,
    ScrollPhysics? scrollPhysics,
    Widget? pageHeader,
    Widget? pageFooter,
  }) {
    return PageConfig(
      cardPadding: cardPadding ?? this.cardPadding,
      cardMargin: cardMargin ?? this.cardMargin,
      cardConstraints: cardConstraints ?? this.cardConstraints,
      cardDecoration: cardDecoration ?? this.cardDecoration,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      colors: colors ?? this.colors,
      background: background ?? this.background,
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? this.keyboardDismissBehavior,
      useScaffold: useScaffold ?? this.useScaffold,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      pageHeader: pageHeader ?? this.pageHeader,
      pageFooter: pageFooter ?? this.pageFooter,
    );
  }
}
