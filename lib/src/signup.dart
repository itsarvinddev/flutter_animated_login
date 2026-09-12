import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flutter_animated_login.dart';
import 'controller.dart';
import 'utils/extension.dart';
import 'widget/button.dart';
import 'widget/identity_field.dart';
import 'widget/oauth.dart';
import 'widget/password_field.dart';

/// The account-creation screen.
class FlutterAnimatedSignup extends StatefulWidget {
  /// Creates the signup screen.
  const FlutterAnimatedSignup({
    super.key,
    required this.loginConfig,
    required this.loginType,
    required this.pageConfig,
    required this.config,
    required this.controller,
    this.onSignup,
    this.consent,
    this.termsAndConditions,
    this.providers,
  });

  /// Supplies the strings, the field configuration and the button style.
  final LoginConfig loginConfig;

  /// Decides the primary button's default label.
  final LoginType loginType;

  /// Everything about the page this screen is drawn on.
  final PageConfig pageConfig;

  /// Everything about this screen.
  final SignupConfig config;

  /// Owns the flow's state.
  final FlutterAnimatedLoginController controller;

  /// Runs your account creation.
  final SignupCallback? onSignup;

  /// A checkbox the user must tick before the primary button enables.
  final ConsentConfig? consent;

  /// Terms text shown under the social buttons.
  final Widget? termsAndConditions;

  /// The social sign-in options.
  final List<LoginProvider>? providers;

  @override
  State<FlutterAnimatedSignup> createState() => _FlutterAnimatedSignupState();
}

