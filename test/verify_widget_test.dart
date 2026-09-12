import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the codes in these tests are sent.
const String _sentTo = '+919876543210';

/// The Material button whose label is [label], whatever its variant.
Finder _buttonWithText(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );

/// Mounts the flow, drives it to the verify screen and settles the page
/// transition without burning any more of the cooldown than it has to.
Future<FlutterAnimatedLoginController> _pumpVerify(
  WidgetTester tester, {
  VerifyConfig config = const VerifyConfig(),
  VerifyCallback? onVerify,
  ResendOtpCallback? onResendOtp,
}) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final controller = FlutterAnimatedLoginController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: FlutterAnimatedLogin(
        controller: controller,
        verifyConfig: config,
        onVerify: onVerify,
        onResendOtp: onResendOtp,
      ),
    ),
  );
  await tester.pumpAndSettle();

  controller.showOtp(sentTo: _sentTo);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return controller;
}

void main() {
  group('verify screen', () {
    testWidgets('shows where the code went', (tester) async {
      await _pumpVerify(
        tester,
        config: const VerifyConfig(startCooldownOnOpen: false),
      );

      expect(find.text('Enter OTP sent to your phone'), findsOneWidget);
      expect(find.textContaining(_sentTo), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
    });

    testWidgets('the resend button waits for the cooldown', (tester) async {
      await _pumpVerify(
        tester,
        config: const VerifyConfig(resendCooldown: Duration(seconds: 2)),
      );

      // Counting down: a label, not a button, so there is nothing to tap.
      expect(find.text('Resend OTP (00:02)'), findsOneWidget);
      expect(_buttonWithText('Resend OTP'), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend OTP (00:01)'), findsOneWidget);
      expect(_buttonWithText('Resend OTP'), findsNothing);

      // The last tick cancels the timer, so the test ends with none pending.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.textContaining('Resend OTP ('), findsNothing);
      expect(_buttonWithText('Resend OTP'), findsOneWidget);
      expect(
        tester
            .widget<ButtonStyleButton>(_buttonWithText('Resend OTP'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('startCooldownOnOpen false offers the button at once',
        (tester) async {
      await _pumpVerify(
        tester,
        config: const VerifyConfig(startCooldownOnOpen: false),
      );

      expect(find.textContaining('Resend OTP ('), findsNothing);
      expect(_buttonWithText('Resend OTP'), findsOneWidget);
      expect(
        tester
            .widget<ButtonStyleButton>(_buttonWithText('Resend OTP'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('the resend limit replaces the button with a message',
        (tester) async {
      var sent = 0;
      final controller = await _pumpVerify(
        tester,
        config: const VerifyConfig(
          startCooldownOnOpen: false,
          resendCooldown: Duration.zero,
          maxResendAttempts: 1,
        ),
        onResendOtp: (_) async {
          sent++;
          return null;
        },
      );

      await tester.tap(_buttonWithText('Resend OTP'));
      await tester.pumpAndSettle();

      expect(sent, 1);
      expect(controller.resendAttempts, 1);
      expect(_buttonWithText('Resend OTP'), findsNothing);
      expect(
        find.text('No more attempts left, please try again later'),
        findsOneWidget,
      );
    });

    // Before 1.0.0 initState hardcoded 6 in three places, so a 4-digit code
    // never auto-submitted.
    testWidgets('a four-digit code auto-submits', (tester) async {
      LoginData? verified;
      final controller = await _pumpVerify(
        tester,
        config: const VerifyConfig(
          startCooldownOnOpen: false,
          textFiledConfig: OtpTextFiledConfig(length: 4),
        ),
        onVerify: (data) async {
          verified = data;
          return null;
        },
      );

      await tester.enterText(find.byType(Pinput), '1234');
      await tester.pumpAndSettle();

      expect(verified?.secret, '1234');
      expect(verified?.name, _sentTo);
      expect(verified?.method, LoginMethod.otp);
      // A null result means success, which returns to the login screen.
      expect(controller.step, LoginStep.login);
    });

    testWidgets('a rejected code stays put and clears the field',
        (tester) async {
      String? result = 'ZZ wrong code';
      final controller = await _pumpVerify(
        tester,
        config: const VerifyConfig(startCooldownOnOpen: false),
        onVerify: (_) async => result,
      );

      await tester.enterText(find.byType(Pinput), '123456');
      await tester.pumpAndSettle();

      expect(controller.step, LoginStep.verify);
      expect(controller.otpController.text, isEmpty);
      expect(find.text('ZZ wrong code'), findsOneWidget);

      result = null;
      await tester.enterText(find.byType(Pinput), '654321');
      await tester.pumpAndSettle();

      expect(controller.step, LoginStep.login);
    });
  });
}
