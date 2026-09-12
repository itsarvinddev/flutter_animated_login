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
}
