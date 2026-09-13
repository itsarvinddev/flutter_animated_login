import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Brand every screen with a single [AnimatedLoginTheme].
///
/// The theme is handed straight to [FlutterAnimatedLogin.theme], which wins
/// over `ThemeData.extensions`. Registering it on your [ThemeData] instead
/// brands every login flow in the app at once:
///
/// ```dart
/// ThemeData(
///   extensions: const <ThemeExtension<dynamic>>[
///     AnimatedLoginTheme(fieldGap: 20),
///   ],
/// )
/// ```
///
/// Flip the app bar's light/dark toggle to see both halves of the palette;
/// the theme is rebuilt from the ambient [Brightness] on every build.
class ThemingDemo extends StatefulWidget {
  /// Creates the theming demo.
  const ThemingDemo({super.key});

  @override
  State<ThemingDemo> createState() => _ThemingDemoState();
}

class _ThemingDemoState extends State<ThemingDemo> {
  final DemoEventLog _log = DemoEventLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  Future<String?> _sendCode(LoginData data) async {
    final error = await FakeAuth.sendOtp(data.name);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Code ${FakeAuth.otp} sent to ${data.name}');
    return null;
  }

  Future<String?> _verifyCode(LoginData data) async {
    final error = await FakeAuth.verifyOtp(data.secret ?? '');
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Signed in as ${data.name}');
    return null;
  }

  AnimatedLoginTheme _theme(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return AnimatedLoginTheme(
      backgroundGradientStart:
          isDark ? const Color(0xFF10131A) : const Color(0xFFFDE68A),
      backgroundGradientEnd:
          isDark ? const Color(0xFF1F2937) : const Color(0xFFF472B6),
      cardColor: scheme.surface,
      cardRadius: const BorderRadius.all(Radius.circular(28)),
      fieldRadius: const BorderRadius.all(Radius.circular(12)),
      buttonRadius: const BorderRadius.all(Radius.circular(12)),
      cardPadding: const EdgeInsets.all(28),
      fieldGap: 22,
      maxCardWidth: 420,
      titleStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      subtitleStyle: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
      linkStyle: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary),
      // The notifications the package shows for you.
      successColor: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
      errorColor: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
      // How one screen gives way to the next.
      pageTransitionDuration: const Duration(milliseconds: 450),
      pageTransitionCurve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Theming',
      log: _log,
      child: FlutterAnimatedLogin(
        theme: _theme(context),
        onLogin: _sendCode,
        onVerify: _verifyCode,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Branded',
          subtitle: 'One AnimatedLoginTheme styles all four screens.',
          logo: Icon(Icons.palette_outlined, size: 64),
        ),
      ),
    );
  }
}
