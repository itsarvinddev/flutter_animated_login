import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

/// Key of the email branch of the identity field.
const Key _emailFieldKey =
    ValueKey<String>('flutter_animated_login.identity.email');

/// The subtitle the signup screen shows with the default [FormMessages].
const String _signupSubtitle = 'Create an account to get started with our app.';

/// Pumps [login] inside a [MaterialApp] on a surface tall enough for the whole
/// form to be laid out and tappable.
Future<void> _pump(WidgetTester tester, Widget login) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: login));
  await tester.pumpAndSettle();
}

/// The Material button whose label is [label], whatever its variant.
Finder _buttonWithText(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );

/// Whether the button labelled [label] accepts taps.
bool _enabled(WidgetTester tester, String label) {
  final finder = _buttonWithText(label);
  expect(finder, findsOneWidget);
  return tester.widget<ButtonStyleButton>(finder).onPressed != null;
}

/// The text field whose decoration carries [label].
Finder _fieldWithLabel(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextFormField));

void main() {
  group('login screen', () {
    testWidgets('renders the title, the identity field and the button',
        (tester) async {
      await _pump(
        tester,
        const FlutterAnimatedLogin(
          loginConfig: LoginConfig(title: 'Welcome back'),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byKey(_emailFieldKey), findsOneWidget);
      expect(_buttonWithText('Continue'), findsOneWidget);
    });

    // Before 1.0.0 the secondary link row rendered only in password mode, so
    // for the default LoginType.otp both screens were unreachable.
    testWidgets('otp login reaches the signup and reset screens by link',
        (tester) async {
      await _pump(
        tester,
        FlutterAnimatedLogin(
          onSignup: (_) async => null,
          onResetPassword: (_) async => null,
          // The forgot-password link is opt-in for LoginType.otp; see
          // bugsFoundInLib. The signup link needs no flag.
          loginConfig: const LoginConfig(showForgotLink: true),
        ),
      );

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text(_signupSubtitle), findsOneWidget);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.byKey(_emailFieldKey), findsOneWidget);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Account Password'), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    });

    // Before 1.0.0 LoginConfig.copyWith dropped `messages`, so a translated
    // form reverted to English the moment it left the login screen.
    testWidgets('custom messages reach the signup and reset screens',
        (tester) async {
      const messages = FormMessages(
        signIn: 'ZZ sign in',
        signUp: 'ZZ create account',
        signUpShort: 'ZZ sign up',
        createAccountLong: 'ZZ create account long',
        forgotPassword: 'ZZ forgot password',
        resetTitle: 'ZZ reset title',
        resetSubtitle: 'ZZ reset subtitle',
        resetButton: 'ZZ reset button',
      );
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        FlutterAnimatedLogin(
          controller: controller,
          loginConfig: const LoginConfig(
            messages: messages,
            showForgotLink: true,
          ),
          onSignup: (_) async => null,
          onResetPassword: (_) async => null,
        ),
      );

      expect(find.text('ZZ sign up'), findsOneWidget);
      expect(find.text('ZZ forgot password'), findsOneWidget);

      controller.goTo(LoginStep.signup);
      await tester.pumpAndSettle();
      // Once as the title, once as the submit button's label.
      expect(find.text('ZZ create account'), findsNWidgets(2));
      expect(find.text('ZZ create account long'), findsOneWidget);
      expect(find.text('ZZ sign in'), findsOneWidget);

      controller.goTo(LoginStep.resetPassword);
      await tester.pumpAndSettle();
      expect(find.text('ZZ reset title'), findsOneWidget);
      expect(find.text('ZZ reset subtitle'), findsOneWidget);
      expect(find.text('ZZ reset button'), findsOneWidget);
      expect(find.text('ZZ sign in'), findsOneWidget);
    });

    testWidgets('the button stays disabled until the identifier is valid',
        (tester) async {
      await _pump(tester, FlutterAnimatedLogin(onLogin: (_) async => null));

      expect(_enabled(tester, 'Continue'), isFalse);

      await tester.enterText(find.byKey(_emailFieldKey), 'user@example.com');
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'Continue'), isTrue);
    });

    testWidgets('password login needs an identifier and a password',
        (tester) async {
      await _pump(
        tester,
        FlutterAnimatedLogin(
          loginType: LoginType.password,
          onLogin: (_) async => null,
        ),
      );

      expect(_enabled(tester, 'Sign In'), isFalse);

      await tester.enterText(find.byKey(_emailFieldKey), 'user@example.com');
      await tester.pumpAndSettle();

      // A filled email with an empty password must not enable the button.
      expect(_enabled(tester, 'Sign In'), isFalse);

      await tester.enterText(_fieldWithLabel('Password*'), 'sup3r-secret');
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'Sign In'), isTrue);
    });

    // Before 1.0.0 LoginType.otpAndPassword behaved exactly like otp: no
    // password field and no way to choose.
    testWidgets('otpAndPassword renders a password field and a method toggle',
        (tester) async {
      await _pump(
        tester,
        FlutterAnimatedLogin(
          loginType: LoginType.otpAndPassword,
          onLogin: (_) async => null,
        ),
      );

      expect(_fieldWithLabel('Password*'), findsOneWidget);
      expect(find.text('Use a one-time code instead'), findsOneWidget);
      expect(_buttonWithText('Sign In'), findsOneWidget);

      await tester.tap(find.text('Use a one-time code instead'));
      await tester.pumpAndSettle();

      expect(_fieldWithLabel('Password*'), findsNothing);
      expect(find.text('Use a password instead'), findsOneWidget);
      expect(_buttonWithText('Continue'), findsOneWidget);
    });

    testWidgets('an external controller drives the flow and reports steps',
        (tester) async {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      final steps = <LoginStep>[];

      await _pump(
        tester,
        FlutterAnimatedLogin(
          controller: controller,
          onSignup: (_) async => null,
          onStepChanged: steps.add,
        ),
      );

      expect(find.byKey(_emailFieldKey), findsOneWidget);

      controller.goTo(LoginStep.signup);
      await tester.pumpAndSettle();

      expect(find.text(_signupSubtitle), findsOneWidget);
      expect(steps, <LoginStep>[LoginStep.signup]);
      expect(controller.step, LoginStep.signup);
    });

    testWidgets('a required consent gates the primary button', (tester) async {
      await _pump(
        tester,
        FlutterAnimatedLogin(
          // The card's own background hides a CheckboxListTile's ink splash,
          // which Flutter reports as an error; see bugsFoundInLib. Drop the
          // card colour so that report cannot drown out this test.
          config: const PageConfig(cardDecoration: BoxDecoration()),
          consent: const ConsentConfig(
            label: Text('I accept the terms'),
            isRequired: true,
            showOnLogin: true,
          ),
          onLogin: (_) async => null,
        ),
      );

      await tester.enterText(find.byKey(_emailFieldKey), 'user@example.com');
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'Continue'), isFalse);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'Continue'), isTrue);
    });

    // The whole point of replacing the module-level signals with a per-widget
    // controller.
    testWidgets('two login widgets in one tree do not share state',
        (tester) async {
      tester.view.physicalSize = const Size(1600, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: FlutterAnimatedLogin(
                    key: const ValueKey<String>('first'),
                    config: const PageConfig(useScaffold: false),
                    onSignup: (_) async => null,
                  ),
                ),
                Expanded(
                  child: FlutterAnimatedLogin(
                    key: const ValueKey<String>('second'),
                    config: const PageConfig(useScaffold: false),
                    onSignup: (_) async => null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder inFirst(Finder matching) => find.descendant(
            of: find.byKey(const ValueKey<String>('first')),
            matching: matching,
          );
      Finder inSecond(Finder matching) => find.descendant(
            of: find.byKey(const ValueKey<String>('second')),
            matching: matching,
          );

      await tester.tap(inFirst(find.text('Sign Up')));
      await tester.pumpAndSettle();

      expect(inFirst(find.text(_signupSubtitle)), findsOneWidget);
      expect(inSecond(find.text(_signupSubtitle)), findsNothing);
      expect(inSecond(find.byKey(_emailFieldKey)), findsOneWidget);
      expect(inSecond(find.text('Sign Up')), findsOneWidget);
    });
  });
}
