import 'package:flutter/material.dart';

import 'demos/controller_demo.dart';
import 'demos/localization_demo.dart';
import 'demos/otp_demo.dart';
import 'demos/password_demo.dart';
import 'demos/providers_demo.dart';
import 'demos/reset_demo.dart';
import 'demos/signup_demo.dart';
import 'demos/theming_demo.dart';
import 'fake_auth.dart';
import 'theme_mode_scope.dart';

void main() => runApp(const ExampleApp());

/// A gallery of everything `flutter_animated_login` can do, one route per
/// feature.
///
/// Nothing here talks to a real server: [FakeAuth] stands in for one, waiting
/// a realistic moment before accepting a known identifier and rejecting
/// everything else.
class ExampleApp extends StatefulWidget {
  /// Creates the gallery.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final ValueNotifier<ThemeMode> _themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
        brightness: brightness,
        colorSchemeSeed: const Color(0xFF4F46E5),
      );

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      mode: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'Flutter Animated Login',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

/// One entry in the gallery.
@immutable
class Demo {
  /// Describes a demo and how to open it.
  const Demo({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.builder,
  });

  /// Shown as the tile's headline and used by the smoke test.
  final String title;

  /// One line on what the demo shows.
  final String blurb;

  /// The tile's leading glyph.
  final IconData icon;

  /// Builds the demo's route.
  final WidgetBuilder builder;
}

/// Every demo in the gallery, in the order the list shows them.
const List<Demo> demos = <Demo>[
  Demo(
    title: 'One-time code',
    blurb: 'Send a code to a phone or an email, verify it, resend it under a '
        'cooldown.',
    icon: Icons.sms_outlined,
    builder: _otpDemo,
  ),
  Demo(
    title: 'Password',
    blurb: 'Password sign-in, plus a signup screen under a PasswordPolicy '
        'with a strength meter.',
    icon: Icons.password_outlined,
    builder: _passwordDemo,
  ),
  Demo(
    title: 'Sign up with extra fields',
    blurb: 'A required name, a validated age, a newsletter checkbox — and the '
        'SignupData they produce.',
    icon: Icons.badge_outlined,
    builder: _signupDemo,
  ),
  Demo(
    title: 'Reset password',
    blurb: 'Ask for a reset link and return to the login screen.',
    icon: Icons.lock_reset_outlined,
    builder: _resetDemo,
  ),
  Demo(
    title: 'Social providers',
    blurb: 'Full-width branded buttons with semantic labels.',
    icon: Icons.groups_outlined,
    builder: _providersDemo,
  ),
  Demo(
    title: 'Programmatic control',
    blurb: 'Call showOtp(), prefill() and reset() on the controller yourself.',
    icon: Icons.settings_remote_outlined,
    builder: _controllerDemo,
  ),
  Demo(
    title: 'Theming',
    blurb: 'Brand all four screens with one AnimatedLoginTheme, in light and '
        'dark.',
    icon: Icons.palette_outlined,
    builder: _themingDemo,
  ),
  Demo(
    title: 'Localization',
    blurb: 'Every string overridden through FormMessages — here, in Spanish.',
    icon: Icons.translate_outlined,
    builder: _localizationDemo,
  ),
];

// Tear-offs, so the list above can stay const.
Widget _otpDemo(BuildContext context) => const OtpDemo();
Widget _passwordDemo(BuildContext context) => const PasswordDemo();
Widget _signupDemo(BuildContext context) => const SignupDemo();
Widget _resetDemo(BuildContext context) => const ResetDemo();
Widget _providersDemo(BuildContext context) => const ProvidersDemo();
Widget _controllerDemo(BuildContext context) => const ControllerDemo();
Widget _themingDemo(BuildContext context) => const ThemingDemo();
Widget _localizationDemo(BuildContext context) => const LocalizationDemo();

/// The list of demos.
class HomeScreen extends StatelessWidget {
  /// Creates the gallery's home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Animated Login'),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) return const _Credentials();
          final demo = demos[index - 1];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(demo.icon),
              ),
              title: Text(demo.title),
              subtitle: Text(demo.blurb),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: demo.builder),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The credentials every demo accepts, so nobody has to read [FakeAuth].
class _Credentials extends StatelessWidget {
  const _Credentials();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The fake backend accepts',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            const SelectableText(
              '${FakeAuth.phone}  ·  ${FakeAuth.email}\n'
              'code ${FakeAuth.otp}  ·  password ${FakeAuth.password}',
            ),
            const SizedBox(height: 6),
            Text(
              'Everything else is rejected, so the error paths are visible '
              'too.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
