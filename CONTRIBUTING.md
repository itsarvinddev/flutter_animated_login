# Contributing to flutter_animated_login

Thanks for helping out. This is a pure-Dart Flutter package — no native code,
no plugins — so getting set up is just a clone and a `pub get`.

## Getting set up

```sh
git clone https://github.com/itsarvinddev/flutter_animated_login.git
cd flutter_animated_login
flutter pub get
```

The package declares **Flutter 3.27 / Dart 3.6** as its floor, and CI builds
against both that exact version and the current stable channel. If you use a
newer SDK locally, keep an eye on the floor leg of CI before assuming a red
build is unrelated to your change.

Run the demo app to see your change:

```sh
cd example
flutter run
```

## What CI will run

Run these before you push; they are exactly what
[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs.

```sh
dart format --output=none --set-exit-if-changed .   # default 80 columns
flutter analyze lib test                            # info-level lints are fatal
flutter test

cd example && flutter analyze && flutter test
```

Two things trip people up:

- **Format at the default 80 columns.** Do not pass `--line-length`. Plain
  `dart format .` is correct.
- **Analysis must be completely silent**, in the package and in the example.
  Info-level lints fail the build. If a demo genuinely needs to print, add a
  scoped `// ignore: avoid_print` rather than turning the rule off.

## How the package is laid out

```
lib/flutter_animated_login.dart   the public API — everything exported
lib/src/login.dart                FlutterAnimatedLogin, the entry widget
lib/src/controller.dart           FlutterAnimatedLoginController + LoginStep
lib/src/verify.dart               the one-time-code screen
lib/src/signup.dart               the sign-up screen
lib/src/reset_password.dart       the reset-password screen
lib/src/widget/                   the field and button widgets
lib/src/utils/                    configs, theme, messages, data classes
test/                             the test suite
example/                          the demo app deployed to GitHub Pages
```

Things worth knowing before you change behaviour:

- **State is per instance.** It lives on `FlutterAnimatedLoginController`, a
  `ChangeNotifier` handed down through `AnimatedLoginScope`. There are no
  module-level globals — two login widgets on screen at once must never see
  each other's state, and a popped-and-repushed screen must start on
  `LoginStep.login`. Please do not reintroduce shared state.
- **Ownership follows who created it.** `FlutterAnimatedLogin` disposes the
  controller it creates; a controller you pass in stays yours to dispose. The
  same rule applies to text controllers inside the controller.
- **Each screen owns its own `Form` and `GlobalKey<FormState>`**, wrapped in an
  `AutofillGroup`, and only the visible screen is built.
- **Every user-facing string belongs on `FormMessages`.** Never hard-code
  display text in a widget — that is what makes the package translatable.
- **Colours and shapes belong on `AnimatedLoginTheme`**, the package's
  `ThemeExtension`.

## Tests

Tests live in `test/`. A behaviour change needs a test; a bug fix needs one
that fails before the fix.

Prefer the stable keys the widgets already carry over matching on text, which
is localizable — for example the identity field:

```dart
find.byKey(const ValueKey<String>('flutter_animated_login.identity.email'))
find.byKey(const ValueKey<String>('flutter_animated_login.identity.phone'))
```

Those are two genuinely different widgets — a plain `TextFormField` in email
mode, an `IntlPhoneField` in phone mode — chosen by
`LoginConfig.loginFieldInputType`, and in `phoneOrEmail` by what the user
types. Tests that assume one widget for both will pass for the wrong reason.

## Commits and pull requests

- Branch off `main`; that is the default branch and the only one CI watches.
- Keep a pull request to one concern.
- Fill in the pull request template, including screenshots for visual changes
  and a note on any breaking change.
- Public API additions need doc comments — pub.dev scores the package on them,
  and CI gates the [pana](https://pub.dev/packages/pana) score so it cannot
  quietly regress.

## Reporting a bug

Open a [bug report](https://github.com/itsarvinddev/flutter_animated_login/issues/new?template=bug_report.yml)
and include the package version, the output of `flutter doctor -v`, the
platform, and a `main.dart` we can run in a fresh `flutter create` app. Without
a reproduction most reports stall.

## Releasing (maintainers)

1. Bump `version:` in `pubspec.yaml` and add a `CHANGELOG.md` entry.
2. Merge to `main`. CI runs the tests, `dart pub publish --dry-run` and pana.
3. Tag it: `git tag v1.2.3 && git push origin v1.2.3`.

[`publish.yml`](.github/workflows/publish.yml) checks the tag against
`pubspec.yaml` and publishes to pub.dev over OIDC — there is no pub.dev
credential stored in this repository. Pushing to `main` also redeploys the
[live demo](https://itsarvinddev.github.io/flutter_animated_login/).

## Licence

Contributions are accepted under the [MIT licence](LICENSE).
