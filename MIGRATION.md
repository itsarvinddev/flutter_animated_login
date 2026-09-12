# Migrating to 1.0.0

Most applications need one line changed — the version constraint — and nothing
else. The flow's public shape is unchanged: `FlutterAnimatedLogin` with
`onLogin`, `onVerify`, `onSignup` and `onResetPassword` still works exactly as
before.

This guide covers every breaking change. If your code is not doing one of these
things, it keeps compiling and behaving as it did.

## At a glance

| What changed | What to do |
| --- | --- |
| Minimum SDK is Dart 3.6 / Flutter 3.27 | Raise your own constraint, or stay on 0.0.15 |
| `flutter_intl_phone_field` moved 0.0.7 → 0.1.x | Read [its migration guide](https://github.com/itsarvinddev/flutter_intl_phone_field/blob/main/MIGRATION.md); most apps do nothing |
| `pinput` moved 5.x → 6.x | Nothing, unless you passed `enableInteractiveSelection` |
| `signals` is no longer a dependency | Depend on it directly if you were using it transitively |
| `SignupData.additionalSignupData` is non-nullable and drops `confirmPassword` | Remove the `?`; set `includeConfirmPasswordInData: true` if you need the value |
| `SignupConfig`/`ResetConfig` field configs are now nullable | Nothing, unless you *read* them |
| `EmailPhoneTextFiledConfig` default `style`, `textAlign`, `invalidMessage` changed | Pass them explicitly to keep the old look |
| The signup and reset links now appear for `LoginType.otp` | Nothing, or hide them with `showSignupLink` / `showForgotLink` |
| `LoginType.otpAndPassword` now really is dual-path | Handle `LoginData.method` |
| You disposed a controller you passed to the package | Keep doing it — the package no longer disposes it for you |
| `scribbleEnabled` → `stylusHandwritingEnabled` | Nothing; the old name is deprecated, not removed |

---

## Raise your SDK constraint

```yaml
environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.0"
```

**Why.** The package already called `Color.withValues`, which arrived in
Flutter 3.27, while declaring a floor of 3.10 — so the floor it advertised
could not actually compile. 3.27 is the truthful minimum, and it is what lets
the package use `stylusHandwritingEnabled` instead of the deprecated
`scribbleEnabled`.

If you are pinned below Flutter 3.27, stay on `flutter_animated_login: 0.0.15`.

---

## `flutter_intl_phone_field` 0.0.7 → 0.1.x

This package re-exports it, so its types are your types. The changes that can
reach you:

- `PhoneNumber` is immutable — use `copyWith` instead of assigning to a field.
- `PhoneNumber.countryCode` always carries a leading `+`, so drop any
  `'+' + phone.countryCode` concatenation of your own.
- `Country.dialCode` is the true calling code; the area code moved to
  `Country.regionCode` for +1 territories. Build numbers with
  `country.fullCountryCode` and display them with `country.displayCC`.
- 117 territories' accepted number lengths were corrected from libphonenumber,
  so a number that used to validate may now fail, and vice versa.
- `CountryPickerDialog` was replaced by `showCountryPicker`.

`LoginData.name` is unaffected: it was, and still is, the email address as
typed or the phone number in E.164 form. `LoginData` now also carries the
parsed `phoneNumber`, so you no longer have to re-parse `name` yourself.

Full detail is in that package's
[MIGRATION.md](https://github.com/itsarvinddev/flutter_intl_phone_field/blob/main/MIGRATION.md).

---

## `signals` is gone

**Why.** It backed five module-level globals — a page index, two booleans, the
typed identifier and a loading flag — and pulled `signals_core`,
`signals_flutter`, `signals_hooks`, `preact_signals` and `flutter_hooks` into
every consumer's resolution to do it. Its 7.x line also requires Dart 3.5.
Those globals were themselves the package's worst bug (see below), so removing
the dependency and fixing the bug were the same change.

Nothing in the public API ever exposed a `Signal`. If your app used `signals`
because this package happened to provide it, declare it yourself:

```yaml
dependencies:
  signals: ^7.1.0
```

---

## State is per-instance now

**Why.** The page index, the identifier, the phone/email mode, the
form-validity flag and the submit spinner were top-level `signal`s in the
package's own library. No `dispose` reset them, so:

- pushing the login route, tapping through to the one-time-code screen, and
  popping left the page index at 1 — the next push opened on the OTP screen,
  showing the previous user's phone number in its subtitle and, on "Resend
  OTP", texting a fresh code to it;
- two `FlutterAnimatedLogin` widgets alive at once shared one page index, so
  tapping "Sign Up" in a login card inside a dialog also flipped the screen
  behind it.

There is nothing to migrate — the fix is internal — but the replacement is
public, and it is the feature most people were asking for:

```dart
class _MyLoginState extends State<MyLogin> {
  final controller = FlutterAnimatedLoginController();

  @override
  void dispose() {
    controller.dispose();     // yours to create, yours to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FlutterAnimatedLogin(
        controller: controller,
        onLogin: (data) async {
          final error = await api.sendOtp(data.name);
          if (error != null) return error;
          controller.showOtp();      // advance once *your* send succeeded
          return null;
        },
      );
}
```

`controller.goTo(LoginStep.signup)`, `controller.reset()`,
`controller.prefill(identifier: deepLinkEmail)` and `controller.step` are all
available. Passing a controller stays optional — one is created and disposed
internally when you do not.

---

## Controller ownership changed

**Before**, the widget disposed every text controller it touched, including
ones you created and were told to dispose yourself. Disposing it on your side
too — as the documentation said to — threw on the second mount.

**Now** the rule is the usual Flutter one: *whoever created it, disposes it.*

```dart
// You create it -> you dispose it. The package will not.
final emailController = TextFieldController();

FlutterAnimatedLogin(
  loginConfig: LoginConfig(
    textFiledConfig: EmailPhoneTextFiledConfig(controller: emailController),
  ),
)
```

If you were relying on the package to dispose your controller, dispose it
yourself now. If you were skipping disposal because of the old crash, you can
stop skipping it.

---

## The email field is a real email field

**Why.** Email mode used to be an `IntlPhoneField` with its country selector
hidden. flutter_intl_phone_field 0.1.0 reduces that field's value to digits, so
an email address came back as the empty string: the submit button never
enabled, the validator reported "please enter a phone number" under a valid
address, and a controller pre-seeded with an email was wiped on first build.

Email mode is now a plain `TextFormField` and phone mode is an
`IntlPhoneField`. Two consequences for you:

- **`EmailPhoneTextFiledConfig.onChanged` and `onSaved` get `number: null` in
  email mode**, and `value` is the raw text. In phone mode `number` is the
  parsed `PhoneNumber` and `value` is its national part. Previously `number`
  was always non-null and, for an email, meaningless.
- **`emailDecoration`** lets you decorate the email field separately from the
  phone field; `decoration` still applies to both.

```dart
EmailPhoneTextFiledConfig(
  onChanged: (v) {
    if (v.number != null) {
      // phone mode
    } else {
      // email mode: v.value is what was typed
    }
  },
)
```

---

## `SignupData.additionalSignupData`

**Before:** `Map<String, String>?`, always containing exactly one entry —
`confirmPassword`.

**Now:** `Map<String, String>`, defaulting to `const {}`, containing whatever
your extra fields collected and *not* the confirm-password value. A password
confirmation is a check on the form, not something your backend asked for.

```dart
// Before
final confirm = data.additionalSignupData?['confirmPassword'];

// After — if you genuinely need it
SignupConfig(includeConfirmPasswordInData: true)
```

Drop the `?` from any null-aware access; the map is never null now.

---

## Extra signup fields (issue #8)

New, and the reason many people forked. Declarative fields:

```dart
SignupConfig(
  additionalFields: [
    SignupField(key: 'name', label: 'Full name', isRequired: true),
    SignupField(
      key: 'age',
      label: 'Age',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    ),
  ],
  // Anything a text field cannot express:
  customFields: [
    (context, values) => CheckboxListTile(
          title: const Text('Send me product news'),
          value: values['newsletter'] == 'true',
          onChanged: (v) => values['newsletter'] = '$v',
        ),
  ],
)
```

Values arrive in `SignupData.additionalSignupData`, keyed by
`SignupField.key`.

---

## Config objects that now default to `null`

`SignupConfig.textFiledConfig`, `SignupConfig.passwordTextFiledConfig` and
`ResetConfig.textFiledConfig` were declared non-null with defaults — and then
unconditionally overwritten by the login screen's configuration, so setting
them did nothing. They are nullable now, and `null` means "reuse the login
screen's", which is what actually happened before.

Setting them now works. Reading them may give you `null`:

```dart
// Before: always non-null, and ignored.
final c = signupConfig.textFiledConfig;

// After: null means "inherit from LoginConfig".
final c = signupConfig.textFiledConfig ?? loginConfig.textFiledConfig;
```

---

## Changed defaults on `EmailPhoneTextFiledConfig`

| Property | Before | Now | Why |
| --- | --- | --- | --- |
| `style` | `TextStyle(fontSize: 16)` | `null` | Inherits your theme. The old default also leaked through `copyWith`, which reset any custom style on every call — including the package's own internal calls. |
| `textAlign` | `TextAlign.left` | `TextAlign.start` | `left` forced LTR alignment in Arabic, Hebrew and Farsi layouts. |
| `invalidMessage` | `'Invalid Mobile Number'` | `null` | Falls back to `FormMessages.invalidPhoneNumber`, so it is translatable. |

Pass them explicitly to keep the old behaviour:

```dart
EmailPhoneTextFiledConfig(
  style: const TextStyle(fontSize: 16),
  textAlign: TextAlign.left,
  invalidMessage: 'Invalid Mobile Number',
)
```

---

## The signup and "forgot password" links now appear for `LoginType.otp`

**Why.** The link row rendered inside `if (!isLoginWithOTP)`, and
`isLoginWithOTP` is true for the default `LoginType.otp`. So an app that passed
`onSignup` and `onResetPassword` got two screens that no user could reach and
no API could open.

They now appear whenever the matching callback is supplied. To keep the old
(empty) look:

```dart
LoginConfig(showSignupLink: false, showForgotLink: false)
```

---

## `LoginType.otpAndPassword` behaves differently

It used to be identical to `LoginType.otp` — no password field, no choice, and
no advance to the verify screen. It now renders a password field plus a link
that switches to the one-time-code path.

Read `LoginData.method` to tell them apart:

```dart
onLogin: (data) async => switch (data.method) {
  LoginMethod.otp => api.sendOtp(data.name),
  LoginMethod.password => api.signIn(data.name, data.secret!),
  LoginMethod.provider => null,
},
```

If you were using `otpAndPassword` and want the old behaviour, switch to
`LoginType.otp`.

---

## `PageConfig.useScaffold`

Each screen provides its own `Scaffold`. If `FlutterAnimatedLogin` already sits
inside yours — which the package's own example did — you had two, which paints
a second background and shadows your `ScaffoldMessenger`.

```dart
Scaffold(
  body: FlutterAnimatedLogin(
    config: const PageConfig(useScaffold: false),   // <- add this
  ),
)
```

The default is still `true`, so nothing changes unless you opt in.

---

## Deprecated, not removed

These still compile and behave as before. They will go in 2.0.0.

| Deprecated | Replacement |
| --- | --- |
| `FlutterAnimatedLogin.debug` | Nothing — signals are gone, so it toggles nothing |
| `LoginConfig.termsAndConditions` (`String?`) | `FlutterAnimatedLogin.termsAndConditions` (a `Widget`) or `FlutterAnimatedLogin.consent` |
| `LoginConfig.privacyPolicy` (`String?`) | As above |
| `SignupConfig.resendButton`, `ResetConfig.resendButton` | Nothing — neither screen has a resend button |
| `EmailPhoneTextFiledConfig.searchText` | `FormMessages.searchCountry` |
| `PasswordTextFiledConfig.scribbleEnabled` | `PasswordTextFiledConfig.stylusHandwritingEnabled` |

---

## Things you may now want to adopt

None of these are required.

- **Translate everything.** `FormMessages` grew from 17 fields to 55, absorbing
  the 26 English strings that were hardcoded in the screens. A custom
  `FormMessages` now also survives to the signup and reset screens, which it
  did not before.
- **Enforce a password policy** with `PasswordPolicy.standard()` or
  `.strict()`, and show `showStrengthMeter` / `showRequirementChecklist` /
  `showCapsLockHint`.
- **Gate submission on consent** with `ConsentConfig(isRequired: true)`.
- **Brand everything in one place** with `AnimatedLoginTheme`, a
  `ThemeExtension`.
- **Ship compliant social buttons** with `ProviderLayout.fullWidthStacked`,
  `LoginProvider.iconWidget` and `semanticLabel`.
- **Match your backend's rate limit** with `VerifyConfig.resendCooldown` and
  `maxResendAttempts`, instead of the hardcoded 60 seconds.
