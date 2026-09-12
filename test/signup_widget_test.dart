import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_animated_login/src/utils/gradient_box.dart';
import 'package:flutter_test/flutter_test.dart';

/// The English defaults every assertion below is written against.
const FormMessages messages = FormMessages();

/// Email mode keeps the identifier field a plain [TextFormField], so these
/// tests exercise the signup form rather than the country picker.
const LoginConfig emailLogin = LoginConfig(
  loginFieldInputType: LoginFieldInputType.email,
);

const ValueKey<String> emailKey = ValueKey<String>(
  'flutter_animated_login.identity.email',
);

/// The extra field [SignupField] renders for [key].
Finder extraField(String key) =>
    find.byKey(ValueKey<String>('flutter_animated_login.signup.$key'));

/// The text field carrying [label] in its decoration.
Finder fieldWithLabel(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextFormField));

Finder get submitButton => find.widgetWithText(FilledButton, messages.signUp);

/// Gives the test a window big enough for the whole signup form, so taps do
/// not have to scroll the card first.
void useLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// A controller that opens straight on [LoginStep.signup], disposed with the
/// test.
FlutterAnimatedLoginController signupController() {
  final controller = FlutterAnimatedLoginController(
    initialStep: LoginStep.signup,
  );
  addTearDown(controller.dispose);
  return controller;
}

Widget harness({
  required FlutterAnimatedLoginController controller,
  SignupConfig signupConfig = const SignupConfig(),
  LoginConfig loginConfig = emailLogin,
  PageConfig pageConfig = const PageConfig(),
  SignupCallback? onSignup,
  ConsentConfig? consent,
}) {
  return MaterialApp(
    home: FlutterAnimatedLogin(
      controller: controller,
      loginConfig: loginConfig,
      signupConfig: signupConfig,
      config: pageConfig,
      onSignup: onSignup,
      consent: consent,
    ),
  );
}

/// Fills the identifier and both password fields with valid values.
Future<void> fillCredentials(
  WidgetTester tester, {
  String email = 'ada@example.com',
  String password = 'Sup3rSecret!',
  String? confirmPassword,
}) async {
  await tester.enterText(find.byKey(emailKey), email);
  await tester.enterText(fieldWithLabel(messages.password), password);
  if (find.text(messages.confirmPassword).evaluate().isNotEmpty) {
    await tester.enterText(
      fieldWithLabel(messages.confirmPassword),
      confirmPassword ?? password,
    );
  }
  await tester.pump();
}

Future<void> tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}

