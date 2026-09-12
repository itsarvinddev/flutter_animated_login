import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_animated_login/src/utils/gradient_box.dart';
import 'package:flutter_test/flutter_test.dart';

const ValueKey<String> emailKey =
    ValueKey<String>('flutter_animated_login.identity.email');

const Color kCardColorFromThemeData = Color(0xFF123456);
const Color kCardColorFromWidget = Color(0xFF654321);
const BorderRadius kFieldRadius = BorderRadius.all(Radius.circular(7));

/// Wide enough that the page is in its desktop layout, where the gradient is
/// fully opaque and therefore actually painted.
void useWideSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget harness({
  AnimatedLoginTheme? themeDataExtension,
  AnimatedLoginTheme? widgetTheme,
  PageConfig pageConfig = const PageConfig(),
  bool wrapInScaffold = false,
}) {
  final Widget login = FlutterAnimatedLogin(
    theme: widgetTheme,
    config: pageConfig,
    loginConfig: const LoginConfig(
      loginFieldInputType: LoginFieldInputType.email,
    ),
    onLogin: (_) async => null,
  );

  return MaterialApp(
    theme: ThemeData(
      extensions: themeDataExtension == null
          ? const <ThemeExtension<dynamic>>[]
          : <ThemeExtension<dynamic>>[themeDataExtension],
    ),
    home: wrapInScaffold ? Scaffold(body: login) : login,
  );
}

