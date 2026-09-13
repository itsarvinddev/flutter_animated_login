import 'package:example/fake_auth.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ValueKey<String> emailFieldKey = ValueKey<String>(
    'flutter_animated_login.identity.email',
  );

  /// Pumps the gallery on a phone-sized surface, the way the demos are meant
  /// to be seen.
  Future<void> pumpGallery(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();
  }

  /// Opens the demo whose tile reads [title].
  Future<void> openDemo(WidgetTester tester, String title) async {
    final Finder tile = find.text(title);
    await tester.scrollUntilVisible(
      tile,
      120,
      // The credentials card holds a SelectableText, which is a Scrollable of
      // its own; the list is the first one in the tree.
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('the one-time-code demo enables its button only once the '
      'identifier is valid', (WidgetTester tester) async {
    await pumpGallery(tester);
    expect(find.text('Flutter Animated Login'), findsOneWidget);

    await openDemo(tester, 'One-time code');

    // We are on the demo's login screen now, not the gallery.
    expect(find.text('Welcome back'), findsOneWidget);

    // Nothing typed yet: the field is in email mode and the button is off.
    final Finder field = find.byKey(emailFieldKey);
    expect(field, findsOneWidget);
    final Finder button = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    // A half-typed address is still not enough.
    await tester.enterText(field, 'demo@');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.enterText(field, FakeAuth.email);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('the one-time-code demo runs a whole round trip against the '
      'fake backend', (WidgetTester tester) async {
    await pumpGallery(tester);
    await openDemo(tester, 'One-time code');

    await tester.enterText(find.byKey(emailFieldKey), FakeAuth.email);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    // Let the fake network call resolve.
    await tester.pump(FakeAuth.latency + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // The package moved to the verify screen, and the demo reported the send.
    expect(find.text('Enter OTP sent to your email'), findsOneWidget);
    expect(find.textContaining('Code ${FakeAuth.otp} sent'), findsOneWidget);

    // Pinput is the only EditableText on this screen.
    await tester.enterText(find.byType(EditableText).first, FakeAuth.otp);
    await tester.pump();
    await tester.pump(FakeAuth.latency + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Signed in as ${FakeAuth.email}'),
      findsOneWidget,
    );
  });

  testWidgets('the signup demo renders its additional and custom fields', (
    WidgetTester tester,
  ) async {
    await pumpGallery(tester);
    await openDemo(tester, 'Sign up with extra fields');

    // SignupConfig.additionalFields …
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);

    // … and SignupConfig.customFields.
    final Finder newsletter = find.widgetWithText(
      CheckboxListTile,
      'Send me product news',
    );
    expect(newsletter, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(newsletter).value, isFalse);

    await tester.ensureVisible(newsletter);
    await tester.pumpAndSettle();
    await tester.tap(newsletter);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(newsletter).value, isTrue);

    // The identifier and the password are still empty, so the submit button
    // stays disabled.
    final Finder submit = find.widgetWithText(FilledButton, 'Create Account');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
  });
}
