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
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? error(
    String title, {
    String? description,
  }) => _show(
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _show(
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
      return null;
    }
    final theme = Theme.of(this);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
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

/// Shows a screen's errors and dismisses the last one once that screen
/// succeeds.
///
/// Without this, entering a wrong code and then the right one left
/// "That code is incorrect" on screen over the app's home page for up to four
/// seconds. Only a SnackBar this tracker showed, and that is still open, is
/// dismissed: a message the app shows from its own callback is left alone.
class ScreenErrorSnackBar {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _current;
  bool _open = false;

  /// Shows [description] as an error.
  void show(BuildContext context, String title, {String? description}) {
    // Remove this tracker's previous error outright. Merely hiding it left the
    // new one queued behind its exit animation, so a success in that window
    // hid the old error again and the new one then slid in after sign-in.
    if (_open) ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    final controller = context.error(title, description: description);
    if (controller == null) return;
    _current = controller;
    _open = true;
    // Showing a second error hides the first, whose `closed` completes while
    // the second is still on screen; only the newest one may clear the flag.
    controller.closed.whenComplete(() {
      if (identical(_current, controller)) _open = false;
    });
  }

  /// Hides the error this tracker showed, if it is still on screen.
  ///
  /// Package errors are shown after hiding whatever was current and nothing
  /// the package shows is queued ahead of them, so while one is open it is
  /// the current SnackBar; anything the app showed later waits behind it.
  void dismiss(BuildContext context) {
    if (!_open) return;
    _open = false;
    _current = null;
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }
}

/// Runs [reset] after a successful sign-in, unless the host has already moved
/// on.
///
/// Hosts very often navigate to their home screen from inside onLogin or
/// onVerify. Resetting immediately made the outgoing screen cross-fade back to
/// an empty login form while the next route animated in. Declarative routers
/// (go_router's `context.go`, an auth redirect) only swap routes on a later
/// frame, so the check waits one frame and then skips the reset when this
/// route is no longer the current one.
void resetUnlessNavigatedAway(BuildContext context, VoidCallback reset) {
  WidgetsBinding.instance
    ..addPostFrameCallback((_) {
      if (!context.mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) return;
      reset();
    })
    // A post-frame callback waits for a frame but does not ask for one. After
    // a code is verified nothing else may: the keyboard is already closed and
    // the resend countdown may have finished, so the code screen stayed up
    // until something unrelated repainted.
    ..scheduleFrame();
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
      transitionBuilder: _recording(transitionBuilder),
      // Keep the outgoing screen out of focus, the semantics tree and hit
      // testing while it fades away.
      //
      // Every child gets the same wrapper types, keyed like the child, with
      // only the flags flipped. Wrapping just the outgoing screen changed the
      // widget type in its slot, so Flutter could not update it in place: the
      // whole screen was torn down and re-inflated mid-transition, re-running
      // every initState. IntlPhoneField writes the shared text controller in
      // its initState, which then notified the deactivated field it replaced
      // ("Looking up a deactivated widget's ancestor is unsafe").
      layoutBuilder:
          (currentChild, previousChildren) => Stack(
            alignment: Alignment.center,
            children: <Widget>[
              for (final child in _mostVisiblePerKey(
                previousChildren,
                currentChild,
              ))
                _shield(child, active: false),
              if (currentChild != null) _shield(currentChild, active: true),
            ],
          ),
      child: KeyedSubtree(
        key: ValueKey<int>(value),
        child: builder(context, value),
      ),
    );
  }

  /// Keeps one outgoing entry per key: the most visible one.
  ///
  /// Going login -> signup -> login -> signup within one transition leaves two
  /// outgoing login entries. AnimatedSwitcher only filters out entries keyed
  /// like the current child, and [_shield] keys its wrapper like the child, so
  /// the two gave the Stack duplicate keys ("Duplicate keys found") and every
  /// later frame threw. Every outgoing entry fades at the same rate, so the
  /// one with the highest animation value covers the other and outlasts it;
  /// keeping the newest instead let the older one reappear once the newer had
  /// faded out.
  static List<Widget> _mostVisiblePerKey(
    List<Widget> previous,
    Widget? current,
  ) {
    final currentKey = current?.key;
    final best = <Key, int>{};
    for (var i = 0; i < previous.length; i++) {
      final key = previous[i].key;
      if (key == null || key == currentKey) continue;
      final kept = best[key];
      if (kept == null ||
          _visibility(previous[i]) >= _visibility(previous[kept])) {
        best[key] = i;
      }
    }
    return <Widget>[
      for (var i = 0; i < previous.length; i++)
        if (previous[i].key == null ||
            (previous[i].key != currentKey && best[previous[i].key] == i))
          previous[i],
    ];
  }

  static final Expando<Animation<double>> _animationOf = Expando();
  static final Expando<Widget Function(Widget, Animation<double>)>
  _recordingBuilders = Expando();

  /// Wraps [builder] so each transition remembers its animation. Cached per
  /// builder, so AnimatedSwitcher sees the same function on every rebuild and
  /// does not rebuild its transitions.
  static Widget Function(Widget, Animation<double>) _recording(
    Widget Function(Widget, Animation<double>) builder,
  ) =>
      _recordingBuilders[builder] ??= (child, animation) {
        final transition = builder(child, animation);
        _animationOf[transition] = animation;
        return transition;
      };

  /// How visible an outgoing entry still is. AnimatedSwitcher hands the
  /// layout builder each transition wrapped in a [KeyedSubtree].
  static double _visibility(Widget entry) {
    final transition = entry is KeyedSubtree ? entry.child : entry;
    return _animationOf[transition]?.value ?? 0;
  }

  static Widget _shield(Widget child, {required bool active}) => ExcludeFocus(
    key: child.key,
    excluding: !active,
    child: ExcludeSemantics(
      excluding: !active,
      child: IgnorePointer(ignoring: !active, child: child),
    ),
  );
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
