import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Drive the flow from outside with a [FlutterAnimatedLoginController].
///
/// The buttons under the form call the controller directly — the same calls
/// you would make from a deep link, a "resend from elsewhere" push, or a
/// sign-out. [FlutterAnimatedLogin.onStepChanged] reports where the flow
/// ended up.
class ControllerDemo extends StatefulWidget {
  /// Creates the controller demo.
  const ControllerDemo({super.key});

  @override
  State<ControllerDemo> createState() => _ControllerDemoState();
}

class _ControllerDemoState extends State<ControllerDemo> {
  final DemoEventLog _log = DemoEventLog();
  final FlutterAnimatedLoginController _controller =
      FlutterAnimatedLoginController();

  LoginStep _step = LoginStep.login;

  @override
  void dispose() {
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Programmatic control',
      log: _log,
      footer: _ControllerBar(
        step: _step,
        onPrefill: () {
          // A national number plus a country: the identifier field switches
          // itself to phone mode and hands the callbacks E.164.
          _controller.prefill(
            identifier: FakeAuth.phoneNational,
            countryIsoCode: 'IN',
          );
          _log.success(
            'prefill(identifier: ${FakeAuth.phoneNational}, '
            "countryIsoCode: 'IN') -> ${_controller.identifier}",
          );
        },
        onShowOtp: () {
          _controller.showOtp(sentTo: FakeAuth.phone);
          _log.success('showOtp(sentTo: ${FakeAuth.phone})');
        },
        onReset: () {
          _controller.reset();
          _log.success('reset() — back to the login screen, fields cleared');
        },
      ),
      child: FlutterAnimatedLogin(
        controller: _controller,
        onLogin: _sendCode,
        onVerify: _verifyCode,
        onStepChanged: (step) => setState(() => _step = step),
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Driven from outside',
          subtitle: 'Use the buttons below the card.',
          logo: Icon(Icons.settings_remote_outlined, size: 64),
          loginFieldInputType: LoginFieldInputType.phoneOrEmail,
        ),
        verifyConfig: const VerifyConfig(
          // The code was "sent" by the button, not by this screen, so the
          // resend button is available immediately.
          startCooldownOnOpen: false,
        ),
      ),
    );
  }
}

class _ControllerBar extends StatelessWidget {
  const _ControllerBar({
    required this.step,
    required this.onPrefill,
    required this.onShowOtp,
    required this.onReset,
  });

  final LoginStep step;
  final VoidCallback onPrefill;
  final VoidCallback onShowOtp;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'controller.step: ${step.name}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.tonal(
                onPressed: onPrefill,
                child: const Text('prefill()'),
              ),
              FilledButton.tonal(
                onPressed: onShowOtp,
                child: const Text('showOtp()'),
              ),
              FilledButton.tonal(
                onPressed: onReset,
                child: const Text('reset()'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
