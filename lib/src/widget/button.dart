import 'package:flutter/material.dart';

import '../../flutter_animated_login.dart';
import '../utils/loading_state.dart';

/// Widest an action button grows, however wide the card is.
const double kMaxActionButtonWidth = 400;

/// Sizes an action button: full width of the card, capped so it does not
/// stretch absurdly on a desktop window.
///
/// Before 1.0.0 buttons were pinned to half the *viewport* width, so their
/// labels clipped under text scaling on a phone and floated in the middle of a
/// wide window.
class ActionButtonBox extends StatelessWidget {
  /// Wraps [child] in the standard action-button footprint.
  const ActionButtonBox({super.key, required this.child});

  /// The button.
  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: kMaxActionButtonWidth),
    child: SizedBox(width: double.infinity, child: child),
  );
}

/// The primary button on the login, signup and reset screens.
class SignInButton extends StatelessWidget {
  /// Creates the primary button.
  const SignInButton({
    super.key,
    required this.onPressed,
    required this.config,
    required this.loginType,
    required this.controller,
    this.label,
  });

  /// Runs the screen's submit logic.
  final Future<String?> Function()? onPressed;

  /// Supplies the label and its style.
  final LoginConfig config;

  /// Decides the default label when [config] and [label] give none.
  final LoginType loginType;

  /// Reports whether the form is valid and whether a submit is in flight.
  final FlutterAnimatedLoginController controller;

  /// Overrides the label.
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginTheme = AnimatedLoginTheme.of(context);
    final messages = config.messages;
    final usesOtp =
        loginType == LoginType.otp ||
        (loginType == LoginType.otpAndPassword && controller.useOtp);

    return ActionButtonBox(
      child: AutoLoadingButton(
        isLoading: controller.isBusy,
        style:
            loginTheme.primaryButtonStyle ??
            FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              textStyle:
                  config.buttonTextStyle ??
                  loginTheme.buttonTextStyle ??
                  theme.textTheme.titleMedium,
              shape:
                  loginTheme.buttonRadius == null
                      ? null
                      : RoundedRectangleBorder(
                        borderRadius: loginTheme.buttonRadius!,
                      ),
            ),
        onPressed: controller.isFormValid ? onPressed : null,
        child:
            label ??
            config.buttonText ??
            Text(usesOtp ? messages.continueButton : messages.signIn),
      ),
    );
  }
}

/// The "Sign Up" and "Forgot Password?" links under the login form.
///
/// Rendered whenever the matching callback was supplied, whatever the login
/// type. Before 1.0.0 this row appeared only in password mode, which left the
/// signup and reset screens unreachable for the default [LoginType.otp].
class SignUpAndForgetButton extends StatelessWidget {
  /// Creates the secondary link row.
  const SignUpAndForgetButton({
    super.key,
    required this.messages,
    required this.controller,
    required this.showSignup,
    required this.showForgot,
    this.textStyle,
  });

  /// Supplies the labels.
  final FormMessages messages;

  /// Navigates to the chosen screen.
  final FlutterAnimatedLoginController controller;

  /// Whether to show the link to the signup screen.
  final bool showSignup;

  /// Whether to show the link to the reset-password screen.
  final bool showForgot;

  /// Style of the labels.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (!showSignup && !showForgot) return const SizedBox.shrink();
    final loginTheme = AnimatedLoginTheme.of(context);
    final style =
        loginTheme.secondaryButtonStyle ??
        TextButton.styleFrom(textStyle: textStyle ?? loginTheme.linkStyle);

    final links = <Widget>[
      if (showSignup)
        TextButton(
          onPressed: () => controller.goTo(LoginStep.signup),
          style: style,
          child: Text(messages.signUpShort),
        ),
      if (showForgot)
        TextButton(
          onPressed: () => controller.goTo(LoginStep.resetPassword),
          style: style,
          child: Text(messages.forgotPassword),
        ),
    ];

    // A Row overflowed once the two labels stopped fitting — at about 1.7x
    // text scale on a phone, or in a language with longer words.
    return Wrap(
      alignment:
          links.length > 1 ? WrapAlignment.spaceBetween : WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: links,
    );
  }
}

/// Switches the login screen between the one-time-code and password paths in
/// [LoginType.otpAndPassword].
class LoginMethodToggle extends StatelessWidget {
  /// Creates the method toggle.
  const LoginMethodToggle({
    super.key,
    required this.messages,
    required this.controller,
    this.textStyle,
  });

  /// Supplies the label.
  final FormMessages messages;

  /// Holds which path is selected.
  final FlutterAnimatedLoginController controller;

  /// Style of the label.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => controller.setUseOtp(!controller.useOtp),
      style:
          AnimatedLoginTheme.of(context).secondaryButtonStyle ??
          TextButton.styleFrom(
            textStyle: textStyle ?? AnimatedLoginTheme.of(context).linkStyle,
          ),
      child: Text(
        controller.useOtp
            ? messages.usePasswordInstead
            : messages.useOtpInstead,
      ),
    );
  }
}
