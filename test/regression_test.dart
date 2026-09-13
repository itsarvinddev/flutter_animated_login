import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: child);

/// Cases that each pin a specific defect fixed in 1.0.0. Every one of these
/// failed, crashed or silently did the wrong thing in 0.0.15.
void main() {
  testWidgets('renders the login screen', (tester) async {
    await tester.pumpWidget(
      _app(
        FlutterAnimatedLogin(
          onLogin: (_) async => null,
          loginConfig: const LoginConfig(title: 'Hello', subtitle: 'Sign in'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('email typing does not throw and enables the button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(FlutterAnimatedLogin(onLogin: (_) async => null)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final button = tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(button.onPressed, isNotNull, reason: 'email should enable submit');
  });

  testWidgets('switching to phone mode does not throw (mid-build notify)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(FlutterAnimatedLogin(onLogin: (_) async => null)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('flutter_animated_login.identity.phone')),
      findsOneWidget,
    );
  });

  testWidgets(
    'signup and forgot links reachable with the default LoginType.otp',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FlutterAnimatedLogin(
            onLogin: (_) async => null,
            onSignup: (_) async => null,
            onResetPassword: (_) async => null,
            loginConfig: const LoginConfig(showForgotLink: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsWidgets);
    },
  );

  testWidgets('two instances do not share state', (tester) async {
    final a = FlutterAnimatedLoginController();
    final b = FlutterAnimatedLoginController();
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Expanded(
              child: FlutterAnimatedLogin(
                controller: a,
                onSignup: (_) async => null,
              ),
            ),
            Expanded(
              child: FlutterAnimatedLogin(
                controller: b,
                onSignup: (_) async => null,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    a.goTo(LoginStep.signup);
    await tester.pumpAndSettle();
    expect(a.step, LoginStep.signup);
    expect(b.step, LoginStep.login);
  });

  testWidgets('custom messages survive to the signup screen', (tester) async {
    await tester.pumpWidget(
      _app(
        FlutterAnimatedLogin(
          onSignup: (_) async => null,
          loginConfig: const LoginConfig(
            messages: FormMessages(
              signUp: 'ZZTOP-SIGNUP',
              signUpShort: 'ZZTOP-LINK',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ZZTOP-LINK'));
    await tester.pumpAndSettle();
    expect(find.text('ZZTOP-SIGNUP'), findsWidgets);
  });

  testWidgets('three gradient colours do not throw', (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 900,
          height: 900,
          child: FlutterAnimatedLogin(
            config: PageConfig(
              colors: [Colors.red, Colors.orange, Colors.yellow],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'prefill with a national number enables submit and yields E.164',
    (tester) async {
      final c = FlutterAnimatedLoginController(initialCountryCode: 'IN');
      addTearDown(c.dispose);
      String? seen;

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAnimatedLogin(
            controller: c,
            onLogin: (d) async {
              seen = d.name;
              return null;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      c.prefill(identifier: '9876543210');
      await tester.pumpAndSettle();

      expect(c.isPhone, isTrue);
      expect(
        c.isFormValid,
        isTrue,
        reason: 'prefilled number should enable submit',
      );

      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(seen, '+919876543210');
    },
  );

  testWidgets('a very tall signup form scrolls instead of overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 420);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onSignup: (_) async => null,
          signupConfig: SignupConfig(
            additionalFields: [
              for (var i = 0; i < 10; i++)
                SignupField(key: 'f$i', label: 'Field number $i'),
            ],
            customFields: [
              (context, values) => CheckboxListTile(
                title: const Text('Send me product news'),
                value: values['n'] == 'true',
                onChanged: (v) => values['n'] = '$v',
              ),
            ],
          ),
        ),
      ),
    );
    c.goTo(LoginStep.signup);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // And it must actually be scrollable to the bottom.
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Field number 9'), findsOneWidget);
  });

  testWidgets('focus survives the email-to-phone swap, so typing continues', (
    tester,
  ) async {
    // Found while capturing README screenshots: in the default phoneOrEmail
    // mode the first digit swapped the email field for the phone field, the
    // new field mounted unfocused, the keyboard closed, and every keystroke
    // after the first was dropped.
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(controller: c, onLogin: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('flutter_animated_login.identity.email')),
    );
    await tester.pumpAndSettle();
    tester.testTextInput.enterText('9');
    await tester.pumpAndSettle();

    final phone = find.byKey(
      const ValueKey('flutter_animated_login.identity.phone'),
    );
    expect(phone, findsOneWidget);
    final editable = tester.widget<EditableText>(
      find.descendant(of: phone, matching: find.byType(EditableText)),
    );
    expect(editable.focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue, reason: 'keyboard up');

    tester.testTextInput.enterText('98765');
    await tester.pumpAndSettle();
    expect(c.identifierController.text.replaceAll(RegExp(r'\D'), ''), '98765');
  });

  testWidgets('a prefilled, formatted phone number enables submit', (
    tester,
  ) async {
    // prefill() puts "(201) 555-0123" in the field with formatInput on, but
    // IntlPhoneField only reports a PhoneNumber on user input. The fallback
    // used a bare-digits pattern, so the button stayed disabled.
    final c = FlutterAnimatedLoginController(initialCountryCode: 'US');
    addTearDown(c.dispose);
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onLogin: (data) async {
            submitted = data.name;
            return null;
          },
          loginConfig: const LoginConfig(
            textFiledConfig: EmailPhoneTextFiledConfig(formatInput: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    c.prefill(identifier: '2015550123', countryIsoCode: 'US');
    await tester.pumpAndSettle();

    expect(c.identifierController.text, contains('('), reason: 'formatted');
    expect(c.isFormValid, isTrue);
    expect(c.phoneNumber?.completeNumber, '+12015550123');

    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(submitted, '+12015550123');
  });

  testWidgets('phone and email text read left-to-right in an RTL layout', (
    tester,
  ) async {
    // In Arabic the UAE number "50 123 4567" displayed as "4567 123 50": the
    // field inherited RTL and bidi reordered the space-separated groups.
    Future<TextDirection> directionOf(String key) async {
      final editable = find.descendant(
        of: find.byKey(ValueKey('flutter_animated_login.identity.$key')),
        matching: find.byType(EditableText),
      );
      final widget = tester.widget<EditableText>(editable);
      return widget.textDirection ??
          Directionality.of(tester.element(editable));
    }

    final c = FlutterAnimatedLoginController(initialCountryCode: 'AE');
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) =>
                Directionality(textDirection: TextDirection.rtl, child: child!),
        home: FlutterAnimatedLogin(controller: c, onLogin: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();
    expect(await directionOf('email'), TextDirection.ltr);

    c.prefill(identifier: '501234567', countryIsoCode: 'AE');
    await tester.pumpAndSettle();
    expect(await directionOf('phone'), TextDirection.ltr);
  });

  testWidgets('pasting a number with formatInput swaps fields without errors', (
    tester,
  ) async {
    // IntlPhoneField reformats the shared text in its initState, in the same
    // frame the email field is deactivated. That notified the dying field:
    // "Looking up a deactivated widget's ancestor is unsafe".
    final c = FlutterAnimatedLoginController(initialCountryCode: 'US');
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onLogin: (_) async => null,
          loginConfig: const LoginConfig(
            textFiledConfig: EmailPhoneTextFiledConfig(formatInput: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('flutter_animated_login.identity.email')),
    );
    await tester.pumpAndSettle();
    tester.testTextInput.enterText('2015550123');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('flutter_animated_login.identity.phone')),
      findsOneWidget,
    );
    expect(c.isFormValid, isTrue);
  });

  testWidgets('clearing a phone number returns to email mode', (tester) async {
    // The phone field filters out letters. When an emptied field stayed in
    // phone mode, typing a digit and deleting it made an email untypeable.
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(controller: c, onLogin: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    final email = find.byKey(
      const ValueKey('flutter_animated_login.identity.email'),
    );
    final phone = find.byKey(
      const ValueKey('flutter_animated_login.identity.phone'),
    );

    await tester.tap(email);
    await tester.pumpAndSettle();
    tester.testTextInput.enterText('9');
    await tester.pumpAndSettle();
    expect(phone, findsOneWidget);

    tester.testTextInput.enterText('');
    await tester.pumpAndSettle();
    expect(email, findsOneWidget, reason: 'back to the email field');
    expect(c.isPhone, isFalse);

    tester.testTextInput.enterText('ada@lovelace.dev');
    await tester.pumpAndSettle();
    expect(c.identifierController.text, 'ada@lovelace.dev');
    expect(c.isFormValid, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terms required only at sign-up do not block login', (
    tester,
  ) async {
    // Found by recording the README demo: login's submit checked
    // ConsentConfig.isRequired but not showOnLogin, so a sign-up-only consent
    // rejected every login with "Please accept the terms to continue" on a
    // screen that has no checkbox.
    LoginData? received;
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          onLogin: (data) async {
            received = data;
            return null;
          },
          consent: const ConsentConfig(
            label: Text('I accept the terms'),
            isRequired: true,
            showOnSignup: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('flutter_animated_login.identity.email')),
      'ada@lovelace.dev',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.text(const FormMessages().consentRequired), findsNothing);
    expect(received?.name, 'ada@lovelace.dev');
  });

  // Found by executing the go_router prompt: each step had its own Scaffold,
  // so navigating during the reset cross-fade drew the SnackBar under one Hero
  // tag twice and Flutter threw.
  testWidgets('navigating away while an error SnackBar shows does not crash', (
    tester,
  ) async {
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: FlutterAnimatedLogin(
          controller: c,
          onLogin: (_) async => null,
          onVerify: (data) async {
            if (data.secret != '123456') return 'Wrong code';
            // Like go_router's context.go or an auth redirect: the Navigator
            // changes a moment later, not inside this call.
            Future<void>.delayed(const Duration(milliseconds: 50), () {
              nav.currentState!.pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('HOME')),
                ),
              );
            });
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    c.prefill(identifier: 'ada@lovelace.dev');
    c.showOtp();
    await tester.pumpAndSettle();

    final pin = find.byType(EditableText).first;
    await tester.showKeyboard(pin);
    tester.testTextInput.enterText('000000'); // wrong -> error SnackBar
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Wrong code'), findsOneWidget);

    await tester.showKeyboard(find.byType(EditableText).first);
    tester.testTextInput.enterText('123456'); // right, SnackBar still up
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('HOME'), findsOneWidget);
  });

  test('reset() restores the initial country', () {
    final c = FlutterAnimatedLoginController(initialCountryCode: 'IN');
    addTearDown(c.dispose);
    c.prefill(identifier: '2015550123', countryIsoCode: 'US');
    c.reset();
    expect(c.countryIsoCode, 'IN');
  });

  testWidgets('AnimatedLoginTheme title styles reach every screen', (
    tester,
  ) async {
    // titleStyle and subtitleStyle only styled the login screen: the other
    // three passed textTheme styles explicitly, which beat the theme.
    const title = TextStyle(fontSize: 31, fontWeight: FontWeight.w800);
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onSignup: (_) async => null,
          onResetPassword: (_) async => null,
          theme: const AnimatedLoginTheme(titleStyle: title),
        ),
      ),
    );
    for (final step in [
      LoginStep.verify,
      LoginStep.signup,
      LoginStep.resetPassword,
    ]) {
      c.goTo(step);
      await tester.pumpAndSettle();
      final titleWidget = tester.widget<TitleWidget>(find.byType(TitleWidget));
      expect(titleWidget.titleStyle?.fontSize, 31, reason: step.name);
    }
  });

  test(
    'PasswordTextFiledConfig still accepts the deprecated scribbleEnabled',
    () {
      // Documented as deprecated, but the constructor parameter had been removed.
      // ignore: deprecated_member_use_from_same_package
      const config = PasswordTextFiledConfig(scribbleEnabled: false);
      expect(config.stylusHandwritingEnabled, isFalse);
    },
  );

  testWidgets('a branded provider keeps its colours while signing in', (
    tester,
  ) async {
    // The button is disabled while its callback runs; with no disabled colours
    // a branded button turned Material grey for the whole round trip.
    const brand = Color(0xFF131314);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          loginConfig: const LoginConfig(
            providerLayout: ProviderLayout.fullWidthStacked,
          ),
          providers: [
            LoginProvider(
              icon: Icons.abc,
              label: const Text('Continue with Brand'),
              backgroundColor: brand,
              foregroundColor: Colors.white,
              callback: () async {
                await Future<void>.delayed(const Duration(seconds: 1));
                return null;
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Brand'));
    await tester.pump(const Duration(milliseconds: 100));

    // The provider's own button is the FilledButton styled with the brand.
    // It cross-fades into its loading state, so take the incoming one: an
    // AnimatedSwitcher stacks the current child last.
    final button = tester
        .widgetList<FilledButton>(find.byType(FilledButton))
        .lastWhere(
          (b) => b.style?.backgroundColor?.resolve(<WidgetState>{}) == brand,
        );
    expect(button.onPressed, isNull, reason: 'disabled while loading');
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.disabled}),
      brand,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('onVerify receives the identifier, not showOtp sentTo label', (
    tester,
  ) async {
    // sentTo is a display label. It used to reach onVerify as LoginData.name,
    // so a formatted "+1 201-555-0123" replaced the E.164 number.
    final c = FlutterAnimatedLoginController(initialCountryCode: 'US');
    addTearDown(c.dispose);
    LoginData? verified;
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onVerify: (data) async {
            verified = data;
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    c.prefill(identifier: '2015550123', countryIsoCode: 'US');
    await tester.pumpAndSettle();
    c.showOtp(sentTo: '+1 201-555-0123');
    await tester.pumpAndSettle();

    // The label still titles the screen (next to its "Edit" link)...
    expect(
      find.textContaining('+1 201-555-0123', findRichText: true),
      findsOneWidget,
    );
    await tester.showKeyboard(find.byType(EditableText).first);
    tester.testTextInput.enterText('123456');
    await tester.pumpAndSettle();
    // ...but the callback gets the E.164 identifier.
    expect(verified?.name, '+12015550123');
  });

  testWidgets('OtpTextFieldConfig pin themes beat AnimatedLoginTheme', (
    tester,
  ) async {
    // The documented precedence is config, then theme. Focused, submitted and
    // error pin themes used the opposite order.
    const fromConfig = PinTheme(width: 41, height: 41);
    const fromTheme = PinTheme(width: 77, height: 77);
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          theme: const AnimatedLoginTheme(focusedPinTheme: fromTheme),
          verifyConfig: const VerifyConfig(
            textFiledConfig: OtpTextFieldConfig(focusedPinTheme: fromConfig),
          ),
        ),
      ),
    );
    c.prefill(identifier: 'ada@lovelace.dev');
    c.showOtp();
    await tester.pumpAndSettle();
    final pinput = tester.widget<Pinput>(find.byType(Pinput));
    expect(pinput.focusedPinTheme?.width, 41);
  });

  testWidgets('a custom signup switch redraws when tapped', (tester) async {
    // The builder's map was plain: writing to it rebuilt nothing, so the
    // documented switch pattern never redrew.
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onSignup: (_) async => null,
          signupConfig: SignupConfig(
            customFields: [
              (context, values) => SwitchListTile(
                title: const Text('News'),
                value: values['news'] == 'true',
                onChanged: (on) => values['news'] = '$on',
              ),
            ],
          ),
        ),
      ),
    );
    c.goTo(LoginStep.signup);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('News'));
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('no Resend button without onResendOtp', (tester) async {
    // It used to appear anyway and "succeed" without sending anything.
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          verifyConfig: const VerifyConfig(startCooldownOnOpen: false),
        ),
      ),
    );
    c.prefill(identifier: 'ada@lovelace.dev');
    c.showOtp();
    await tester.pumpAndSettle();
    expect(find.textContaining('Resend OTP'), findsNothing);
  });

  testWidgets('a successful code dismisses the earlier wrong-code error', (
    tester,
  ) async {
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onVerify:
              (data) async => data.secret == '123456' ? null : 'Wrong code',
        ),
      ),
    );
    c.prefill(identifier: 'ada@lovelace.dev');
    c.showOtp();
    await tester.pumpAndSettle();

    await tester.showKeyboard(find.byType(EditableText).first);
    tester.testTextInput.enterText('000000');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Wrong code'), findsOneWidget);

    await tester.showKeyboard(find.byType(EditableText).first);
    tester.testTextInput.enterText('123456');
    await tester.pumpAndSettle();
    expect(find.text('Wrong code'), findsNothing);
  });

  testWidgets('a message the app shows on success is left alone', (
    tester,
  ) async {
    // Only the package's own error is dismissed, never the app's SnackBar.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => FlutterAnimatedLogin(
                loginType: LoginType.password,
                onLogin: (data) async {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Welcome!')));
                  return null;
                },
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ada@lovelace.dev');
    await tester.enterText(fields.at(1), 'Analytical1843');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome!'), findsOneWidget);
  });

  testWidgets('reset() visibly restores the country in the picker', (
    tester,
  ) async {
    // The field preferred the config's country, so reset() restored the
    // controller's but the picker kept the one the user had chosen.
    final c = FlutterAnimatedLoginController(initialCountryCode: 'GB');
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          loginConfig: const LoginConfig(
            loginFieldInputType: LoginFieldInputType.phone,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('+44'), findsOneWidget);
    c.prefill(identifier: '2015550123', countryIsoCode: 'US');
    await tester.pumpAndSettle();
    expect(find.text('+1'), findsOneWidget);
    c.reset();
    await tester.pumpAndSettle();
    expect(find.text('+44'), findsOneWidget);
  });

  testWidgets('the code screen label reads left-to-right in RTL', (
    tester,
  ) async {
    final c = FlutterAnimatedLoginController(initialCountryCode: 'AE');
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) =>
                Directionality(textDirection: TextDirection.rtl, child: child!),
        home: FlutterAnimatedLogin(controller: c),
      ),
    );
    c.showOtp(sentTo: '+971501234567');
    await tester.pumpAndSettle();
    final subtitle = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((r) => r.text.toPlainText())
        .firstWhere((t) => t.contains('971'));
    expect(subtitle, contains('\u2066+971501234567\u2069'));
  });

  test('every visible phone-field string is on FormMessages', () {
    const m = FormMessages(
      noCountriesFound: 'a',
      favoriteCountries: 'b',
      countrySelectorLabel: 'c',
      digitsOnly: 'd',
      fieldRequired: 'Bitte {label} ausfüllen',
    );
    expect(m.fieldRequiredFor('Name'), 'Bitte Name ausfüllen');
    expect(m.copyWith(noCountriesFound: 'z').favoriteCountries, 'b');
  });

  testWidgets('onResendOtp receives acceptedTerms', (tester) async {
    final c = FlutterAnimatedLoginController();
    addTearDown(c.dispose);
    LoginData? resent;
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterAnimatedLogin(
          controller: c,
          onResendOtp: (data) async {
            resent = data;
            return null;
          },
          verifyConfig: const VerifyConfig(startCooldownOnOpen: false),
        ),
      ),
    );
    c.prefill(identifier: 'ada@lovelace.dev');
    c.setAcceptedTerms(true);
    c.showOtp();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend OTP'));
    await tester.pumpAndSettle();
    expect(resent?.acceptedTerms, isTrue);
  });
}
