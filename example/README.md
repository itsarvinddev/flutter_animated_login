# flutter_animated_login — demo gallery

A runnable tour of [`flutter_animated_login`](https://pub.dev/packages/flutter_animated_login).
Each entry on the home screen pushes its own route and shows one part of the
API, wired to a fake backend so every success *and* every failure path is
visible without a server.

## Run it

```sh
cd example
flutter pub get
flutter run          # any device: iOS, Android, web, macOS, Windows, Linux
```

Checks:

```sh
flutter analyze
flutter test
```

The example depends on the package by path (`flutter_animated_login: {path: ../}`),
so edits to `../lib` show up on a hot restart.

## The fake backend

`lib/fake_auth.dart` stands in for your API. Every call waits 900 ms first, so
the demos exercise the real spinner, disabled-button and error paths. It
accepts exactly one account:

| | |
|---|---|
| phone | `+91 98765 43210` |
| email | `demo@example.com` |
| one-time code | `123456` |
| password | `flutter1234` |

Anything else is rejected with a message, which the package shows for you.
Nothing is ever printed to the console: results land in the panel at the bottom
of every demo (`lib/demo_page.dart`).

## The demos

| Demo | What it shows |
|---|---|
| **One-time code** | `LoginType.otp` end to end: `onLogin` sends a code, the package moves to the verify screen, `onVerify` checks it. `onResendOtp` plus `VerifyConfig.resendCooldown`, `maxResendAttempts`, `countdownBuilder` and `autoSubmitOnFill`. The identifier field switches itself between a country-picker phone field and a plain email field as you type (`LoginFieldInputType.phoneOrEmail`). |
| **Password** | `LoginType.password` sign-in, and a signup screen under `PasswordPolicy.standard()` with `showStrengthMeter` and `showRequirementChecklist`. The login screen deliberately keeps `PasswordPolicy.none`: rules belong where a password is *chosen*, not where an existing one is typed back in. |
| **Sign up with extra fields** | Two `SignupField`s — a required "Full name" and an "Age" with a digits-only formatter and its own validator — plus a `SignupConfig.customFields` checkbox. The resulting `SignupData` is printed into the result panel, password already redacted. Starts on `LoginStep.signup` through a controller. |
| **Reset password** | `onResetPassword`, `ResetConfig` and `returnToLoginOnSuccess`. Starts on `LoginStep.resetPassword`. |
| **Social providers** | `ProviderLayout.fullWidthStacked` with branded colours, a `semanticLabel` on every button so screen readers announce something useful, and `errorsToExcludeFromErrorMessage` for results that are cancellations rather than errors. Google and Apple succeed; GitHub fails on purpose. |
| **Programmatic control** | Buttons that call `prefill()`, `showOtp()` and `reset()` on a `FlutterAnimatedLoginController` you own, with `onStepChanged` reporting where the flow ended up. |
| **Theming** | One `AnimatedLoginTheme` — gradient, card and field radii, spacing, text styles, notification colours, page-transition duration and curve — passed to `FlutterAnimatedLogin.theme`. Use the app-bar toggle to see it in light and dark. |
| **Localization** | A `FormMessages` in Spanish covering every user-facing string. The package ships English defaults and takes no localization dependency, so anything you leave out stays English. |

The light/dark toggle in the app bar is on every screen, because a login theme
has to look right in both.

## Reading order

| File | |
|---|---|
| `lib/main.dart` | the app, the demo list and the home screen |
| `lib/fake_auth.dart` | the stand-in backend |
| `lib/demo_page.dart` | the shared frame and the result panel |
| `lib/theme_mode_scope.dart` | the light/dark toggle |
| `lib/demos/*.dart` | one file per demo — start with `otp_demo.dart` |

Every demo passes `PageConfig(useScaffold: false)`, because the page it sits in
already has a `Scaffold`. Left at its default `true` the package supplies one
for you.

## Tests

`test/widget_test.dart` pumps the gallery on a phone-sized surface, opens a
demo and drives it: the one-time-code demo is taken through a complete round
trip against `FakeAuth`, and the signup demo is checked for its additional and
custom fields.
