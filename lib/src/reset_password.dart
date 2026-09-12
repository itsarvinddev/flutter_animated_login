import 'package:flutter/material.dart';

import '../flutter_animated_login.dart';
import 'controller.dart';
import 'utils/extension.dart';
import 'widget/button.dart';
import 'widget/identity_field.dart';

/// The screen that asks where to send a password-reset link.
class FlutterAnimatedReset extends StatefulWidget {
  /// Creates the reset-password screen.
  const FlutterAnimatedReset({
    super.key,
    required this.config,
    required this.loginConfig,
    required this.loginType,
    required this.pageConfig,
    required this.controller,
    this.onResetPassword,
  });

  /// Everything about this screen.
  final ResetConfig config;

  /// Supplies the strings and the field configuration.
  final LoginConfig loginConfig;

  /// Decides the primary button's default label.
  final LoginType loginType;

  /// Everything about the page this screen is drawn on.
  final PageConfig pageConfig;

  /// Owns the flow's state.
  final FlutterAnimatedLoginController controller;

  /// Sends the reset link.
  final ResetPasswordCallback? onResetPassword;

  @override
  State<FlutterAnimatedReset> createState() => _FlutterAnimatedResetState();
}

class _FlutterAnimatedResetState extends State<FlutterAnimatedReset> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FlutterAnimatedLoginController get controller => widget.controller;
  FormMessages get messages => widget.loginConfig.messages;

  Future<String?> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      context.error(
        messages.errorTitle,
        description: messages.invalidFormData,
      );
      return null;
    }
    _formKey.currentState?.save();

    final onResetPassword = widget.onResetPassword;
    if (onResetPassword == null) return null;

    controller.setBusy(true);
    try {
      final result = await onResetPassword(controller.identifier);
      if (!mounted) return null;
      if (result.isNotEmptyOrNull) {
        context.error(messages.errorTitle, description: result);
        return result;
      }
      context.success(
        messages.successTitle,
        description: messages.resetLinkSent,
      );
      if (widget.config.returnToLoginOnSuccess) {
        _formKey.currentState?.reset();
        controller.reset();
      }
      return null;
    } finally {
      controller.setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AnimatedLoginScope.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final config = widget.config;
    final gap = widget.loginConfig.fieldGap ??
        AnimatedLoginTheme.of(context).fieldGap ??
        18;

    // The reset screen asks only for an identifier.
    controller.configure(passwordRequired: false, consentRequired: false);

    final identityConfig =
        config.textFiledConfig ?? widget.loginConfig.textFiledConfig;

    return PageWidget(
      config: widget.pageConfig,
      builder: (context, constraints) => Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              config.header ??
                  config.titleWidget ??
                  TitleWidget(
                    title: config.title ?? messages.resetTitle,
                    titleStyle: textTheme.titleLarge,
                    subtitle: config.subtitle ?? messages.resetSubtitle,
                    subtitleStyle: textTheme.titleMedium,
                    titleGap: const SizedBox(height: 6),
                    child: config.logo,
                  ),
              IdentityField(
                config: identityConfig,
                controller: controller,
                formMessages: messages,
                loginFieldInputType: widget.loginConfig.loginFieldInputType,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              SizedBox(height: gap),
              SignInButton(
                onPressed: _submit,
                config: widget.loginConfig,
                loginType: widget.loginType,
                controller: controller,
                label: config.buttonText ?? Text(messages.resetButton),
              ),
              const SizedBox(height: 8),
              ActionButtonBox(
                child: TextButton(
                  onPressed: () => controller.goTo(LoginStep.login),
                  style: TextButton.styleFrom(
                    textStyle: config.buttonTextStyle ?? textTheme.titleMedium,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(messages.signIn),
                ),
              ),
              config.footer.orShrink,
            ],
          ),
        ),
      ),
    );
  }
}
