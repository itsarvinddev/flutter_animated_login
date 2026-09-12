import 'package:flutter/material.dart';

import 'theme.dart';

/// Formatting helpers for the one-time-code countdown.
extension IntExtinction on int {
  /// Zero-pads to two digits: `0 => "00"`, `1 => "01"`, `10 => "10"`.
  String get toDigital => this < 10 ? '0$this' : '$this';
}

/// Predicates used to tell an email address from a phone number.
extension StringExtinction on String? {
  /// Whether this is null or the empty string.
  bool get isEmptyOrNull {
    final value = this;
    return value == null || value.isEmpty;
  }

  /// Whether this is neither null nor empty.
  bool get isNotEmptyOrNull {
    final value = this;
    return value != null && value.isNotEmpty;
  }

  /// Alias for [isNotEmptyOrNull].
  bool get hasContent => isNotEmptyOrNull;

  /// This string, or the empty string when it is null.
  String get orEmpty => this ?? '';

  /// Whether this looks like an email address.
  ///
  /// Accepts plus-addressing (`user+tag@example.com`), long modern TLDs
  /// (`.technology`), subdomains, and non-ASCII local and domain parts
  /// (`bücher@münchen.de`). It deliberately stops short of RFC 5322: quoted
  /// local parts and bare-IP domains are rejected, because in a login field
  /// they are far more likely to be a typo than an address.
  bool get isEmail {
    final value = this?.trim();
    if (value == null || value.isEmpty) return false;
    // The longest address any mail server must accept.
    if (value.length > 254) return false;
    return _emailRegExp.hasMatch(value);
  }

  /// Whether this is a phone number that may carry a leading `+`.
  bool get isIntlPhoneNumber =>
      isNotEmptyOrNull && RegExp(r'^[+]?[0-9]{4,15}$').hasMatch(this!.trim());

  /// Whether this is a phone number with no country code.
  bool get isPhoneNumber =>
      isNotEmptyOrNull && RegExp(r'^[0-9]{4,15}$').hasMatch(this!.trim());

  /// Whether this looks like the beginning of a phone number.
  ///
  /// Looser than [isPhoneNumber]: it decides which *field* to show while the
  /// user is still typing, so a single leading digit is enough. Punctuation
  /// people paste with numbers — spaces, dashes, brackets — is allowed,
  /// including a bracketed area code in front of the number, as in
  /// `(555) 123-4567`.
  bool get looksLikePhone {
    final value = this?.trim();
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[+]?[(]?[0-9][0-9\s\-().]*$').hasMatch(value);
  }
}

final RegExp _emailRegExp = RegExp(
  r"^[\p{L}\p{N}.!#$%&'*+/=?^_`{|}~-]+"
  r'@'
  r'[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,61}[\p{L}\p{N}])?'
  r'(?:\.[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,61}[\p{L}\p{N}])?)+$',
  unicode: true,
);

/// Null-safe list predicates.
extension ArrayExtinction<T> on List<T>? {
  /// Whether this is neither null nor empty.
  bool get isNotEmptyOrNull {
    final value = this;
    return value != null && value.isNotEmpty;
  }

  /// Whether this is null or empty.
  bool get isEmptyOrNull {
    final value = this;
    return value == null || value.isEmpty;
  }
}

/// Null-safe widget helpers.
extension WidgetExtinction on Widget? {
  /// This widget, or a zero-sized box when it is null.
  Widget get orShrink => this ?? const SizedBox.shrink();

  /// Whether this widget was supplied.
  bool get isNotNull => this != null;

  /// Whether this widget is missing.
  bool get isNull => this == null;
}

/// Status notifications shown by the package.
///
/// Each looks up [AnimatedLoginTheme] for its colour and falls back to the
/// ambient [ColorScheme], so an app that brands the theme brands these too.
/// All four are no-ops when there is no [ScaffoldMessenger] above the widget,
/// rather than throwing.
extension Tost on BuildContext {
  /// Reports a successful action.
  void success(String title, {String? description}) => _show(
    title,
    description,
    AnimatedLoginTheme.of(this).successColor ??
        Theme.of(this).colorScheme.tertiaryContainer,
    Theme.of(this).colorScheme.onTertiaryContainer,
  );

  /// Reports a failed action.
  void error(String title, {String? description}) => _show(
    title,
    description,
    AnimatedLoginTheme.of(this).errorColor ??
        Theme.of(this).colorScheme.errorContainer,
    Theme.of(this).colorScheme.onErrorContainer,
  );

  /// Reports something neutral.
  void info(String title, {String? description}) => _show(
    title,
    description,
    AnimatedLoginTheme.of(this).infoColor ??
        Theme.of(this).colorScheme.secondaryContainer,
    Theme.of(this).colorScheme.onSecondaryContainer,
  );

  /// Reports something the user should look at but that did not fail.
  void warning(String title, {String? description}) => _show(
    title,
    description,
    AnimatedLoginTheme.of(this).warningColor ??
        Theme.of(this).colorScheme.tertiaryContainer,
    Theme.of(this).colorScheme.onTertiaryContainer,
  );

  void _show(
    String title,
    String? description,
    Color background,
    Color foreground,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) {
      assert(() {
        debugPrint(
          'flutter_animated_login: no ScaffoldMessenger above this widget, so '
          '"$title" was not shown. Wrap FlutterAnimatedLogin in a Scaffold or '
          'a ScaffoldMessenger to see status messages.',
        );
        return true;
      }());
      return;
    }
    final theme = Theme.of(this);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          backgroundColor: background,
          closeIconColor: foreground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
        ),
      );
  }
}

/// Cross-fades between the screens of the login flow.
class AnimatedStack extends StatelessWidget {
  /// Creates a switcher showing the child [builder] returns for [value].
  const AnimatedStack({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  });

  /// Which screen to show.
  final int value;

  /// Builds the screen for [value].
  final Widget Function(BuildContext context, int value) builder;

  /// How long the cross-fade takes.
  final Duration duration;

  /// The curve the incoming screen follows.
  final Curve switchInCurve;

  /// The curve the outgoing screen follows.
  final Curve switchOutCurve;

  /// Builds the transition between screens.
  final Widget Function(Widget child, Animation<double> animation)
  transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      // Keep the outgoing screen out of the semantics tree and out of the
      // enclosing Form while it fades away.
      layoutBuilder:
          (currentChild, previousChildren) => Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren.map(
                (child) => ExcludeFocus(
                  child: ExcludeSemantics(child: IgnorePointer(child: child)),
                ),
              ),
              if (currentChild != null) currentChild,
            ],
          ),
      child: KeyedSubtree(
        key: ValueKey<int>(value),
        child: builder(context, value),
      ),
    );
  }
}

/// A [TextEditingController] that remembers whether it has been disposed.
///
/// The package hands ownership of its controllers to
/// [FlutterAnimatedLoginController], which disposes only the ones it created —
/// so this flag is now a safety net rather than the mechanism. It stays public
/// because it appears in the configuration API.
class TextFieldController extends TextEditingController {
  /// Creates an empty controller.
  TextFieldController({super.text});

  /// Creates a controller from an existing [TextEditingValue].
  TextFieldController.fromValue(super.value) : super.fromValue();

  bool _isDisposed = false;

  /// Whether [dispose] has already run.
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
