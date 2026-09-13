import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

/// The English defaults every assertion below is written against.
const FormMessages messages = FormMessages();

/// Three providers, the count that used to overflow the old fixed row.
List<LoginProvider> providers() => <LoginProvider>[
  LoginProvider(
    icon: Icons.abc,
    semanticLabel: 'Sign in with Google',
    callback: () async => null,
  ),
  LoginProvider(
    icon: Icons.apple,
    semanticLabel: 'Sign in with Apple',
    callback: () async => null,
  ),
  LoginProvider(
    icon: Icons.facebook,
    semanticLabel: 'Sign in with Facebook',
    callback: () async => null,
  ),
];

/// A controller holding a valid identifier, so the primary button is enabled
/// rather than greyed out — a disabled button is exempt from contrast rules
/// and would hide a real failure.
FlutterAnimatedLoginController filledController({
  LoginStep step = LoginStep.login,
}) {
  final controller = FlutterAnimatedLoginController(
    initialStep: step,
    initialIdentifier: 'ada@example.com',
  );
  addTearDown(controller.dispose);
  return controller;
}

Widget harness({
  required FlutterAnimatedLoginController controller,
  LoginType loginType = LoginType.otp,
  List<LoginProvider>? loginProviders,
  TextScaler? textScaler,
  TextDirection? textDirection,
}) {
  Widget login = FlutterAnimatedLogin(
    controller: controller,
    loginType: loginType,
    loginConfig: const LoginConfig(
      loginFieldInputType: LoginFieldInputType.email,
      providerLayout: ProviderLayout.iconWrap,
    ),
    providers: loginProviders,
    onLogin: (_) async => null,
    onVerify: (_) async => null,
    onSignup: (_) async => null,
  );

  if (textDirection != null) {
    login = Directionality(textDirection: textDirection, child: login);
  }

  return MaterialApp(
    home: Builder(
      builder:
          (context) =>
              textScaler == null
                  ? login
                  : MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: textScaler),
                    child: login,
                  ),
    ),
  );
}

void main() {
  testWidgets('the login screen meets the Material accessibility guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      harness(controller: filledController(), loginProviders: providers()),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('the signup screen meets the Material accessibility guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      harness(
        controller: filledController(step: LoginStep.signup),
        loginProviders: providers(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('a social provider button announces its semanticLabel', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      harness(controller: filledController(), loginProviders: providers()),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Sign in with Google'), findsOneWidget);
    expect(find.bySemanticsLabel('Sign in with Apple'), findsOneWidget);
    expect(find.bySemanticsLabel('Sign in with Facebook'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('the password reveal toggle carries a tooltip', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      harness(controller: filledController(), loginType: LoginType.password),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(messages.showPassword), findsOneWidget);

    await tester.tap(find.byTooltip(messages.showPassword));
    await tester.pumpAndSettle();

    expect(find.byTooltip(messages.hidePassword), findsOneWidget);
    expect(find.byTooltip(messages.showPassword), findsNothing);

    handle.dispose();
  });

  testWidgets('the one-time-code field carries FormMessages.otpFieldLabel', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = filledController();

    await tester.pumpWidget(harness(controller: controller));
    await tester.pumpAndSettle();

    controller.showOtp(sentTo: 'ada@example.com');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(messages.otpFieldLabel), findsOneWidget);

    handle.dispose();
  });

  testWidgets('nothing overflows at textScaler 2.0 on a 400x800 window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harness(
        controller: filledController(),
        loginProviders: providers(),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    // The provider row and the Sign Up / Forgot row both overflowed here
    // before 1.0.0; both are a Wrap now.
    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap), findsWidgets);
  });

  testWidgets('the signup screen does not overflow at textScaler 2.0', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harness(
        controller: filledController(step: LoginStep.signup),
        loginProviders: providers(),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the login screen renders right-to-left', (tester) async {
    await tester.pumpWidget(
      harness(
        controller: filledController(),
        loginProviders: providers(),
        textDirection: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      Directionality.of(tester.element(find.byType(FlutterAnimatedLogin))),
      TextDirection.rtl,
    );
  });

  testWidgets('the signup screen renders right-to-left', (tester) async {
    await tester.pumpWidget(
      harness(
        controller: filledController(step: LoginStep.signup),
        loginProviders: providers(),
        textDirection: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
