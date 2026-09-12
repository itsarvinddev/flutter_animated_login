# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-12

The flow's state moved out of process-wide globals and into a per-instance
controller you can drive yourself, the email field became a real email field,
and every user-facing string became overridable. See
[MIGRATION.md](MIGRATION.md) for an upgrade guide — most apps need only a
dependency bump.

### Breaking

- **Minimum SDK is Dart 3.7 / Flutter 3.29.** The old floor of 3.10 could
  never have compiled: the package already called `Color.withValues`, which
  arrived in 3.27. 3.29 is where the rest of what it needs lands —
  `TextFormField.stylusHandwritingEnabled` (3.27 deprecated `scribbleEnabled`
  without shipping the replacement) and `TapRegionUpCallback`, which pinput 6
  uses and so requires despite declaring `">=3.7.0"` itself. A CI leg builds
  on exactly this floor so it cannot drift again.
- **`flutter_intl_phone_field` moved from 0.0.7 to 0.1.x**, and this package
  re-exports it. Its breaking changes reach you directly: `PhoneNumber` is
  immutable, `PhoneNumber.countryCode` always carries a leading `+`,
  `Country.dialCode` no longer contains the area code for +1 territories, 117
  territories' accepted number lengths were corrected against libphonenumber,
  and `CountryPickerDialog` was replaced by `showCountryPicker`. See that
  package's own
  [migration guide](https://github.com/itsarvinddev/flutter_intl_phone_field/blob/main/MIGRATION.md).
- **`pinput` moved from 5.x to 6.x**, also re-exported.
- **`signals` is no longer a dependency.** It backed five module-level globals
  and pulled in five transitive packages (`signals_core`, `signals_flutter`,
  `signals_hooks`, `preact_signals`, `flutter_hooks`) to hold four booleans,
  and its 7.x line requires Dart 3.5. Nothing in the public API exposed it, but
  it is no longer available transitively.
- **`SignupData.additionalSignupData` is non-nullable** (`Map<String, String>`,
  defaulting to `const {}`) and **no longer carries `confirmPassword`**. That
  value is a check on the form, not data your backend asked for; set
  `SignupConfig.includeConfirmPasswordInData: true` to get it back.
- **`SignupConfig.textFiledConfig`, `SignupConfig.passwordTextFiledConfig` and
  `ResetConfig.textFiledConfig` are now nullable** and default to `null`,
  meaning "reuse the login screen's". They were previously declared non-null
  and then unconditionally overwritten, so they could never take effect.
- **`EmailPhoneTextFiledConfig` default changes.** `style` was
  `TextStyle(fontSize: 16)` and is now `null` (inherit the theme); `textAlign`
  was `TextAlign.left` and is now `TextAlign.start`, which follows the ambient
  text direction; `invalidMessage` was `'Invalid Mobile Number'` and is now
  `null`, falling back to `FormMessages.invalidPhoneNumber`.
- **The screen widgets `FlutterAnimatedVerify`, `FlutterAnimatedSignup` and
  `FlutterAnimatedReset` take a `controller` instead of loose controllers and
  form keys.** They are internal to the flow; use `FlutterAnimatedLogin`.

### Fixed

- **The login flow no longer leaks state between instances or across
  navigations.** The page index, the identifier, the phone/email mode, the
  form-validity flag and the submit spinner were module-level `signal`s that
  no `dispose` ever reset. Pushing the login route, tapping through to the OTP
  screen and popping left the globals set, so the next push opened on the OTP
  screen — showing, and on resend re-texting, the *previous* user's phone
  number. Two login widgets alive at once shared one page index. All of this
  state is now per-instance, inside `FlutterAnimatedLoginController`.
- **Email sign-in works again.** The email field was an `IntlPhoneField` with
  its country selector hidden. Since flutter_intl_phone_field 0.1.0 reduces
  that field's value to digits, an email address came back as the empty
  string: the submit button never enabled, the validator reported "please
  enter a phone number" under a valid address, and a controller pre-seeded
  with an email was wiped on first build. Email mode is now a real
  `TextFormField`.
- **The signup and reset-password screens are reachable again.** Their only
  entry point rendered inside `if (!isLoginWithOTP)`, so with the default
  `LoginType.otp` no user could ever get to them, and there was no programmatic
  route either.
- **A custom `FormMessages` reaches every screen.** `LoginConfig.copyWith`
  silently dropped `messages` and `loginFieldInputType`, and the package calls
  `copyWith` internally on the signup and reset screens — so translations
  reverted to English exactly where they were passed through.
  `EmailPhoneTextFiledConfig.copyWith` likewise reset a custom `style` to
  `TextStyle(fontSize: 16)` on every call and discarded `searchText`.
- **The password reveal toggle stays where you put it.** Its `ValueNotifier`
  was constructed inside `build`, so the field snapped back to obscured on any
  rebuild — a window resize, a rotation, the Android keyboard opening — and
  leaked a notifier every time.
- **The submit button no longer enables with an empty password.** The
  identifier field overwrote the shared validity flag with a value computed
  from the identifier alone, clobbering the password requirement.
- **`PageConfig.colors` accepts any number of colours.** `GradientBox`
  hardcoded `stops: const [0, 1]`, so a list that was not exactly two colours
  long threw `ArgumentError` at paint time — in release builds too.
- **The signup screen honours `PageConfig`.** It required one and never used
  it, so the background, card decoration and padding reverted to defaults on
  that screen alone.
- **Pasting or autofilling an international phone number no longer corrupts
  it.** The field passed `inputFormatters: const []` rather than `null`, which
  replaced the phone field's entire default chain — country-detection on paste,
  digit filtering, the per-country length cap and as-you-type formatting.
  `+919876543210` could be submitted as `+91+919876543210`.
- **Configurable OTP lengths work.** `initState` hardcoded 6 in three places
  while the field honoured `OtpTextFiledConfig.length`, so a 4-digit code never
  auto-submitted and an 8-digit one was truncated to 6.
- **The one-time-code screen no longer leaks a `TapGestureRecognizer` per
  second.** `TitleWidget` allocated one in `build`, and that screen rebuilds
  once a second for its countdown.
- **No more crash after navigating away mid-verify.** The success path touched
  the controller and the `BuildContext` after `await` with no `mounted` guard.
- **Caller-supplied controllers are no longer disposed by the package.**
  Ownership is now explicit: a controller you pass in is yours to dispose, and
  only what the package created does it dispose.
- **The signup button can no longer double-submit.** Its loading flag was
  cleared in a `finally` but never set, so the spinner cancelled mid-request.
- **The package no longer nulls your `SignalsObserver`,** because it no longer
  uses signals at all. It used to set the app-wide observer to `null` in
  `initState` and never restore it, silently killing signals DevTools for the
  whole app.
- **The email validator accepts real addresses.** The old pattern
  (`[\w-]{2,4}` for the TLD) rejected plus-addressing, every TLD longer than
  four letters, and non-ASCII addresses, leaving the submit button disabled
  with no explanation.
- **Status messages no longer throw without a `ScaffoldMessenger`.** They use
  `maybeOf` and warn in debug instead.
- **`SignupData` compares by value.** Its `operator ==` compared the
  `additionalSignupData` maps by identity, so two payloads carrying the same
  entries were never equal.
- **`LoginData.toString()` and `SignupData.toString()` redact the secret.**
  Logging one used to print the password or the one-time code in clear.

### Added

- **`FlutterAnimatedLoginController`** — drive the flow from outside: `goTo`,
  `showOtp`, `reset`, `prefill`, `setBusy`, `clearOtp`, and read `step`,
  `identifier`, `isPhone`, `phoneNumber`, `isFormValid`. Optional: one is
  created and disposed internally when you pass none.
- **Extra signup fields** (GitHub
  [#8](https://github.com/itsarvinddev/flutter_animated_login/issues/8)) —
  `SignupConfig.additionalFields` takes a list of `SignupField`s, and
  `SignupConfig.customFields` takes builders for anything a text field cannot
  express. Values arrive in `SignupData.additionalSignupData`.
- **`LoginType.otpAndPassword` is now implemented.** It renders a password
  field plus a link that switches to the one-time-code path, and
  `LoginData.method` tells you which ran. It previously behaved exactly like
  `LoginType.otp`.
- **`PasswordPolicy`** with `minLength`, `maxLength`, character-class rules,
  `disallow` patterns and a `minStrength` bar, plus `PasswordPolicy.standard()`
  and `.strict()`. Composes with your own `validator` rather than replacing it.
- **Password strength meter, requirement checklist and caps-lock warning** —
  `PasswordTextFiledConfig.showStrengthMeter`, `showRequirementChecklist`,
  `showCapsLockHint` and `strengthBuilder`. Caps lock is read from
  `HardwareKeyboard`, so it needs no plugin.
- **`ConsentConfig`** — a checkbox that gates the submit button, reported back
  on `LoginData.acceptedTerms` and `SignupData.acceptedTerms`.
- **`AnimatedLoginTheme`**, a `ThemeExtension` — brand every screen in one
  place, including the page transition's duration, curve and builder. Per-config
  properties still win over it.
- **`ProviderLayout`** (`iconRow`, `iconWrap`, `fullWidthStacked`) and a richer
  `LoginProvider`: `iconWidget` for a brand mark, `button` for a fully custom
  button, `backgroundColor`, `foregroundColor` and `semanticLabel`. Apple's and
  Google's sign-in guidelines need a labelled full-width button with their own
  mark, which the icon-only API could not produce.
- **`LoginProvider.errorsToExcludeFromErrorMessage` and
  `providerNeedsSignUpCallback` now work.** Both were declared, documented and
  never read.
- **`FormMessages` covers every user-facing string** — it grew from 17 fields
  to 55, absorbing the 26 English literals that were hardcoded in the screens,
  and gained `copyWith` and a `fallback` constant.
- **Configurable OTP resend** — `VerifyConfig.resendCooldown` (was hardcoded to
  60 seconds), `startCooldownOnOpen`, `maxResendAttempts`, `countdownBuilder`,
  `onCooldownFinished` and `autoSubmitOnFill`.
- **Back-navigation handling** — the Android system back button and the browser
  back button return to the login screen from the OTP, signup and reset
  screens instead of leaving the flow. Opt out with
  `handleBackNavigation: false`.
- **`onStepChanged`** so the host can react to screen transitions.
- **`PageConfig.useScaffold`** — set false when `FlutterAnimatedLogin` already
  sits inside your own `Scaffold`, which is the common case and used to nest
  one inside another. Plus `useSafeArea`, `scrollPhysics`, `pageHeader` and
  `pageFooter`.
- **`LoginConfig.showSignupLink` / `showForgotLink`** to control the secondary
  links independently of the login type, and `providerLayout`,
  `providerSpacing` and `fieldGap`.
- **flutter_intl_phone_field 0.1.x capabilities are now reachable** through
  `EmailPhoneTextFiledConfig`: `favoriteCountries`, `onlyCountries`,
  `excludeCountries`, `formatInput`, `showExampleAsHint`,
  `detectCountryOnPaste`, `initialValueFormat`, `strictValidation`,
  `flagShape`, `flagSize`, `flagBuilder`, `dialCodeBuilder`,
  `countrySelectorBuilder`, `phoneController`, `showCountryCode`,
  `onTapOutside` and `restorationId`.
- **pinput 6 capabilities** — `OtpTextFiledConfig.onTapUpOutside`,
  `showErrorWhenFocused`, `enableInteractiveSelection` and `semanticLabel`.
- **`LoginData.method`, `LoginData.phoneNumber`, `LoginData.acceptedTerms`**,
  `copyWith` and `const` constructors on both data classes.
- **Accessibility** — semantic labels on the social buttons and the one-time-code
  field, tooltips on the password reveal toggle, 48×48 minimum touch targets,
  live regions on status messages and the countdown, and `AutofillGroup` around
  every form so password managers offer to save.
- **A test suite.** The package previously had none.

### Changed

- Every screen owns its own `Form` and `GlobalKey<FormState>`. One key used to
  wrap the whole switcher, so during a 300 ms page transition two screens'
  fields lived in the same `FormState`.
- Only the visible screen is built; all four used to be constructed on every
  frame.
- Buttons are full-width up to 400 logical pixels rather than pinned to half
  the viewport, and the secondary links and social buttons use `Wrap`, so
  neither overflows at large text scales.
- The default card shadow is a soft themed shadow rather than opaque black at a
  100-pixel blur.
- Status messages follow the theme instead of hardcoded `Colors.green.shade400`
  and friends.
- `PasswordTextFiledConfig.scribbleEnabled` is now
  `stylusHandwritingEnabled`, matching Flutter 3.29. The old name still works
  and is deprecated.

### Deprecated

Everything below still works and is scheduled for removal in 2.0.0:

- `FlutterAnimatedLogin.debug` — signals are gone, so there is no observer left
  to toggle. It does nothing.
- `LoginConfig.termsAndConditions` and `LoginConfig.privacyPolicy` (both
  `String?`) — never read. Use `FlutterAnimatedLogin.termsAndConditions`
  (a `Widget`) or `FlutterAnimatedLogin.consent`.
- `SignupConfig.resendButton` and `ResetConfig.resendButton` — neither screen
  has a resend button; the fields were copied from `VerifyConfig`.
- `EmailPhoneTextFiledConfig.searchText` — use `FormMessages.searchCountry`.
- `PasswordTextFiledConfig.scribbleEnabled` — use `stylusHandwritingEnabled`.

### Packaging

- **The published archive is roughly 600 KB instead of 31 MB.** A 32 MB demo
  video sat in the repository root with no `.pubignore`, so every consumer
  downloaded it on every `pub get`.
- `homepage`, `repository`, `issue_tracker` and `documentation` point at
  `itsarvinddev`, where the repository actually lives; the old `rvndsngwn` URLs
  404ed. Added `funding:`.
- CI now runs. It triggered on pushes to a `master` branch that does not exist,
  asserted 120-column formatting against 80-column code, and had its test step
  commented out.

## [0.0.15] - 2025

- dependencies updated

## [0.0.14] - 2025

- rename stylusHandwritingEnabled to scribbleEnabled for legacy support

## [0.0.13] - 2025

- dependencies updated
- initial values supported
- extra dependencies removed

## [0.0.12] - 2025

- dependencies updated
- SMS autofill on Android now requires adding `smart_auth` (or similar) to your
  own project — see
  [pinput's migration guide](https://github.com/Tkko/Flutter_PinPut/blob/master/MIGRATION.md)

## [0.0.11]

- `textInputAction` added for all text fields
- `onSubmitted` added for all text fields

## [0.0.10]

- state reset added for login and signup

## [0.0.9]

- signals disposed error fixed

## [0.0.8]

- fixed multiple widgets using the same `GlobalKey`

## [0.0.7]

- login with password added
- reset password screen added
- signup screen added

## [0.0.6]

- OTP verification handling added

## [0.0.5]

- `LoginData` class added for handling OTP functionality

## [0.0.4]

- title widget added with custom style

## [0.0.3]

- `PageConfig` added for customizing page layout and style
- `pinput` and `flutter_intl_phone_field` re-exported
