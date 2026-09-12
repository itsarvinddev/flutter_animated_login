import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Create an account with extra fields beyond the identifier and password.
///
/// [SignupField] covers anything a text field can express — here a required
/// "Full name" and a validated "Age". Anything else (a checkbox, a dropdown, a
/// date picker) goes in [SignupConfig.customFields], which hands the builder a
/// mutable map that is merged into [SignupData.additionalSignupData].
///
/// The controller starts on [LoginStep.signup] so the screen is the first
/// thing you see.
class SignupDemo extends StatefulWidget {
  /// Creates the signup demo.
  const SignupDemo({super.key});

  @override
  State<SignupDemo> createState() => _SignupDemoState();
}

class _SignupDemoState extends State<SignupDemo> {
  final DemoEventLog _log = DemoEventLog();
  final FlutterAnimatedLoginController _controller =
      FlutterAnimatedLoginController(initialStep: LoginStep.signup);

  @override
  void dispose() {
    // A controller you create is yours to dispose.
    _controller.dispose();
    _log.dispose();
    super.dispose();
  }

  Future<String?> _signUp(SignupData data) async {
    final error = await FakeAuth.signUp(data);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    // SignupData.toString() redacts the password for you, so the whole
    // payload is safe to show.
    _log.success('$data');
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
      title: 'Sign up with extra fields',
      log: _log,
      child: FlutterAnimatedLogin(
        controller: _controller,
        loginType: LoginType.password,
        onLogin: _signIn,
        onSignup: _signUp,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Sign in',
          logo: Icon(Icons.person_add_alt_outlined, size: 64),
          loginFieldInputType: LoginFieldInputType.email,
        ),
        signupConfig: SignupConfig(
          subtitle: 'Everything below arrives in SignupData.',
          logo: const Icon(Icons.badge_outlined, size: 64),
          additionalFields: <SignupField>[
            const SignupField(
              key: 'fullName',
              label: 'Full name',
              hint: 'Ada Lovelace',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              autofillHints: <String>[AutofillHints.name],
            ),
            SignupField(
              key: 'age',
              label: 'Age',
              hint: '36',
              isRequired: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              // Runs after the isRequired check passes.
              validator: (value) {
                final age = int.tryParse(value ?? '');
                if (age == null) return 'Enter your age in years';
                if (age < 13) return 'You must be at least 13';
                if (age > 120) return 'That is not a plausible age';
                return null;
              },
            ),
          ],
          customFields: <SignupFieldBuilder>[
            // Whatever a custom field writes into `values` is merged into
            // SignupData.additionalSignupData under the same key.
            // The Material keeps the tile's ink splash visible: the card
            // behind it is a DecoratedBox, not a Material.
            (context, values) => Material(
                  type: MaterialType.transparency,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Send me product news'),
                    value: values['newsletter'] == 'true',
                    onChanged: (value) => setState(
                      () => values['newsletter'] = '${value ?? false}',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
