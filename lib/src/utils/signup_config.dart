import 'package:flutter/material.dart';

import '../../flutter_animated_login.dart';

/// Everything about the signup screen.
@immutable
class SignupConfig {
  /// Shown above the title.
  final Widget? logo;

  /// Replaces the whole title block.
  final Widget? header;

  /// Rendered at the very bottom of the screen.
  final Widget? footer;

  /// The screen's title. Defaults to [FormMessages.signUp].
  final String? title;

  /// The screen's subtitle. Defaults to [FormMessages.createAccountLong].
  final String? subtitle;

  /// Replaces the generated [TitleWidget].
  final TitleWidget? titleWidget;

  /// The style of the secondary link's label.
  final TextStyle? buttonTextStyle;

  /// Configures the identifier field.
  ///
  /// Left unset, the signup screen reuses [LoginConfig.textFiledConfig] so the
  /// two screens match. Set it to override that — before 1.0.0 this field was
  /// declared but unconditionally overwritten, so it could never take effect.
  final EmailPhoneTextFiledConfig? textFiledConfig;

  /// Configures both password fields.
  ///
  /// Left unset, the signup screen reuses [LoginConfig.passwordConfig].
  final PasswordTextFiledConfig? passwordTextFiledConfig;

  /// Extra fields rendered between the passwords and the submit button.
  ///
  /// Their values arrive in [SignupData.additionalSignupData], keyed by
  /// [SignupField.key]. This is the answer to "how do I add a name or an age
  /// to the signup form".
  final List<SignupField> additionalFields;

  /// Arbitrary extra controls — dropdowns, date pickers, checkboxes —
  /// rendered after [additionalFields].
  ///
  /// Each builder receives a mutable map; whatever it writes is merged into
  /// [SignupData.additionalSignupData].
  final List<SignupFieldBuilder> customFields;

  /// Whether the confirm-password value is included in
  /// [SignupData.additionalSignupData] under the key `confirmPassword`.
  ///
  /// Defaults to false. Before 1.0.0 it was always included, which sent a
  /// plaintext secret to a callback that never asked for it.
  final bool includeConfirmPasswordInData;

  /// Whether to render the confirm-password field at all.
  final bool showConfirmPassword;

  /// Whether to show the social login buttons and the terms text on this
  /// screen.
  ///
  /// Defaults to true — the signup screen is where consent matters most, and
  /// before 1.0.0 neither appeared here.
  final bool showProviders;

  /// After a successful signup, whether to keep what the user typed in the
  /// fields so they can sign straight in.
  ///
  /// This does **not** authenticate anyone: the package has no credentials to
  /// sign in with. Do that from your own `onSignup`.
  final bool loginAfterSignUp;

  /// Creates the signup screen's configuration.
  const SignupConfig({
    this.logo,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.titleWidget,
    @Deprecated(
      'The signup screen has no resend button. This field was never read and '
      'will be removed in 2.0.0.',
    )
    this.resendButton,
    this.buttonTextStyle,
    this.textFiledConfig,
    this.passwordTextFiledConfig,
    this.additionalFields = const <SignupField>[],
    this.customFields = const <SignupFieldBuilder>[],
    this.includeConfirmPasswordInData = false,
    this.showConfirmPassword = true,
    this.showProviders = true,
    this.loginAfterSignUp = false,
  });

  /// Never rendered.
  @Deprecated(
    'The signup screen has no resend button. This field was never read and '
    'will be removed in 2.0.0.',
  )
  final Widget? resendButton;

  /// A copy of this configuration with the given properties replaced.
  SignupConfig copyWith({
    Widget? logo,
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    TitleWidget? titleWidget,
    Widget? resendButton,
    TextStyle? buttonTextStyle,
    EmailPhoneTextFiledConfig? textFiledConfig,
    PasswordTextFiledConfig? passwordTextFiledConfig,
    List<SignupField>? additionalFields,
    List<SignupFieldBuilder>? customFields,
    bool? includeConfirmPasswordInData,
    bool? showConfirmPassword,
    bool? showProviders,
    bool? loginAfterSignUp,
  }) {
    return SignupConfig(
      logo: logo ?? this.logo,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleWidget: titleWidget ?? this.titleWidget,
      // ignore: deprecated_member_use_from_same_package
      resendButton: resendButton ?? this.resendButton,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      textFiledConfig: textFiledConfig ?? this.textFiledConfig,
      passwordTextFiledConfig:
          passwordTextFiledConfig ?? this.passwordTextFiledConfig,
      additionalFields: additionalFields ?? this.additionalFields,
      customFields: customFields ?? this.customFields,
      includeConfirmPasswordInData:
          includeConfirmPasswordInData ?? this.includeConfirmPasswordInData,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      showProviders: showProviders ?? this.showProviders,
      loginAfterSignUp: loginAfterSignUp ?? this.loginAfterSignUp,
    );
  }
}