class _FlutterAnimatedSignupState extends State<FlutterAnimatedSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _customValues = <String, String>{};

  FlutterAnimatedLoginController get controller => widget.controller;
  SignupConfig get config => widget.config;
  FormMessages get messages => widget.loginConfig.messages;

  @override
  void initState() {
    super.initState();
    for (final field in config.additionalFields) {
      final initial = field.initialValue;
      if (initial == null || initial.isEmpty) continue;
      final fieldController = controller.additionalFieldController(field.key);
      // Only seed an untouched controller. Assigning unconditionally re-armed
      // the initial value after a successful signup cleared it, and because
      // the outgoing screen is still mounted during the page transition that
      // synchronous notification reached its TextFormField mid-build:
      // "setState() or markNeedsBuild() called during build".
      if (fieldController.text.isEmpty) fieldController.text = initial;
    }
  }

  Future<String?> _submit() async {
    final consent = widget.consent;
    if ((consent?.isRequired ?? false) &&
        (consent?.showOnSignup ?? true) &&
        !controller.acceptedTerms) {
      context.error(
        messages.errorTitle,
        description: consent?.errorText ?? messages.consentRequired,
      );
      return null;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      context.error(
        messages.errorTitle,
        description: messages.invalidFormData,
      );
      return null;
    }
    _formKey.currentState?.save();

    final onSignup = widget.onSignup;
    if (onSignup == null) return null;

    // Before 1.0.0 this flag was only ever cleared, never set, so the button
    // re-enabled mid-request and a second tap double-submitted.
    controller.setBusy(true);
    try {
      final extras = <String, String>{
        ...controller.additionalFieldValues,
        ..._customValues,
        if (config.includeConfirmPasswordInData)
          'confirmPassword': controller.confirmPasswordController.text,
      };

      final result = await onSignup(
        SignupData(
          name: controller.identifier,
          password: controller.passwordController.text,
          additionalSignupData: extras,
          phoneNumber: controller.isPhone ? controller.phoneNumber : null,
          acceptedTerms: controller.acceptedTerms,
        ),
      );
      if (!mounted) return null;
      if (result.isNotEmptyOrNull) {
        context.error(messages.errorTitle, description: result);
        return result;
      }
      TextInput.finishAutofillContext();
      if (config.loginAfterSignUp) {
        // Keep what was typed so the user can sign straight in. Authenticating
        // is your own onSignup's job — the package has no session to create.
        controller.goTo(LoginStep.login);
      } else {
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
    final consent = widget.consent;
    final gap = widget.loginConfig.fieldGap ??
        AnimatedLoginTheme.of(context).fieldGap ??
        18;
    final radius = AnimatedLoginTheme.of(context).fieldRadius ??
        const BorderRadius.all(Radius.circular(16));

    controller.configure(
      passwordRequired: true,
      consentRequired:
          (consent?.isRequired ?? false) && (consent?.showOnSignup ?? true),
    );

    // These fall back to the login screen's configuration so the two screens
    // match; before 1.0.0 they were overwritten and could never take effect.
    final identityConfig =
        config.textFiledConfig ?? widget.loginConfig.textFiledConfig;
    final passwordConfig =
        config.passwordTextFiledConfig ?? widget.loginConfig.passwordConfig;

    return PageWidget(
      // Before 1.0.0 the signup screen ignored PageConfig entirely, so the
      // background, card decoration and padding all reverted to defaults.
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
                    title: config.title ?? messages.signUp,
                    titleStyle: textTheme.titleLarge,
                    subtitle: config.subtitle ?? messages.createAccountLong,
                    subtitleStyle: textTheme.titleMedium,
                    titleGap: const SizedBox(height: 6),
                    child: config.logo,
                  ),
              IdentityField(
                config: identityConfig,
                controller: controller,
                formMessages: messages,
                loginFieldInputType: widget.loginConfig.loginFieldInputType,
              ),
              SizedBox(height: gap),
              PasswordTextField(
                config: passwordConfig.copyWith(
                  autofillHints: const <String>[AutofillHints.newPassword],
                ),
                controller: controller.passwordController,
                formMessages: messages,
              ),
              if (config.showConfirmPassword) ...[
                SizedBox(height: gap),
                PasswordTextField(
                  config: passwordConfig.copyWith(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofillHints: const <String>[AutofillHints.newPassword],
                    // The confirm field checks only that the two agree; the
                    // policy is already enforced on the field above.
                    policy: const PasswordPolicy.none(),
                    showStrengthMeter: false,
                    showRequirementChecklist: false,
                    decoration: (isObscure) {
                      final custom = passwordConfig.decoration?.call(isObscure);
                      if (custom != null) {
                        return custom.copyWith(
                          labelText: messages.confirmPassword,
                        );
                      }
                      return InputDecoration(
                        hintText: messages.reEnterPassword,
                        labelText: messages.confirmPassword,
                        border: OutlineInputBorder(borderRadius: radius),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          tooltip: isObscure.value
                              ? messages.showPassword
                              : messages.hidePassword,
                          onPressed: () => isObscure.value = !isObscure.value,
                        ),
                      );
                    },
                    validator: (value) =>
                        value != controller.passwordController.text
                            ? messages.passwordsUnmatched
                            : null,
                    textInputAction: config.additionalFields.isEmpty
                        ? TextInputAction.done
                        : TextInputAction.next,
                  ),
                  controller: controller.confirmPasswordController,
                  formMessages: messages,
                  onSubmitted:
                      config.additionalFields.isEmpty ? (_) => _submit() : null,
                ),
              ],
              // GitHub #8: extra fields such as a name or an age.
              for (final field in config.additionalFields) ...[
                SizedBox(height: gap),
                if (field.header != null) field.header!,
                _AdditionalField(
                  field: field,
                  controller: controller.additionalFieldController(field.key),
                  radius: radius,
                  isLast: field == config.additionalFields.last,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              for (final builder in config.customFields) ...[
                SizedBox(height: gap),
                builder(context, _customValues),
              ],
              if (consent != null && consent.showOnSignup) ...[
                SizedBox(height: gap / 2),
                ConsentCheckbox(config: consent, controller: controller),
              ],
              SizedBox(height: gap),
              SignInButton(
                onPressed: _submit,
                config: widget.loginConfig,
                loginType: widget.loginType,
                controller: controller,
                label: Text(messages.signUp),
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
              if (config.showProviders)
                OAuthWidget(
                  providers: widget.providers,
                  termsAndConditions: widget.termsAndConditions,
                  footerWidget: config.footer,
                  messages: messages,
                  controller: controller,
                  layout: widget.loginConfig.providerLayout,
                  spacing: widget.loginConfig.providerSpacing,
                )
              else
                config.footer.orShrink,
            ],
          ),
        ),
      ),
    );
  }
}

class _AdditionalField extends StatelessWidget {
  const _AdditionalField({
    required this.field,
    required this.controller,
    required this.radius,
    required this.isLast,
    required this.onSubmitted,
  });

  final SignupField field;
  final TextEditingController controller;
  final BorderRadius radius;
  final bool isLast;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<String>('flutter_animated_login.signup.${field.key}'),
      controller: controller,
      enabled: field.enabled,
      autofocus: field.autofocus,
      obscureText: field.obscureText,
      style: field.style,
      maxLength: field.maxLength,
      maxLines: field.obscureText ? 1 : field.maxLines,
      minLines: field.minLines,
      keyboardType: field.keyboardType,
      textCapitalization: field.textCapitalization,
      inputFormatters: field.inputFormatters,
      autofillHints: field.autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: field.textInputAction ??
          (isLast ? TextInputAction.done : TextInputAction.next),
      onFieldSubmitted: isLast ? onSubmitted : null,
      validator: field.validate,
      decoration: field.decoration ??
          InputDecoration(
            labelText: field.label ?? field.key,
            hintText: field.hint,
            border: OutlineInputBorder(borderRadius: radius),
            counter: field.maxLength == null ? const SizedBox.shrink() : null,
          ),
    );
  }
}