/// The card every screen is drawn on.
BoxDecoration cardDecoration(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration!
        as BoxDecoration;

/// The identifier field's outline, which follows
/// [AnimatedLoginTheme.fieldRadius].
BorderRadius fieldRadius(WidgetTester tester) {
  final field = tester.widget<TextField>(
    find.descendant(of: find.byKey(emailKey), matching: find.byType(TextField)),
  );
  return (field.decoration!.border! as OutlineInputBorder).borderRadius;
}

void main() {
  group('resolution', () {
    testWidgets(
        'a theme on ThemeData.extensions reaches the card and the '
        'fields', (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(
        themeDataExtension: const AnimatedLoginTheme(
          cardColor: kCardColorFromThemeData,
          fieldRadius: kFieldRadius,
        ),
      ));
      await tester.pumpAndSettle();

      expect(cardDecoration(tester).color, kCardColorFromThemeData);
      expect(fieldRadius(tester), kFieldRadius);
    });

    testWidgets('FlutterAnimatedLogin.theme wins over ThemeData.extensions',
        (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(
        themeDataExtension: const AnimatedLoginTheme(
          cardColor: kCardColorFromThemeData,
          fieldRadius: kFieldRadius,
        ),
        widgetTheme: const AnimatedLoginTheme(
          cardColor: kCardColorFromWidget,
        ),
      ));
      await tester.pumpAndSettle();

      expect(cardDecoration(tester).color, kCardColorFromWidget);
      // Properties the widget theme leaves null still come from ThemeData.
      expect(fieldRadius(tester), kFieldRadius);
    });

    testWidgets('with no theme at all the card falls back to the ColorScheme',
        (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      final scheme = Theme.of(
        tester.element(find.byType(FlutterAnimatedLogin)),
      ).colorScheme;
      expect(cardDecoration(tester).color, scheme.surface);
    });
  });

  group('AnimatedLoginTheme', () {
    const AnimatedLoginTheme small = AnimatedLoginTheme(
      cardColor: Color(0xFF000000),
      fieldGap: 10,
      maxCardWidth: 400,
      cardRadius: BorderRadius.all(Radius.circular(4)),
      titleStyle: TextStyle(fontSize: 10),
      pageTransitionDuration: Duration(milliseconds: 100),
    );
    const AnimatedLoginTheme large = AnimatedLoginTheme(
      cardColor: Color(0xFFFFFFFF),
      fieldGap: 20,
      maxCardWidth: 600,
      cardRadius: BorderRadius.all(Radius.circular(20)),
      titleStyle: TextStyle(fontSize: 30),
      pageTransitionDuration: Duration(milliseconds: 900),
    );

    test('lerp interpolates every interpolatable property', () {
      final mid = small.lerp(large, 0.5);

      expect(mid.fieldGap, 15);
      expect(mid.maxCardWidth, 500);
      expect(mid.cardColor, Color.lerp(small.cardColor, large.cardColor, 0.5));
      expect(
        mid.cardRadius,
        BorderRadius.lerp(small.cardRadius, large.cardRadius, 0.5),
      );
      expect(mid.titleStyle?.fontSize, 20);
      // Durations have no meaningful midpoint, so they snap at the halfway
      // mark rather than being dropped.
      expect(mid.pageTransitionDuration, large.pageTransitionDuration);
    });

    test('lerp returns the endpoints at t = 0 and t = 1', () {
      final start = small.lerp(large, 0);
      final end = small.lerp(large, 1);

      expect(start.fieldGap, small.fieldGap);
      expect(start.cardColor, small.cardColor);
      expect(end.fieldGap, large.fieldGap);
      expect(end.cardColor, large.cardColor);
    });

    test('lerp with no other theme returns this one unchanged', () {
      expect(small.lerp(null, 0.5), same(small));
    });

    test('copyWith round-trips', () {
      final same = small.copyWith();

      expect(same.cardColor, small.cardColor);
      expect(same.fieldGap, small.fieldGap);
      expect(same.maxCardWidth, small.maxCardWidth);
      expect(same.cardRadius, small.cardRadius);
      expect(same.titleStyle, small.titleStyle);
      expect(same.pageTransitionDuration, small.pageTransitionDuration);

      final changed = small.copyWith(
        cardColor: kCardColorFromWidget,
        fieldGap: 99,
      );

      expect(changed.cardColor, kCardColorFromWidget);
      expect(changed.fieldGap, 99);
      // Everything not named is carried over.
      expect(changed.cardRadius, small.cardRadius);
      expect(changed.titleStyle, small.titleStyle);
    });

    test('merge layers the other theme on top, keeping nulls', () {
      const overlay = AnimatedLoginTheme(cardColor: kCardColorFromWidget);
      final merged = small.merge(overlay);

      expect(merged.cardColor, kCardColorFromWidget);
      expect(merged.fieldGap, small.fieldGap);
      expect(small.merge(null), same(small));
    });
  });

  group('PageConfig.colors (regression)', () {
    const Color a = Color(0xFF112233);
    const Color b = Color(0xFF445566);
    const Color c = Color(0xFF778899);
    const Color d = Color(0xFFAABBCC);

    testWidgets('GradientBox paints one, two, three and four colours',
        (tester) async {
      for (final colors in const <List<Color>>[
        <Color>[a],
        <Color>[a, b],
        <Color>[a, b, c],
        <Color>[a, b, c, d],
      ]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GradientBox(colors: colors),
          ),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${colors.length} colours must paint; before 1.0.0 the '
              'hardcoded stops threw for anything but two',
        );
      }
    });

    testWidgets('three colours render inside the page', (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(
        pageConfig: const PageConfig(colors: <Color>[a, b, c]),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<GradientBox>(find.byType(GradientBox)).colors,
        const <Color>[a, b, c],
      );
      // The gradient is opaque here, so it really was painted rather than
      // skipped by a zero-opacity layer.
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.ancestor(
                of: find.byType(GradientBox),
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .opacity,
        1.0,
      );
    });

    testWidgets('a single colour renders inside the page', (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(
        pageConfig: const PageConfig(colors: <Color>[a]),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<GradientBox>(find.byType(GradientBox)).colors,
        const <Color>[a],
      );
    });
  });

  group('PageConfig.useScaffold', () {
    testWidgets('false adds no Scaffold of its own', (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(
        pageConfig: const PageConfig(useScaffold: false),
        wrapInScaffold: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('the default nests one inside yours', (tester) async {
      useWideSurface(tester);

      await tester.pumpWidget(harness(wrapInScaffold: true));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsNWidgets(2));
    });
  });
}
