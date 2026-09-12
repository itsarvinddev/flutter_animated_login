import 'package:flutter/material.dart';

import '../../flutter_animated_login.dart';

/// Everything about the reset-password screen.
@immutable
class ResetConfig {
  /// Shown above the title.
  final Widget? logo;

  /// Replaces the whole title block.
  final Widget? header;

  /// Rendered at the very bottom of the screen.
  final Widget? footer;

  /// The screen's title. Defaults to [FormMessages.resetTitle].
  final String? title;

  /// The screen's subtitle. Defaults to [FormMessages.resetSubtitle].
  final String? subtitle;

  /// Replaces the generated [TitleWidget].
  final TitleWidget? titleWidget;

  /// The style of the secondary link's label.
  final TextStyle? buttonTextStyle;

  /// Configures the identifier field.
  ///
  /// Left unset, the reset screen reuses [LoginConfig.textFiledConfig]. Before
  /// 1.0.0 this field was declared but unconditionally overwritten.
  final EmailPhoneTextFiledConfig? textFiledConfig;

  /// The label inside the submit button. Defaults to
  /// [FormMessages.resetButton].
  final Widget? buttonText;

  /// Whether to return to the login screen once the link is sent.
  final bool returnToLoginOnSuccess;

  /// Never rendered.
  @Deprecated(
    'The reset screen has no resend button. This field was never read and '
    'will be removed in 2.0.0.',
  )
  final Widget? resendButton;

  /// Creates the reset-password screen's configuration.
  const ResetConfig({
    this.logo,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.titleWidget,
    @Deprecated(
      'The reset screen has no resend button. This field was never read and '
      'will be removed in 2.0.0.',
    )
    this.resendButton,
    this.buttonTextStyle,
    this.textFiledConfig,
    this.buttonText,
    this.returnToLoginOnSuccess = true,
  });

  /// A copy of this configuration with the given properties replaced.
  ResetConfig copyWith({
    Widget? logo,
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    TitleWidget? titleWidget,
    Widget? resendButton,
    TextStyle? buttonTextStyle,
    EmailPhoneTextFiledConfig? textFiledConfig,
    Widget? buttonText,
    bool? returnToLoginOnSuccess,
  }) {
    return ResetConfig(
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
      buttonText: buttonText ?? this.buttonText,
      returnToLoginOnSuccess:
          returnToLoginOnSuccess ?? this.returnToLoginOnSuccess,
    );
  }
}