void main() {
  group('SignupConfig.additionalFields (GitHub #8)', () {
    testWidgets('renders every field, gates submit and delivers both values', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(
            additionalFields: <SignupField>[
              SignupField(key: 'name', label: 'Full name', isRequired: true),
              SignupField(
                key: 'age',
                label: 'Age',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(extraField('name'), findsOneWidget);
      expect(extraField('age'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: extraField('age'),
                matching: find.byType(TextField),
              ),
            )
            .keyboardType,
        TextInputType.number,
      );

      // Everything filled but the required extra field.
      await fillCredentials(tester);
      await tester.enterText(extraField('age'), '36');
      await tester.pump();

      await tapSubmit(tester);
      expect(captured, isNull, reason: 'a required field was still empty');
      expect(find.text('Full name is required'), findsOneWidget);

      await tester.enterText(extraField('name'), 'Ada Lovelace');
      await tester.pump();
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(captured!.name, 'ada@example.com');
      expect(captured!.password, 'Sup3rSecret!');
      expect(captured!.additionalSignupData['name'], 'Ada Lovelace');
      expect(captured!.additionalSignupData['age'], '36');
    });

    testWidgets('SignupField.requiredMessage replaces the default', (
      tester,
    ) async {
      useLargeSurface(tester);

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(
            additionalFields: <SignupField>[
              SignupField(
                key: 'name',
                label: 'Full name',
                isRequired: true,
                requiredMessage: 'We need your name',
              ),
            ],
          ),
          onSignup: (_) async => null,
        ),
      );
      await tester.pumpAndSettle();

      await fillCredentials(tester);
      await tapSubmit(tester);

      expect(find.text('We need your name'), findsOneWidget);
      expect(find.text('Full name is required'), findsNothing);
    });

    testWidgets('SignupField.initialValue prefills and is submitted', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(
            additionalFields: <SignupField>[
              SignupField(
                key: 'company',
                label: 'Company',
                initialValue: 'Analytical Engines Ltd',
              ),
            ],
          ),
          // Returning a failure keeps the screen mounted. A success would send
          // the flow back to the login screen, and re-entering signup with a
          // prefilled field currently trips a framework assertion — see the
          // bug reported against signup.dart's initState.
          onSignup: (data) async {
            captured = data;
            return 'Backend said no';
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Analytical Engines Ltd'), findsOneWidget);

      await fillCredentials(tester);
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(
        captured!.additionalSignupData['company'],
        'Analytical Engines Ltd',
      );
    });
  });

  group('SignupConfig.customFields', () {
    testWidgets('renders the widget and forwards what it writes', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: SignupConfig(
            // Deliberately not a CheckboxListTile: the card paints its own
            // background with a DecoratedBox, and any ListTile under it trips
            // the framework's "ink splashes may be invisible" assertion.
            customFields: <SignupFieldBuilder>[
              (context, values) => StatefulBuilder(
                builder:
                    (context, setState) => Row(
                      children: [
                        Checkbox(
                          value: values['newsletter'] == 'true',
                          onChanged:
                              (value) => setState(
                                () => values['newsletter'] = '$value',
                              ),
                        ),
                        const Text('Send me product news'),
                      ],
                    ),
              ),
            ],
          ),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send me product news'), findsOneWidget);

      await fillCredentials(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(captured!.additionalSignupData['newsletter'], 'true');
    });
  });

  group('confirm password', () {
    testWidgets('is left out of additionalSignupData by default', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      await fillCredentials(tester);
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(
        captured!.additionalSignupData.containsKey('confirmPassword'),
        isFalse,
      );
      expect(captured!.additionalSignupData, isEmpty);
    });

    testWidgets('is included when includeConfirmPasswordInData is set', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(includeConfirmPasswordInData: true),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      await fillCredentials(tester);
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(captured!.additionalSignupData['confirmPassword'], 'Sup3rSecret!');
    });

    testWidgets('rejects a mismatch with FormMessages.passwordsUnmatched', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      await fillCredentials(tester, confirmPassword: 'Something3lse!');
      await tester.pump();

      // The confirm field autovalidates on user interaction.
      expect(find.text(messages.passwordsUnmatched), findsOneWidget);

      await tapSubmit(tester);
      expect(captured, isNull);
      expect(find.text(messages.passwordsUnmatched), findsOneWidget);
    });

    testWidgets('is hidden by SignupConfig(showConfirmPassword: false)', (
      tester,
    ) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(showConfirmPassword: false),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(messages.confirmPassword), findsNothing);
      expect(find.text(messages.password), findsOneWidget);

      await fillCredentials(tester);
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(captured!.password, 'Sup3rSecret!');
    });
  });

  group('PageConfig', () {
    testWidgets('applies to the signup screen', (tester) async {
      useLargeSurface(tester);
      const colors = <Color>[Color(0xFF112233), Color(0xFF445566)];
      const decoration = BoxDecoration(
        color: Color(0xFF10203A),
        borderRadius: BorderRadius.all(Radius.circular(3)),
      );

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          pageConfig: const PageConfig(
            colors: colors,
            cardDecoration: decoration,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<GradientBox>(find.byType(GradientBox)).colors,
        colors,
      );
      expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer))
            .decoration,
        decoration,
      );
    });
  });

  group('PasswordPolicy', () {
    testWidgets('blocks a weak password and shows its message', (tester) async {
      useLargeSurface(tester);
      SignupData? captured;

      await tester.pumpWidget(
        harness(
          controller: signupController(),
          signupConfig: const SignupConfig(
            passwordTextFiledConfig: PasswordTextFiledConfig(
              policy: PasswordPolicy(minLength: 10, requireDigit: true),
            ),
          ),
          onSignup: (data) async {
            captured = data;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      await fillCredentials(tester, password: 'short');
      await tapSubmit(tester);

      expect(captured, isNull);
      expect(find.text(messages.passwordTooShortFor(10)), findsOneWidget);

      await fillCredentials(tester, password: 'longenoughbutnodigit');
      await tapSubmit(tester);

      expect(captured, isNull);
      expect(find.text(messages.passwordNeedsDigit), findsOneWidget);

      await fillCredentials(tester, password: 'longenough1');
      await tapSubmit(tester);

      expect(captured, isNotNull);
      expect(captured!.password, 'longenough1');
    });
  });
}
