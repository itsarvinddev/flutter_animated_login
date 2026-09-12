import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

/// Key of the email branch of the identity field.
const Key _emailFieldKey =
    ValueKey<String>('flutter_animated_login.identity.email');

/// Key of the phone branch of the identity field.
const Key _phoneFieldKey =
    ValueKey<String>('flutter_animated_login.identity.phone');

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

void main() {
  group('identity field', () {
    testWidgets('email input type renders the email field only',
        (tester) async {
      await _pump(
        tester,
        const FlutterAnimatedLogin(
          loginConfig: LoginConfig(
            loginFieldInputType: LoginFieldInputType.email,
          ),
        ),
      );

      expect(find.byKey(_emailFieldKey), findsOneWidget);
      expect(find.byKey(_phoneFieldKey), findsNothing);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('phone input type renders the phone field only',
        (tester) async {
      await _pump(
        tester,
        FlutterAnimatedLogin(
          loginConfig: const LoginConfig(
            loginFieldInputType: LoginFieldInputType.phone,
          ),
          onLogin: (_) async => null,
        ),
      );

      expect(find.byKey(_phoneFieldKey), findsOneWidget);
      expect(find.byKey(_emailFieldKey), findsNothing);

      expect(_enabled(tester, 'Continue'), isFalse);
      await tester.enterText(find.byKey(_phoneFieldKey), '9876543210');
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'Continue'), isTrue);
    });

    testWidgets('phoneOrEmail starts on email and follows what is typed',
        (tester) async {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      await _pump(tester, FlutterAnimatedLogin(controller: controller));

      expect(find.byKey(_emailFieldKey), findsOneWidget);
      expect(find.byKey(_phoneFieldKey), findsNothing);

      await tester.enterText(find.byKey(_emailFieldKey), '9876543210');
      await tester.pumpAndSettle();

      expect(find.byKey(_phoneFieldKey), findsOneWidget);
      expect(find.byKey(_emailFieldKey), findsNothing);
      expect(controller.isPhone, isTrue);

      // The phone field's own formatters drop everything but digits, so an
      // address can only reach it through the shared text controller — a
      // prefill, a deep link, or a platform paste.
      controller.identifierController.text = 'user@example.com';
      await tester.pumpAndSettle();

      expect(find.byKey(_emailFieldKey), findsOneWidget);
      expect(find.byKey(_phoneFieldKey), findsNothing);
      expect(controller.isPhone, isFalse);
    });

    // The critical one. flutter_intl_phone_field 0.1.x reduces its value to
    // digits, so routing an email through the phone field produced the empty
    // string: the button never enabled and email sign-in was dead.
    testWidgets('a valid email in phoneOrEmail enables the button and submits',
        (tester) async {
      String? received;

      await _pump(
        tester,
        FlutterAnimatedLogin(
          verifyConfig: const VerifyConfig(startCooldownOnOpen: false),
          onLogin: (data) async {
            received = data.name;
            return null;
          },
        ),
      );

      expect(_enabled(tester, 'Continue'), isFalse);

      await tester.enterText(find.byKey(_emailFieldKey), 'user@example.com');
      await tester.pumpAndSettle();

      expect(find.byKey(_emailFieldKey), findsOneWidget);
      expect(_enabled(tester, 'Continue'), isTrue);

      await tester.tap(_buttonWithText('Continue'));
      await tester.pumpAndSettle();

      expect(received, 'user@example.com');
    });

    testWidgets('the email validator rejects junk and accepts a real address',
        (tester) async {
      await _pump(
        tester,
        const FlutterAnimatedLogin(
          loginConfig: LoginConfig(
            messages: FormMessages(invalidEmail: 'ZZ invalid email'),
            loginFieldInputType: LoginFieldInputType.email,
            textFiledConfig: EmailPhoneTextFiledConfig(
              autovalidateMode: AutovalidateMode.always,
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(_emailFieldKey), 'not-an-email');
      await tester.pumpAndSettle();
      expect(find.text('ZZ invalid email'), findsOneWidget);

      await tester.enterText(
        find.byKey(_emailFieldKey),
        'user+tag@example.co.uk',
      );
      await tester.pumpAndSettle();
      expect(find.text('ZZ invalid email'), findsNothing);
    });
  });
}
