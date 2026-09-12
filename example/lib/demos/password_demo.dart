import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Sign in with a password, and create an account under a [PasswordPolicy].
///
/// The login screen deliberately keeps [PasswordPolicy.none]: rules belong on
/// the screen where a password is *chosen*, never on the one where an existing
/// password is typed back in. The signup screen gets
/// [PasswordPolicy.standard], a strength meter and a live requirement
/// checklist.
class PasswordDemo extends StatefulWidget {
  /// Creates the password demo.
  const PasswordDemo({super.key});

  @override
  State<PasswordDemo> createState() => _PasswordDemoState();
}

class _PasswordDemoState extends State<PasswordDemo> {
  final DemoEventLog _log = DemoEventLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  Future<String?> _signIn(LoginData data) async {
    final error = await FakeAuth.signIn(data.name, data.secret ?? '');
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Signed in as ${data.name} (${data.method.name})');
    return null;
  }

  Future<String?> _signUp(SignupData data) async {
    final error = await FakeAuth.signUp(data);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Created an account for ${data.name}');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Password',
      log: _log,
      child: FlutterAnimatedLogin(
        loginType: LoginType.password,
        onLogin: _signIn,
        // Supplying onSignup is what puts the "Sign Up" link on the login
        // screen.
        onSignup: _signUp,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Sign in',
          subtitle: '${FakeAuth.email} / ${FakeAuth.password}',
          logo: Icon(Icons.password_outlined, size: 64),
          loginFieldInputType: LoginFieldInputType.email,
        ),
        signupConfig: const SignupConfig(
          subtitle: 'Pick a password of 8+ characters with a letter and a '
              'digit.',
          passwordTextFiledConfig: PasswordTextFiledConfig(
            policy: PasswordPolicy.standard(),
            showStrengthMeter: true,
            showRequirementChecklist: true,
          ),
        ),
      ),
    );
  }
}
