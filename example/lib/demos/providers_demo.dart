import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Social sign-in buttons, laid out the way brand guidelines ask for.
///
/// [ProviderLayout.fullWidthStacked] gives every provider a labelled,
/// full-width button — what Apple and Google require. Each [LoginProvider]
/// carries its own colours and, importantly, a [LoginProvider.semanticLabel]
/// so a screen reader announces something better than "button".
///
/// Real apps pass the brand mark through [LoginProvider.iconWidget]; this demo
/// uses Material glyphs so it needs no assets.
class ProvidersDemo extends StatefulWidget {
  /// Creates the social-providers demo.
  const ProvidersDemo({super.key});

  @override
  State<ProvidersDemo> createState() => _ProvidersDemoState();
}

class _ProvidersDemoState extends State<ProvidersDemo> {
  final DemoEventLog _log = DemoEventLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  Future<String?> _signInWith(String provider) async {
    final error = await FakeAuth.signInWithProvider(provider);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Signed in with $provider');
    return null;
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

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Social providers',
      log: _log,
      child: FlutterAnimatedLogin(
        onLogin: _sendCode,
        onVerify: _verifyCode,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Continue with',
          subtitle: 'Google and Apple succeed; GitHub fails on purpose.',
          logo: Icon(Icons.groups_outlined, size: 64),
          providerLayout: ProviderLayout.fullWidthStacked,
          providerSpacing: 12,
        ),
        providers: <LoginProvider>[
          LoginProvider(
            icon: Icons.g_mobiledata,
            label: const Text('Continue with Google'),
            semanticLabel: 'Sign in with Google',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F1F1F),
            callback: () => _signInWith('Google'),
          ),
          LoginProvider(
            icon: Icons.apple,
            label: const Text('Continue with Apple'),
            semanticLabel: 'Sign in with Apple',
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            callback: () => _signInWith('Apple'),
          ),
          LoginProvider(
            icon: Icons.code,
            label: const Text('Continue with GitHub'),
            semanticLabel: 'Sign in with GitHub',
            backgroundColor: const Color(0xFF24292F),
            foregroundColor: Colors.white,
            // A provider that resolves with one of these strings is treated
            // as a cancellation rather than an error, so the user sees
            // nothing.
            errorsToExcludeFromErrorMessage: const <String>['cancelled'],
            callback: () => _signInWith('GitHub'),
          ),
        ],
        termsAndConditions: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'By continuing you agree to the demo terms.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
