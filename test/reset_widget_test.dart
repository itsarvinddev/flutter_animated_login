import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

/// The English defaults every assertion below is written against.
const FormMessages messages = FormMessages();

const ValueKey<String> emailKey =
    ValueKey<String>('flutter_animated_login.identity.email');

/// Gives the test a window big enough for the whole form, so taps never have
/// to scroll the card first.
void useLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget harness({
  ResetConfig resetConfig = const ResetConfig(),
  FormMessages formMessages = messages,
  ResetPasswordCallback? onResetPassword,
  FlutterAnimatedLoginController? controller,
}) {
  return MaterialApp(
    home: FlutterAnimatedLogin(
      controller: controller,
      // A password login is what puts the "Forgot Password?" link on screen.
      loginType: LoginType.password,
      loginConfig: LoginConfig(
        loginFieldInputType: LoginFieldInputType.email,
        messages: formMessages,
      ),
      resetConfig: resetConfig,
      onLogin: (_) async => null,
      onResetPassword: onResetPassword,
    ),
  );
}

/// Walks from the login screen to the reset screen the way a user does.
Future<void> openResetScreen(WidgetTester tester, {String? label}) async {
  await tester.pumpAndSettle();
  expect(find.text(label ?? messages.forgotPassword), findsOneWidget);
  await tester.tap(find.text(label ?? messages.forgotPassword));
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester, Finder button) async {
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'the forgot link opens the reset screen and submits the '
      'identifier', (tester) async {
    useLargeSurface(tester);
    final sentTo = <String>[];

    await tester.pumpWidget(harness(
      onResetPassword: (identifier) async {
        sentTo.add(identifier);
        return null;
      },
    ));
    await openResetScreen(tester);

    expect(find.text(messages.resetTitle), findsOneWidget);
    expect(find.text(messages.resetSubtitle), findsOneWidget);

    await tester.enterText(find.byKey(emailKey), 'ada@example.com');
    await tester.pump();
    await submit(
        tester, find.widgetWithText(FilledButton, messages.resetButton));

    expect(sentTo, <String>['ada@example.com']);
  });

  testWidgets('an empty identifier never reaches onResetPassword',
      (tester) async {
    useLargeSurface(tester);
    var calls = 0;

    await tester.pumpWidget(harness(
      onResetPassword: (_) async {
        calls++;
        return null;
      },
    ));
    await openResetScreen(tester);

    // The primary button stays disabled until the identifier is valid.
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, messages.resetButton),
    );
    expect(button.onPressed, isNull);
    expect(calls, 0);
  });

  testWidgets('a returned error keeps the user on the reset screen',
      (tester) async {
    useLargeSurface(tester);

    await tester.pumpWidget(harness(
      onResetPassword: (_) async => 'No account for that address',
    ));
    await openResetScreen(tester);

    await tester.enterText(find.byKey(emailKey), 'ada@example.com');
    await tester.pump();
    await submit(
        tester, find.widgetWithText(FilledButton, messages.resetButton));

    expect(find.text(messages.resetTitle), findsOneWidget);
    expect(find.text('No account for that address'), findsOneWidget);
    expect(find.text(messages.errorTitle), findsOneWidget);
    // Nothing was cleared, so the user can correct and retry.
    expect(find.text('ada@example.com'), findsOneWidget);
  });

  testWidgets('success returns to login when returnToLoginOnSuccess is set',
      (tester) async {
    useLargeSurface(tester);

    await tester.pumpWidget(harness(
      onResetPassword: (_) async => null,
    ));
    await openResetScreen(tester);

    await tester.enterText(find.byKey(emailKey), 'ada@example.com');
    await tester.pump();
    await submit(
        tester, find.widgetWithText(FilledButton, messages.resetButton));

    expect(find.text(messages.resetLinkSent), findsOneWidget);
    expect(find.text(messages.resetTitle), findsNothing);
    expect(find.widgetWithText(FilledButton, messages.signIn), findsOneWidget);
  });

  testWidgets('success stays put when returnToLoginOnSuccess is false',
      (tester) async {
    useLargeSurface(tester);

    await tester.pumpWidget(harness(
      resetConfig: const ResetConfig(returnToLoginOnSuccess: false),
      onResetPassword: (_) async => null,
    ));
    await openResetScreen(tester);

    await tester.enterText(find.byKey(emailKey), 'ada@example.com');
    await tester.pump();
    await submit(
        tester, find.widgetWithText(FilledButton, messages.resetButton));

    expect(find.text(messages.resetLinkSent), findsOneWidget);
    expect(find.text(messages.resetTitle), findsOneWidget);
  });

  testWidgets('the link back to login returns to the login screen',
      (tester) async {
    useLargeSurface(tester);

    await tester.pumpWidget(harness(onResetPassword: (_) async => null));
    await openResetScreen(tester);

    await tester.tap(find.widgetWithText(TextButton, messages.signIn));
    await tester.pumpAndSettle();

    expect(find.text(messages.resetTitle), findsNothing);
    expect(find.text(messages.forgotPassword), findsOneWidget);
  });

  group('strings', () {
    testWidgets('title, subtitle and button default to FormMessages',
        (tester) async {
      useLargeSurface(tester);
      const custom = FormMessages(
        resetTitle: 'Set a new password',
        resetSubtitle: 'Tell us where to send the link.',
        resetButton: 'Email me a link',
        forgotPassword: 'Lost your password?',
      );

      await tester.pumpWidget(harness(
        formMessages: custom,
        onResetPassword: (_) async => null,
      ));
      await openResetScreen(tester, label: custom.forgotPassword);

      expect(find.text(custom.resetTitle), findsOneWidget);
      expect(find.text(custom.resetSubtitle), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, custom.resetButton),
        findsOneWidget,
      );
      // The English defaults are gone, not merely duplicated.
      expect(find.text(messages.resetTitle), findsNothing);
      expect(find.text(messages.resetButton), findsNothing);
    });

    testWidgets('ResetConfig overrides win over FormMessages', (tester) async {
      useLargeSurface(tester);
      const custom = FormMessages(
        resetTitle: 'Set a new password',
        resetSubtitle: 'Tell us where to send the link.',
        resetButton: 'Email me a link',
      );

      await tester.pumpWidget(harness(
        formMessages: custom,
        resetConfig: const ResetConfig(
          title: 'Forgot it?',
          subtitle: 'Happens to everyone.',
          buttonText: Text('Send the link'),
        ),
        onResetPassword: (_) async => null,
      ));
      await openResetScreen(tester);

      expect(find.text('Forgot it?'), findsOneWidget);
      expect(find.text('Happens to everyone.'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Send the link'),
        findsOneWidget,
      );
      expect(find.text(custom.resetTitle), findsNothing);
      expect(find.text(custom.resetButton), findsNothing);
    });
  });
}
