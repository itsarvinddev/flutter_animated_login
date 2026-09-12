import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Ask for a password-reset link.
///
/// [FlutterAnimatedLogin.onResetPassword] receives the identifier as a plain
/// string. Supplying it is also what puts the "Forgot Password?" link on the
/// login screen; the controller starts on [LoginStep.resetPassword] here so
/// the screen shows straight away.
class ResetDemo extends StatefulWidget {
  /// Creates the reset-password demo.
  const ResetDemo({super.key});

  @override
  State<ResetDemo> createState() => _ResetDemoState();
}

class _ResetDemoState extends State<ResetDemo> {
  final DemoEventLog _log = DemoEventLog();
  final FlutterAnimatedLoginController _controller =
      FlutterAnimatedLoginController(initialStep: LoginStep.resetPassword);

  @override
  void dispose() {
    _controller.dispose();
    _log.dispose();
    super.dispose();
  }

  Future<String?> _sendResetLink(String identifier) async {
    final error = await FakeAuth.sendResetLink(identifier);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Reset link sent to $identifier');
    return null;
  }

  Future<String?> _signIn(LoginData data) async {
    final error = await FakeAuth.signIn(data.name, data.secret ?? '');
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
      title: 'Reset password',
      log: _log,
      child: FlutterAnimatedLogin(
        controller: _controller,
        loginType: LoginType.password,
        onLogin: _signIn,
        onResetPassword: _sendResetLink,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Sign in',
          logo: Icon(Icons.lock_reset_outlined, size: 64),
          loginFieldInputType: LoginFieldInputType.email,
        ),
        resetConfig: const ResetConfig(
          title: 'Forgot your password?',
          subtitle: 'Enter ${FakeAuth.email} and we will send a link.',
          logo: Icon(Icons.mark_email_read_outlined, size: 64),
          // Go back to the login screen once the link is on its way.
          returnToLoginOnSuccess: true,
        ),
      ),
    );
  }
}
