# Flutter Animated Login

[![Pub Version](https://img.shields.io/pub/v/flutter_animated_login?color=blue&style=flat-square)](https://pub.dev/packages/flutter_animated_login)
[![Pub Points](https://img.shields.io/pub/points/flutter_animated_login?style=flat-square)](https://pub.dev/packages/flutter_animated_login/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/itsarvinddev/flutter_animated_login?color=gold&style=flat-square)](https://github.com/itsarvinddev/flutter_animated_login/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/itsarvinddev/flutter_animated_login?color=coral&style=flat-square)](https://github.com/itsarvinddev/flutter_animated_login/issues)

A complete, animated login flow in one widget: sign in with a one-time code or
a password, sign up, reset a password, and offer social providers — with a
country-picking phone field, full localization, and no native code on any
platform.

### [Live demo 🔗](https://itsarvinddev.github.io/flutter_animated_login/)

> **Upgrading from 0.0.x?** 1.0.0 fixes a state-leak that could show the
> previous user's phone number, and restores email sign-in. Most apps need only
> a version bump — see the [migration guide](MIGRATION.md).

## Features

- **Four screens, one widget** — login, one-time code, sign up and reset
  password, cross-faded with a configurable transition.
- **Any identifier** — phone only, email only, or both with the field switching
  as the user types. The phone field carries a searchable country picker with
  libphonenumber-accurate validation for 250+ countries.
- **Driveable from your code** — `FlutterAnimatedLoginController` lets you jump
  to the code screen, prefill from a deep link, or reset after a sign-out.
- **Custom signup fields** — declare extra text fields, or drop in any widget
  at all, and read the values back on submit.
- **Password quality** — a declarative `PasswordPolicy`, a strength meter, a
  live requirement checklist and a caps-lock warning.
- **Branded social login** — icon row, wrapping grid, or the full-width
  labelled buttons Apple's and Google's guidelines require.
- **Consent that actually gates** — an optional checkbox the submit button
  waits for.
- **Fully translatable** — every user-facing string lives on `FormMessages`.
- **Themeable in one place** — `AnimatedLoginTheme`, a `ThemeExtension`.
- **Accessible** — semantic labels, 48×48 touch targets, live-region status
  messages, `AutofillGroup` so password managers offer to save, and layouts
  that survive a 2× text scale.
- **No plugins** — pure Dart and Flutter, so it runs unchanged on Android, iOS,
  web, macOS, Windows and Linux.

## Platform support

| Android | iOS | Web | macOS | Windows | Linux |
| :-----: | :-: | :-: | :---: | :-----: | :---: |
|    ✅    |  ✅  |  ✅  |   ✅   |    ✅    |   ✅   |

No native code and no plugin dependencies, so there is nothing to configure per
platform.

**Requires Flutter 3.27 / Dart 3.6 or newer.** On older SDKs, use
`flutter_animated_login: 0.0.15`.

## Screenshots

### Email OTP

<table><tr>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-1.png" width="270" alt="Email login screen"></td>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-2.png" width="270" alt="One-time code screen"></td>
</tr></table>

### Phone OTP

<table><tr>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-3.png" width="270" alt="Phone login screen"></td>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-4.png" width="270" alt="Country picker"></td>
</tr></table>

### Dark theme

<table><tr>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-5.png" width="270" alt="Dark login screen"></td>
<td><img src="https://raw.githubusercontent.com/itsarvinddev/flutter_animated_login/main/image-6.png" width="270" alt="Dark one-time code screen"></td>
</tr></table>

## Install

```bash
flutter pub add flutter_animated_login
```

Or track the latest commit:

```yaml
dependencies:
  flutter_animated_login:
    git:
      url: https://github.com/itsarvinddev/flutter_animated_login.git
      ref: main
```

## Quick start

Every callback returns `null` (or an empty string) on success, or a message
describing the failure — which the package shows to the user for you.

```dart
import 'package:flutter_animated_login/flutter_animated_login.dart';

FlutterAnimatedLogin(
  onLogin: (data) async {
    // data.name is the email as typed, or the phone number in E.164 form.
    return await api.sendOtp(data.name);   // null == success
  },
  onVerify: (data) async {
    return await api.verifyOtp(data.name, data.secret!);
  },
)
```

That is the whole one-time-code flow. For a password flow, pass
`loginType: LoginType.password` and read `data.secret` as the password.

See [`example/`](example) for a runnable app covering every feature below.

## Recipes

### Drive the flow yourself

Useful when your backend, not the button, decides when to advance.

```dart
final controller = FlutterAnimatedLoginController();

FlutterAnimatedLogin(
  controller: controller,
  onLogin: (data) async {
    final error = await api.sendOtp(data.name);
    if (error != null) return error;
    controller.showOtp();          // advance only once the send succeeded
    return null;
  },
  onStepChanged: (step) => analytics.log('login_step', {'step': step.name}),
);

// Elsewhere:
controller.prefill(identifier: emailFromDeepLink);
controller.goTo(LoginStep.signup);
controller.reset();                // e.g. after sign-out
```

Dispose a controller you created; the package disposes only the one it makes
for you.

### Extra fields on the signup form

```dart
FlutterAnimatedLogin(
  onSignup: (data) async {
    final name = data.additionalSignupData['name'];
    final age = data.additionalSignupData['age'];
    return await api.register(data.name, data.password!, name, age);
  },
  signupConfig: SignupConfig(
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
  ),
)
```

### Require a decent password

```dart
LoginConfig(
  passwordConfig: PasswordTextFiledConfig(
    policy: const PasswordPolicy(
      minLength: 10,
      requireUppercase: true,
      requireDigit: true,
      minStrength: PasswordStrength.good,
    ),
    showStrengthMeter: true,
    showRequirementChecklist: true,
  ),
)
```

`PasswordPolicy.standard()` and `PasswordPolicy.strict()` are ready-made. The
policy composes with your own `validator` rather than replacing it.

### Branded social buttons

```dart
FlutterAnimatedLogin(
  loginConfig: const LoginConfig(
    providerLayout: ProviderLayout.fullWidthStacked,
  ),
  providers: [
    LoginProvider(
      iconWidget: Image.asset('assets/google.png', height: 20),
      label: const Text('Continue with Google'),
      semanticLabel: 'Sign in with Google',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      errorsToExcludeFromErrorMessage: const ['sign_in_canceled'],
      callback: () async => signInWithGoogle(),
    ),
    LoginProvider(
      icon: Icons.apple,
      label: const Text('Continue with Apple'),
      semanticLabel: 'Sign in with Apple',
      callback: () async => signInWithApple(),
    ),
  ],
)
```

### Consent before submit

```dart
FlutterAnimatedLogin(
  consent: ConsentConfig(
    isRequired: true,
    showOnSignup: true,
    label: Text.rich(TextSpan(children: [
      const TextSpan(text: 'I accept the '),
      TextSpan(
        text: 'terms of service',
        style: const TextStyle(decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()..onTap = openTerms,
      ),
    ])),
  ),
  onSignup: (data) async {
    assert(data.acceptedTerms);
    return null;
  },
)
```

### Translate it

Every string the package can render lives on `FormMessages`. Anything you omit
keeps its English default.

```dart
LoginConfig(
  messages: FormMessages(
    signIn: l10n.signIn,
    signUp: l10n.createAccount,
    password: l10n.password,
    otpSentToPhone: l10n.otpSentToPhone,
    invalidFormData: l10n.fixTheForm,
    // ...55 fields in total
  ),
)
```

### Brand it

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    extensions: const [
      AnimatedLoginTheme(
        cardRadius: BorderRadius.all(Radius.circular(28)),
        fieldRadius: BorderRadius.all(Radius.circular(12)),
        fieldGap: 20,
        maxCardWidth: 520,
        pageTransitionDuration: Duration(milliseconds: 400),
      ),
    ],
  ),
)
```

Resolution order for any property: a specific config field (say
`PageConfig.cardPadding`) beats `FlutterAnimatedLogin.theme`, which beats the
`AnimatedLoginTheme` on `ThemeData`, which beats the package's
`ColorScheme`-derived defaults.

### Inside your own Scaffold

```dart
Scaffold(
  appBar: AppBar(title: const Text('Sign in')),
  body: FlutterAnimatedLogin(
    config: const PageConfig(useScaffold: false),
  ),
)
```

### Tune the one-time-code screen

```dart
VerifyConfig(
  resendCooldown: const Duration(seconds: 30),   // match your rate limit
  maxResendAttempts: 3,
  textFiledConfig: const OtpTextFiledConfig(length: 4),
  countdownBuilder: (context, remaining) =>
      Text('Resend in ${remaining.inSeconds}s'),
)
```

### SMS autofill on Android

The package takes no SMS-reading dependency, so nothing is requested on your
users' behalf. Add [`smart_auth`](https://pub.dev/packages/smart_auth) yourself
and hand pinput a retriever:

```dart
VerifyConfig(
  textFiledConfig: OtpTextFiledConfig(smsRetriever: MySmsRetriever()),
)
```

## API overview

### `FlutterAnimatedLogin`

| Parameter | Type | What it does |
| --- | --- | --- |
| `onLogin` | `LoginCallback?` | Runs your sign-in |
| `onSignup` | `SignupCallback?` | Runs your account creation; supplying it shows the Sign Up link |
| `onVerify` | `VerifyCallback?` | Runs your one-time-code check |
| `onResendOtp` | `ResendOtpCallback?` | Sends another code |
| `onResetPassword` | `ResetPasswordCallback?` | Sends a reset link; supplying it shows the Forgot Password link |
| `controller` | `FlutterAnimatedLoginController?` | Drives the flow from outside |
| `loginType` | `LoginType` | `otp`, `password` or `otpAndPassword` |
| `loginConfig` | `LoginConfig` | The login screen, the strings, and the field configuration |
| `verifyConfig` | `VerifyConfig` | The one-time-code screen |
| `signupConfig` | `SignupConfig` | The signup screen, including extra fields |
| `resetConfig` | `ResetConfig` | The reset-password screen |
| `config` | `PageConfig` | The page: background, card, scaffold, safe area |
| `providers` | `List<LoginProvider>?` | Social sign-in options |
| `termsAndConditions` | `Widget?` | Terms text under the social buttons |
| `consent` | `ConsentConfig?` | A checkbox the submit button waits for |
| `theme` | `AnimatedLoginTheme?` | Branding; wins over the one on `ThemeData` |
| `onStepChanged` | `ValueChanged<LoginStep>?` | Fires when the visible screen changes |
| `handleBackNavigation` | `bool` | Whether system back returns to the login screen |

### `FlutterAnimatedLoginController`

`goTo(step)` · `showOtp({sentTo})` · `reset({clearFields})` ·
`prefill({identifier, countryIsoCode, password, additionalFields})` ·
`setBusy(bool)` · `clearOtp()` · `setAcceptedTerms(bool)` · `setUseOtp(bool)`

Readable: `step` · `identifier` · `phoneNumber` · `isPhone` · `isFormValid` ·
`isBusy` · `otpSentTo` · `resendAttempts` · `countryIsoCode` · the four text
controllers.

Full documentation for every type is on
[pub.dev](https://pub.dev/documentation/flutter_animated_login/latest/).

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
For anything large, open an issue first so we can agree the shape.

```bash
git clone https://github.com/itsarvinddev/flutter_animated_login.git
cd flutter_animated_login
flutter pub get
flutter test
```

## License

MIT — see [LICENSE](LICENSE).

## Support the project

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/rvndsngwn)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/rvndsngwn)
[![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/rvndsngwn)

## Contributors

<a href="https://github.com/itsarvinddev/flutter_animated_login/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=itsarvinddev/flutter_animated_login" alt="Contributors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
