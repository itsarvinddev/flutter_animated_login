import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
// ChangeNotifier arrives via widgets.dart, which re-exports foundation, so
// importing foundation here as well is redundant -- the 3.29 analyzer says so.
//
// `internal`, though, only joined foundation's re-export list in Flutter 3.35,
// above this package's 3.29 floor, so it has to come straight from meta. On a
// newer SDK the analyzer calls *that* redundant instead. The two SDKs disagree
// about which of these imports is the unnecessary one; this arrangement plus
// the ignore is the only one clean on both.
// ignore: unnecessary_import
import 'package:meta/meta.dart' show internal;

import 'utils/extension.dart';

/// The screens [FlutterAnimatedLogin] can show.
enum LoginStep {
  /// Sign in with a one-time code or a password.
  login,

  /// Enter the one-time code that was just sent.
  verify,

  /// Create a new account.
  signup,

  /// Request a password-reset link.
  resetPassword,
}

/// Drives a [FlutterAnimatedLogin] from outside the widget.
///
/// Construct one, hand it to the widget, and dispose it with your own [State]:
///
/// ```dart
/// late final controller = FlutterAnimatedLoginController();
///
/// @override
/// void dispose() {
///   controller.dispose();
///   super.dispose();
/// }
///
/// @override
/// Widget build(BuildContext context) => FlutterAnimatedLogin(
///       controller: controller,
///       // Returning null advances to the code screen by itself; there is no
///       // need to call showOtp here. Return a message to stay put instead.
///       onLogin: (data) async => api.sendOtp(data.name),
///     );
///
/// // Elsewhere: react to things that happen outside the form.
/// void onDeepLink(String email) => controller.prefill(identifier: email);
/// void onSignedOut() => controller.reset();
/// ```
///
/// Reach for [showOtp] when a code was sent some other way — a magic link that
/// fell back to a code, or resuming a sign-in after the app was restarted.
///
/// Passing a controller is optional: [FlutterAnimatedLogin] creates and
/// disposes its own when you do not.
///
/// A controller you pass brings its own text controllers, so the `controller`
/// fields of [EmailPhoneTextFiledConfig], [PasswordTextFiledConfig] and
/// [OtpTextFiledConfig] are ignored. Hand yours to this constructor's
/// `identifierController`, `passwordController` and `otpController` instead.
///
/// The controller owns the flow's state — which screen is showing, what was
/// typed, whether a submit is in flight. Because it is per-instance, two
/// login widgets alive at the same time never share state, and a screen that
/// is popped and pushed again always starts on [LoginStep.login].
class FlutterAnimatedLoginController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// Supply [identifierController], [passwordController],
  /// [confirmPasswordController] or [otpController] to keep ownership of a
  /// text controller yourself — the controller then never disposes it. Any
  /// controller it creates itself, it disposes.
  FlutterAnimatedLoginController({
    LoginStep initialStep = LoginStep.login,
    String? initialIdentifier,
    String initialCountryCode = 'IN',
    TextEditingController? identifierController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? otpController,
  }) : _step = initialStep,
       _countryIsoCode = initialCountryCode,
       _initialCountryCode = initialCountryCode,
       _identifierController = identifierController ?? TextFieldController(),
       _passwordController = passwordController ?? TextFieldController(),
       _confirmPasswordController =
           confirmPasswordController ?? TextFieldController(),
       _otpController = otpController ?? TextFieldController(),
       _ownsIdentifier = identifierController == null,
       _ownsPassword = passwordController == null,
       _ownsConfirmPassword = confirmPasswordController == null,
       _ownsOtp = otpController == null {
    if (initialIdentifier != null) {
      _identifierController.text = initialIdentifier;
    }
    _syncFromIdentifierText();
    _identifierController.addListener(_onIdentifierChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  final TextEditingController _identifierController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;
  final TextEditingController _otpController;
  final bool _ownsIdentifier;
  final bool _ownsPassword;
  final bool _ownsConfirmPassword;
  final bool _ownsOtp;
  final Map<String, TextEditingController> _additionalControllers =
      <String, TextEditingController>{};
  final Map<String, String> _customValues = <String, String>{};

  LoginStep _step;
  String _countryIsoCode;
  final String _initialCountryCode;
  PhoneNumber? _phoneNumber;
  bool _isPhone = false;
  bool _isBusy = false;
  bool _acceptedTerms = false;
  bool _useOtp = false;
  bool _passwordRequired = false;
  bool _consentRequired = false;
  int _resendAttempts = 0;
  String? _otpSentTo;
  bool _disposed = false;

  // ------------------------------------------------------------------ state

  /// The screen currently showing.
  LoginStep get step => _step;

  /// Whether the identifier field is in phone mode rather than email mode.
  bool get isPhone => _isPhone;

  /// Whether a submit is in flight. Drives the primary button's spinner.
  bool get isBusy => _isBusy;

  /// Whether the consent checkbox is ticked.
  bool get acceptedTerms => _acceptedTerms;

  /// In [LoginType.otpAndPassword], whether the user chose the one-time-code
  /// path. Meaningless for the other login types.
  bool get useOtp => _useOtp;

  /// How many times the user has asked for a new one-time code on this screen.
  int get resendAttempts => _resendAttempts;

  /// ISO 3166-1 alpha-2 code of the country selected in the phone field.
  String get countryIsoCode => _countryIsoCode;

  /// The phone number currently entered, or `null` in email mode.
  PhoneNumber? get phoneNumber =>
      _phoneNumber ?? (_isPhone ? _parseTyped() : null);

  /// The identifier the callbacks receive: the email address as typed, or the
  /// phone number in E.164 form.
  String get identifier {
    final text = _identifierController.text.trim();
    if (!_isPhone) return text;
    final number = _phoneNumber;
    if (number != null && number.number.isNotEmpty) {
      return number.completeNumber;
    }
    // The phone field has not reported a number yet — right after prefill(),
    // for instance. Build E.164 from the selected country rather than handing
    // the callback a bare national number.
    return _e164From(text) ?? text;
  }

  /// E.164 for [text] using the selected country, or null when it cannot be
  /// built.
  String? _e164From(String text) {
    if (text.isEmpty) return null;
    if (text.startsWith('+')) return text.replaceAll(RegExp(r'[^+0-9]'), '');
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final country = CountryResolver.instance.byIsoCode(_countryIsoCode);
    if (country == null) return null;
    return '+${country.fullCountryCode}$digits';
  }

  /// Whether the phone number currently entered is usable.
  ///
  /// Falls back to a shape check on the raw text while the phone field has yet
  /// to report a [PhoneNumber] — otherwise a prefilled number left the submit
  /// button disabled until the user touched the field.
  bool get _isPhoneValid {
    final number = _phoneNumber;
    if (number != null && number.number.isNotEmpty) {
      return number.isValidNumber();
    }
    return _parseTyped()?.isValidNumber() ?? false;
  }

  /// The number in the field, parsed against the selected country, for the
  /// window before the phone field reports one.
  ///
  /// IntlPhoneField only reports a [PhoneNumber] when the user types. After
  /// [prefill], or with an initial value, the controller used to fall back to
  /// a bare-digits pattern — which rejected the brackets, spaces and dashes
  /// that `formatInput` adds, so a valid "(201) 555-0123" left the submit
  /// button disabled until the user touched the field.
  PhoneNumber? _parseTyped() {
    final text = _identifierController.text.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('+')) {
      final parsed = PhoneNumber.fromCompleteNumber(completeNumber: text);
      return parsed.countryISOCode.isEmpty ? null : parsed;
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final country = CountryResolver.instance.byIsoCode(_countryIsoCode);
    if (digits.isEmpty || country == null) return null;
    return PhoneNumber(
      countryISOCode: country.code,
      countryCode: '+${country.fullCountryCode}',
      number: digits,
    );
  }

  /// Where the one-time code was sent, shown on the verify screen. Falls back
  /// to [identifier].
  String get otpSentTo => _otpSentTo ?? identifier;

  /// Controls the email/phone field.
  TextEditingController get identifierController => _identifierController;

  /// Controls the password field.
  TextEditingController get passwordController => _passwordController;

  /// Controls the confirm-password field on the signup screen.
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  /// Controls the one-time-code field.
  TextEditingController get otpController => _otpController;

  /// Whether every field the current screen requires is filled in well enough
  /// to enable the primary button.
  bool get isFormValid {
    if (_consentRequired && !_acceptedTerms) return false;
    final identifierOk =
        _isPhone ? _isPhoneValid : _identifierController.text.trim().isEmail;
    if (!identifierOk) return false;
    if (_passwordRequired && _passwordController.text.isEmpty) return false;
    return true;
  }

  // ---------------------------------------------------------------- commands

  /// Shows [step].
  void goTo(LoginStep step) {
    if (_step == step) return;
    _step = step;
    _safeNotify();
  }

  /// Shows the verify screen, optionally overriding the destination shown in
  /// its subtitle. Resets the resend counter.
  void showOtp({String? sentTo}) {
    _otpSentTo = sentTo ?? identifier;
    _resendAttempts = 0;
    _otpController.clear();
    _step = LoginStep.verify;
    _safeNotify();
  }

  /// Returns to [LoginStep.login].
  ///
  /// When [clearFields] is true (the default) every field, the selected
  /// country and the consent checkbox go back to their initial values, so a
  /// shared device never shows the previous person's details.
  void reset({bool clearFields = true}) {
    _step = LoginStep.login;
    _resendAttempts = 0;
    _otpSentTo = null;
    _isBusy = false;
    if (clearFields) {
      _identifierController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _otpController.clear();
      for (final controller in _additionalControllers.values) {
        controller.clear();
      }
      _customValues.clear();
      _phoneNumber = null;
      _isPhone = false;
      _acceptedTerms = false;
      // Documented, but previously missing: without it the next person on a
      // shared device saw the previous user's country.
      _countryIsoCode = _initialCountryCode;
    }
    _safeNotify();
  }

  /// Fills the form in from outside — a deep link, a remembered session, or a
  /// test.
  void prefill({
    String? identifier,
    String? countryIsoCode,
    String? password,
    Map<String, String>? additionalFields,
  }) {
    if (identifier != null) {
      _identifierController.text = identifier;
      // The field reports a parsed number only as the user types; until it
      // does, phoneNumber and identifier are read from the new text.
      _phoneNumber = null;
    }
    if (countryIsoCode != null) _countryIsoCode = countryIsoCode;
    if (password != null) _passwordController.text = password;
    if (additionalFields != null) {
      for (final entry in additionalFields.entries) {
        additionalFieldController(entry.key).text = entry.value;
      }
    }
    _syncFromIdentifierText();
    _safeNotify();
  }

  /// Shows or hides the primary button's spinner.
  void setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    _safeNotify();
  }

  /// Clears the one-time-code field, for example after a rejected code.
  void clearOtp() {
    _otpController.clear();
    _safeNotify();
  }

  /// Ticks or unticks the consent checkbox.
  void setAcceptedTerms(bool value) {
    if (_acceptedTerms == value) return;
    _acceptedTerms = value;
    _safeNotify();
  }

  /// Switches between the one-time-code and password paths in
  /// [LoginType.otpAndPassword].
  void setUseOtp(bool value) {
    if (_useOtp == value) return;
    _useOtp = value;
    _safeNotify();
  }

  /// The controller backing the additional signup field named [key], creating
  /// it on first use. Disposed with this controller.
  TextEditingController additionalFieldController(String key) =>
      _additionalControllers.putIfAbsent(key, TextFieldController.new);

  /// The values of every additional signup field, ready for
  /// [SignupData.additionalSignupData].
  Map<String, String> get additionalFieldValues => <String, String>{
    for (final entry in _additionalControllers.entries)
      entry.key: entry.value.text,
    ..._customValues,
  };

  /// Records a value written by a [SignupFieldBuilder].
  void setCustomValue(String key, String value) {
    if (_customValues[key] == value) return;
    _customValues[key] = value;
    _safeNotify();
  }

  // ------------------------------------------------------------- internal

  /// Records the country and number reported by the phone field.
  @internal
  void updatePhoneNumber(PhoneNumber number) {
    _phoneNumber = number;
    if (number.countryISOCode.isNotEmpty) {
      _countryIsoCode = number.countryISOCode;
    }
    _safeNotify();
  }

  /// Switches the identifier field between phone and email mode.
  @internal
  void setIsPhone(bool value) {
    if (_isPhone == value) return;
    _isPhone = value;
    _safeNotify();
  }

  /// Tells the controller what the current screen requires, so [isFormValid]
  /// can answer for it.
  @internal
  void configure({
    required bool passwordRequired,
    required bool consentRequired,
  }) {
    if (_passwordRequired == passwordRequired &&
        _consentRequired == consentRequired) {
      return;
    }
    _passwordRequired = passwordRequired;
    _consentRequired = consentRequired;
    _safeNotify();
  }

  /// Counts a resend and returns the new total.
  @internal
  int recordResend() {
    _resendAttempts++;
    _safeNotify();
    return _resendAttempts;
  }

  void _onIdentifierChanged() {
    _syncFromIdentifierText();
    _safeNotify();
  }

  void _onPasswordChanged() => _safeNotify();

  /// Decides phone vs email mode from what is typed, for
  /// [LoginFieldInputType.phoneOrEmail]. A locked input type overrides this
  /// via [setIsPhone].
  void _syncFromIdentifierText() {
    final text = _identifierController.text.trim();
    // An emptied field goes back to email mode. Staying in phone mode trapped
    // the user: the phone field filters out letters, so after typing a digit
    // and deleting it, an email address could no longer be typed at all.
    if (text.isEmpty) {
      _isPhone = false;
      return;
    }
    final looksLikePhone = !text.contains('@') && text.looksLikePhone;
    if (looksLikePhone && !_isPhone && text.startsWith('+')) {
      // An international number typed key by key. Switching at "+4" mounted
      // the phone field on the old country with "4" as a national digit, so
      // "+447700900123" was sent as +14477009001. Stay in email mode until the
      // calling code and a first national digit are known, then select that
      // country; the field strips the code as it swaps.
      final parsed = PhoneNumber.fromCompleteNumber(completeNumber: text);
      if (parsed.countryISOCode.isEmpty || parsed.number.isEmpty) {
        _isPhone = false;
        return;
      }
      _countryIsoCode = parsed.countryISOCode;
    }
    _isPhone = looksLikePhone;
  }

  bool _notifyScheduled = false;

  void _safeNotify() {
    if (_disposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    // IntlPhoneField writes the shared text controller synchronously in its
    // own initState, which lands here mid-build. Marking an ancestor dirty
    // then throws, so coalesce those into a single post-frame notification.
    final duringBuild =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (!duringBuild) {
      notifyListeners();
      return;
    }
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (_disposed) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _identifierController.removeListener(_onIdentifierChanged);
    _passwordController.removeListener(_onPasswordChanged);
    if (_ownsIdentifier) _identifierController.dispose();
    if (_ownsPassword) _passwordController.dispose();
    if (_ownsConfirmPassword) _confirmPasswordController.dispose();
    if (_ownsOtp) _otpController.dispose();
    for (final controller in _additionalControllers.values) {
      controller.dispose();
    }
    _additionalControllers.clear();
    super.dispose();
  }
}

/// Makes the active [FlutterAnimatedLoginController] available to the screens
/// below it, and rebuilds them when it changes.
class AnimatedLoginScope
    extends InheritedNotifier<FlutterAnimatedLoginController> {
  /// Wraps [child] so it can reach [controller].
  const AnimatedLoginScope({
    super.key,
    required FlutterAnimatedLoginController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The controller driving the nearest enclosing [FlutterAnimatedLogin],
  /// subscribing the calling widget to its changes.
  static FlutterAnimatedLoginController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AnimatedLoginScope>();
    assert(
      scope != null,
      'No AnimatedLoginScope found. This widget must be placed inside a '
      'FlutterAnimatedLogin.',
    );
    return scope!.notifier!;
  }

  /// Like [of], but returns `null` outside a [FlutterAnimatedLogin] instead of
  /// asserting.
  static FlutterAnimatedLoginController? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AnimatedLoginScope>()
          ?.notifier;
}
