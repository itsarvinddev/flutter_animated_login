import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Sign in with a one-time code sent to a phone number or an email address.
///
/// The whole round trip: [FlutterAnimatedLogin.onLogin] sends the code, the
/// package moves to the verify screen once it succeeds, and
/// [FlutterAnimatedLogin.onVerify] checks what was typed. The resend button,
/// its cooldown and its attempt limit all come from [VerifyConfig].
class OtpDemo extends StatefulWidget {
  /// Creates the one-time-code demo.
  const OtpDemo({super.key});

  @override
  State<OtpDemo> createState() => _OtpDemoState();
}

class _OtpDemoState extends State<OtpDemo> {
  final DemoEventLog _log = DemoEventLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  /// Returning null advances the flow to the verify screen; returning a
  /// message keeps the user here and shows it.
  Future<String?> _sendCode(LoginData data) async {
    final error = await FakeAuth.sendOtp(data.name);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Code ${FakeAuth.otp} sent to ${data.name}');
    return null;
  }

  Future<String?> _resendCode(LoginData data) async {
    final error = await FakeAuth.sendOtp(data.name);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('New code sent to ${data.name}');
    return null;
  }

  Future<String?> _verifyCode(LoginData data) async {
    final error = await FakeAuth.verifyOtp(data.secret ?? '');
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Signed in as ${data.name} (${data.method.name})');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'One-time code',
      log: _log,
      child: FlutterAnimatedLogin(
        loginType: LoginType.otp,
        onLogin: _sendCode,
        onVerify: _verifyCode,
        onResendOtp: _resendCode,
        // This page already has a Scaffold of its own.
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Welcome back',
          subtitle: 'Use ${FakeAuth.phone} or ${FakeAuth.email}',
          logo: Icon(Icons.sms_outlined, size: 64),
          // The field switches itself between a country-picker phone field
          // and a plain email field as the user types.
          loginFieldInputType: LoginFieldInputType.phoneOrEmail,
          textFiledConfig: EmailPhoneTextFiledConfig(
            initialCountryCode: 'IN',
          ),
        ),
        verifyConfig: VerifyConfig(
          resendCooldown: const Duration(seconds: 15),
          maxResendAttempts: 3,
          // Filling the last cell submits, so nobody has to find a button.
          autoSubmitOnFill: true,
          countdownBuilder: (context, remaining) => Text(
            'You can ask for a new code in ${remaining.inSeconds}s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
