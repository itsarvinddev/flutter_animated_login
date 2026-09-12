import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_animated_login.dart';

/// What the identifier field on the login screen accepts.
enum LoginFieldInputType {
  /// A phone number only. The field is always the country-picker field.
  phone,

  /// An email address only. The field is always a plain text field.
  email,

  /// Either. The field switches between the two as the user types: digits
  /// turn it into a phone field, anything else into an email field.
  phoneOrEmail,
}

/// Everything about the login screen.
@immutable
class LoginConfig {
  /// Shown above the title. Nothing is drawn when this is null.
  final Widget? logo;

  /// Replaces the whole title block.
  final Widget? header;

  /// Rendered at the very bottom of the screen.
  final Widget? footer;

  /// The screen's title.
  final String? title;

  /// The screen's subtitle.
  final String? subtitle;

  /// Replaces the generated [TitleWidget].
  final TitleWidget? titleWidget;

  /// The label inside the primary button.
  final Widget? buttonText;

  /// The style of the primary button's label.
  final TextStyle? buttonTextStyle;

  /// Configures the email/phone field.
  final EmailPhoneTextFiledConfig textFiledConfig;

  /// Configures the password field.
  final PasswordTextFiledConfig passwordConfig;

  /// Every user-facing string.
  final FormMessages messages;

  /// What the identifier field accepts.
  final LoginFieldInputType loginFieldInputType;

  /// Whether to show the link to the signup screen.
  ///
  /// Defaults to showing it whenever [FlutterAnimatedLogin.onSignup] was
  /// supplied — including for [LoginType.otp], where before 1.0.0 the link was
  /// rendered only in password mode and the signup screen was unreachable.
  final bool? showSignupLink;

  /// Whether to show the link to the reset-password screen.
  ///
  /// Defaults to showing it whenever [FlutterAnimatedLogin.onResetPassword]
  /// was supplied and the login type involves a password.
  final bool? showForgotLink;

  /// How the social login buttons are laid out.
  final ProviderLayout providerLayout;

  /// Space between social login buttons.
  final double providerSpacing;

  /// Vertical space between stacked fields. Falls back to
  /// [AnimatedLoginTheme.fieldGap], then to 18.
  final double? fieldGap;

  /// Terms text for the login screen.
  @Deprecated(
    'Pass a widget to FlutterAnimatedLogin.termsAndConditions, or use '
    'FlutterAnimatedLogin.consent for a checkbox that gates submission. '
    'This field was never read and will be removed in 2.0.0.',
  )
  final String? termsAndConditions;

  /// Privacy policy text for the login screen.
  @Deprecated(
    'Pass a widget to FlutterAnimatedLogin.termsAndConditions, or use '
    'FlutterAnimatedLogin.consent for a checkbox that gates submission. '
    'This field was never read and will be removed in 2.0.0.',
  )
  final String? privacyPolicy;

  /// Creates the login screen's configuration.
  const LoginConfig({
    this.logo,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.buttonText,
    this.buttonTextStyle,
    @Deprecated(
      'Pass a widget to FlutterAnimatedLogin.termsAndConditions instead. '
      'Removed in 2.0.0.',
    )
    this.termsAndConditions,
    @Deprecated(
      'Pass a widget to FlutterAnimatedLogin.termsAndConditions instead. '
      'Removed in 2.0.0.',
    )
    this.privacyPolicy,
    this.textFiledConfig = const EmailPhoneTextFiledConfig(),
    this.passwordConfig = const PasswordTextFiledConfig(),
    this.messages = const FormMessages(),
    this.loginFieldInputType = LoginFieldInputType.phoneOrEmail,
    this.showSignupLink,
    this.showForgotLink,
    this.providerLayout = ProviderLayout.iconWrap,
    this.providerSpacing = 12,
    this.fieldGap,
  });

  /// A copy of this configuration with the given properties replaced.
  ///
  /// Every constructor parameter is covered. Before 1.0.0 this method dropped
  /// `messages` and `loginFieldInputType`, which the package itself calls on
  /// every screen — so a custom [FormMessages] silently reverted to English on
  /// the signup and reset screens.
  LoginConfig copyWith({
    Widget? logo,
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    TitleWidget? titleWidget,
    Widget? buttonText,
    TextStyle? buttonTextStyle,
    String? termsAndConditions,
    String? privacyPolicy,
    EmailPhoneTextFiledConfig? textFiledConfig,
    PasswordTextFiledConfig? passwordConfig,
    FormMessages? messages,
    LoginFieldInputType? loginFieldInputType,
    bool? showSignupLink,
    bool? showForgotLink,
    ProviderLayout? providerLayout,
    double? providerSpacing,
    double? fieldGap,
  }) {
    return LoginConfig(
      logo: logo ?? this.logo,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleWidget: titleWidget ?? this.titleWidget,
      buttonText: buttonText ?? this.buttonText,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      // ignore: deprecated_member_use_from_same_package
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      // ignore: deprecated_member_use_from_same_package
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      textFiledConfig: textFiledConfig ?? this.textFiledConfig,
      passwordConfig: passwordConfig ?? this.passwordConfig,
      messages: messages ?? this.messages,
      loginFieldInputType: loginFieldInputType ?? this.loginFieldInputType,
      showSignupLink: showSignupLink ?? this.showSignupLink,
      showForgotLink: showForgotLink ?? this.showForgotLink,
      providerLayout: providerLayout ?? this.providerLayout,
      providerSpacing: providerSpacing ?? this.providerSpacing,
      fieldGap: fieldGap ?? this.fieldGap,
    );
  }
}

/// Everything about the email/phone identifier field.
///
/// In phone mode the field is an [IntlPhoneField] with a country picker; in
/// email mode it is a plain [TextFormField]. Properties that only make sense
/// for one of the two are documented as such.
@immutable
class EmailPhoneTextFiledConfig {
  /// Key for the underlying form field, for calling `validate()` on it
  /// directly.
  final GlobalKey<FormFieldState<dynamic>>? formFieldKey;

  /// Whether to hide the text being edited.
  final bool obscureText;

  /// How the text is aligned horizontally.
  ///
  /// Defaults to [TextAlign.start], which follows the ambient text direction —
  /// before 1.0.0 this was [TextAlign.left], which forced left alignment in
  /// Arabic, Hebrew and Farsi layouts.
  final TextAlign textAlign;

  /// How the text is aligned vertically.
  final TextAlignVertical? textAlignVertical;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Called when a pointer goes down outside the field.
  final void Function(PointerDownEvent)? onTapOutside;

  /// Whether the field rejects input while still showing its value.
  final bool readOnly;

  /// Called when the enclosing [Form] is saved.
  ///
  /// `number` is the parsed phone number in phone mode and `null` in email
  /// mode; `value` is always the raw text the user typed.
  final FormFieldSetter<({PhoneNumber? number, String? value})>? onSaved;

  /// Called on every keystroke, with the same payload as [onSaved].
  final ValueChanged<({PhoneNumber? number, String? value})>? onChanged;

  /// Called when the selected country changes. Phone mode only.
  final ValueChanged<Country>? onCountryChanged;

  /// Which keyboard to show.
  final TextInputType? keyboardType;

  /// Controls the field.
  ///
  /// Prefer [FlutterAnimatedLoginController.identifierController], which the
  /// package disposes for you. A controller passed here is never disposed by
  /// the package.
  final TextEditingController? controller;

  /// Reports and drives the phone field's country and number. Phone mode only.
  final PhoneController? phoneController;

  /// Defines the keyboard focus for this field.
  final FocusNode? focusNode;

  /// Called when the user submits from the keyboard.
  final void Function(String)? onSubmitted;

  /// Whether the field accepts input.
  final bool enabled;

  /// The appearance of the keyboard. iOS only.
  final Brightness? keyboardAppearance;

  /// Text the field starts with.
  final String? initialValue;

  /// How to read [initialValue]. Phone mode only.
  final InitialValueFormat initialValueFormat;

  /// Locale for country names in the picker.
  final String languageCode;

  /// 2-letter ISO code of the country selected on open, e.g. `'IN'`.
  final String? initialCountryCode;

  /// Replaces the country list entirely.
  final List<Country>? countries;

  /// Restricts the picker to these ISO codes.
  final List<String>? onlyCountries;

  /// Removes these ISO codes from the picker.
  final List<String>? excludeCountries;

  /// ISO codes pinned to the top of the picker.
  final List<String> favoriteCountries;

  /// Decoration for the field. Applies to both modes.
  final InputDecoration? decoration;

  /// Decoration used only in email mode, when the field is a plain text field.
  ///
  /// Falls back to [decoration], then to the package default.
  final InputDecoration? emailDecoration;

  /// The style of the typed text.
  final TextStyle? style;

  /// Whether to skip the per-country length check. Phone mode only.
  ///
  /// Since flutter_intl_phone_field 0.1.0 the built-in length check runs
  /// alongside a custom validator rather than instead of it, so set this when
  /// you want only your own rule.
  final bool? disableLengthCheck;

  /// Whether the number must match a real fixed-line or mobile range, not
  /// merely have a plausible length. Phone mode only.
  final bool strictValidation;

  /// Whether to show the dropdown arrow beside the flag.
  final bool showDropdownIcon;

  /// Decoration behind the country selector.
  final BoxDecoration dropdownDecoration;

  /// The style of the country dial code.
  final TextStyle? dropdownTextStyle;

  /// Restricts or reformats what can be typed.
  ///
  /// Leave null in phone mode to keep the country-detection, digit-filtering,
  /// length-limiting and as-you-type formatting chain the phone field installs
  /// for you.
  final List<TextInputFormatter>? inputFormatters;

  /// Hint of the country picker's search field.
  @Deprecated(
    'Set FormMessages.searchCountry, or PickerDialogStyle.searchFieldInput'
    'Decoration for full control. Removed in 2.0.0.',
  )
  final String searchText;

  /// Where the dropdown arrow sits relative to the flag.
  final IconPosition dropdownIconPosition;

  /// The dropdown arrow itself.
  final Icon dropdownIcon;

  /// Whether the field takes focus when its screen opens.
  final bool autofocus;

  /// When errors appear. Defaults to [AutovalidateMode.onUserInteraction].
  final AutovalidateMode? autovalidateMode;

  /// Whether to show the country flag.
  final bool showCountryFlag;

  /// Whether to show the country dial code beside the flag.
  final bool showCountryCode;

  /// The shape the flag is drawn in.
  final FlagShape flagShape;

  /// How large the flag is drawn.
  final double flagSize;

  /// Replaces the flag with your own widget.
  final Widget Function(BuildContext context, Country country)? flagBuilder;

  /// Replaces the dial code with your own widget.
  final Widget Function(BuildContext context, Country country)? dialCodeBuilder;

  /// Replaces the whole country selector with your own widget.
  final Widget Function(
    BuildContext context,
    Country country,
    VoidCallback openPicker,
  )? countrySelectorBuilder;

  /// Shown when the number fails the length check.
  final String? invalidMessage;

  /// The colour of the cursor.
  final Color? cursorColor;

  /// How tall the cursor is.
  final double? cursorHeight;

  /// How rounded the cursor's corners are.
  final Radius? cursorRadius;

  /// How thick the cursor is.
  final double cursorWidth;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// Padding inside the country selector button.
  final EdgeInsetsGeometry flagsButtonPadding;

  /// Which action key the keyboard shows.
  final TextInputAction? textInputAction;

  /// Styles the country picker dialog.
  final PickerDialogStyle? pickerDialogStyle;

  /// Margin around the country selector button.
  final EdgeInsets flagsButtonMargin;

  /// Autofill categories this field belongs to.
  final Iterable<String>? autofillHints;

  /// Configures the text magnifier.
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Replaces the country selector in the decoration's prefix slot.
  final Widget? prefixIcon;

  /// Whether the picker opens as a dialog or a bottom sheet.
  final DialogType dialogType;

  /// Most characters accepted.
  final int? maxLength;

  /// Fewest lines the field occupies.
  final int? minLines;

  /// Most lines shown before the field scrolls.
  final int? maxLines;

  /// Whether the field expands to fill its parent.
  final bool expands;

  /// What happens when [maxLength] is exceeded.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Builds the character counter.
  final InputCounterWidgetBuilder? buildCounter;

  /// Called when the user finishes editing.
  final void Function()? onEditingComplete;

  /// Whether to format the number as it is typed. Phone mode only.
  final bool formatInput;

  /// Whether to show a real example number as the hint. Phone mode only.
  final bool showExampleAsHint;

  /// Whether pasting an international number switches the country to match.
  /// Phone mode only.
  final bool detectCountryOnPaste;

  /// Identifier for state restoration.
  final String? restorationId;

  /// Creates the identifier field's configuration.
  const EmailPhoneTextFiledConfig({
    this.formFieldKey,
    this.initialCountryCode,
    this.languageCode = 'en',
    this.autofillHints,
    this.obscureText = false,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.onTap,
    this.onTapOutside,
    this.readOnly = false,
    this.initialValue,
    this.initialValueFormat = InitialValueFormat.auto,
    this.keyboardType,
    this.controller,
    this.phoneController,
    this.focusNode,
    this.decoration,
    this.emailDecoration,
    this.style,
    this.dropdownTextStyle,
    this.onSubmitted,
    this.onChanged,
    this.countries,
    this.onlyCountries,
    this.excludeCountries,
    this.favoriteCountries = const <String>[],
    this.onCountryChanged,
    this.onSaved,
    this.showDropdownIcon = true,
    this.dropdownDecoration = const BoxDecoration(),
    this.inputFormatters,
    this.enabled = true,
    this.keyboardAppearance,
    @Deprecated('Set FormMessages.searchCountry instead. Removed in 2.0.0.')
    this.searchText = 'Search country',
    this.dropdownIconPosition = IconPosition.leading,
    this.dropdownIcon = const Icon(Icons.arrow_drop_down),
    this.autofocus = false,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.showCountryFlag = true,
    this.showCountryCode = true,
    this.flagShape = FlagShape.rectangle,
    this.flagSize = 32,
    this.flagBuilder,
    this.dialCodeBuilder,
    this.countrySelectorBuilder,
    this.cursorColor,
    this.disableLengthCheck,
    this.strictValidation = false,
    this.flagsButtonPadding = EdgeInsets.zero,
    this.invalidMessage,
    this.cursorHeight,
    this.cursorRadius = Radius.zero,
    this.cursorWidth = 2.0,
    this.showCursor = true,
    this.pickerDialogStyle,
    this.flagsButtonMargin = EdgeInsets.zero,
    this.magnifierConfiguration,
    this.prefixIcon,
    this.dialogType = DialogType.showDialog,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.maxLengthEnforcement,
    this.buildCounter,
    this.onEditingComplete,
    this.formatInput = false,
    this.showExampleAsHint = false,
    this.detectCountryOnPaste = true,
    this.restorationId,
  });

  /// A copy of this configuration with the given properties replaced.
  ///
  /// Every constructor parameter is covered. Before 1.0.0 `style` carried a
  /// default value here, so any call to `copyWith` reset a custom style to
  /// `TextStyle(fontSize: 16)`, and `searchText` was accepted and discarded.
  EmailPhoneTextFiledConfig copyWith({
    GlobalKey<FormFieldState<dynamic>>? formFieldKey,
    String? initialCountryCode,
    String? languageCode,
    Iterable<String>? autofillHints,
    bool? obscureText,
    TextAlign? textAlign,
    TextAlignVertical? textAlignVertical,
    VoidCallback? onTap,
    void Function(PointerDownEvent)? onTapOutside,
    bool? readOnly,
    String? initialValue,
    InitialValueFormat? initialValueFormat,
    TextInputType? keyboardType,
    TextEditingController? controller,
    PhoneController? phoneController,
    FocusNode? focusNode,
    InputDecoration? decoration,
    InputDecoration? emailDecoration,
    TextStyle? style,
    TextStyle? dropdownTextStyle,
    void Function(String)? onSubmitted,
    ValueChanged<({PhoneNumber? number, String? value})>? onChanged,
    List<Country>? countries,
    List<String>? onlyCountries,
    List<String>? excludeCountries,
    List<String>? favoriteCountries,
    ValueChanged<Country>? onCountryChanged,
    FormFieldSetter<({PhoneNumber? number, String? value})>? onSaved,
    bool? showDropdownIcon,
    BoxDecoration? dropdownDecoration,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    Brightness? keyboardAppearance,
    String? searchText,
    IconPosition? dropdownIconPosition,
    Icon? dropdownIcon,
    bool? autofocus,
    AutovalidateMode? autovalidateMode,
    bool? showCountryFlag,
    bool? showCountryCode,
    FlagShape? flagShape,
    double? flagSize,
    Widget Function(BuildContext, Country)? flagBuilder,
    Widget Function(BuildContext, Country)? dialCodeBuilder,
    Widget Function(BuildContext, Country, VoidCallback)?
        countrySelectorBuilder,
    Color? cursorColor,
    bool? disableLengthCheck,
    bool? strictValidation,
    EdgeInsetsGeometry? flagsButtonPadding,
    String? invalidMessage,
    double? cursorHeight,
    Radius? cursorRadius,
    double? cursorWidth,
    bool? showCursor,
    PickerDialogStyle? pickerDialogStyle,
    EdgeInsets? flagsButtonMargin,
    TextMagnifierConfiguration? magnifierConfiguration,
    Widget? prefixIcon,
    DialogType? dialogType,
    int? maxLength,
    int? minLines,
    int? maxLines,
    bool? expands,
    MaxLengthEnforcement? maxLengthEnforcement,
    InputCounterWidgetBuilder? buildCounter,
    void Function()? onEditingComplete,
    TextInputAction? textInputAction,
    bool? formatInput,
    bool? showExampleAsHint,
    bool? detectCountryOnPaste,
    String? restorationId,
  }) {
    return EmailPhoneTextFiledConfig(
      formFieldKey: formFieldKey ?? this.formFieldKey,
      initialCountryCode: initialCountryCode ?? this.initialCountryCode,
      languageCode: languageCode ?? this.languageCode,
      autofillHints: autofillHints ?? this.autofillHints,
      obscureText: obscureText ?? this.obscureText,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      onTap: onTap ?? this.onTap,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      readOnly: readOnly ?? this.readOnly,
      initialValue: initialValue ?? this.initialValue,
      initialValueFormat: initialValueFormat ?? this.initialValueFormat,
      keyboardType: keyboardType ?? this.keyboardType,
      controller: controller ?? this.controller,
      phoneController: phoneController ?? this.phoneController,
      focusNode: focusNode ?? this.focusNode,
      decoration: decoration ?? this.decoration,
      emailDecoration: emailDecoration ?? this.emailDecoration,
      style: style ?? this.style,
      dropdownTextStyle: dropdownTextStyle ?? this.dropdownTextStyle,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      onChanged: onChanged ?? this.onChanged,
      countries: countries ?? this.countries,
      onlyCountries: onlyCountries ?? this.onlyCountries,
      excludeCountries: excludeCountries ?? this.excludeCountries,
      favoriteCountries: favoriteCountries ?? this.favoriteCountries,
      onCountryChanged: onCountryChanged ?? this.onCountryChanged,
      onSaved: onSaved ?? this.onSaved,
      showDropdownIcon: showDropdownIcon ?? this.showDropdownIcon,
      dropdownDecoration: dropdownDecoration ?? this.dropdownDecoration,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      enabled: enabled ?? this.enabled,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      // ignore: deprecated_member_use_from_same_package
      searchText: searchText ?? this.searchText,
      dropdownIconPosition: dropdownIconPosition ?? this.dropdownIconPosition,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      autofocus: autofocus ?? this.autofocus,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      showCountryFlag: showCountryFlag ?? this.showCountryFlag,
      showCountryCode: showCountryCode ?? this.showCountryCode,
      flagShape: flagShape ?? this.flagShape,
      flagSize: flagSize ?? this.flagSize,
      flagBuilder: flagBuilder ?? this.flagBuilder,
      dialCodeBuilder: dialCodeBuilder ?? this.dialCodeBuilder,
      countrySelectorBuilder:
          countrySelectorBuilder ?? this.countrySelectorBuilder,
      cursorColor: cursorColor ?? this.cursorColor,
      disableLengthCheck: disableLengthCheck ?? this.disableLengthCheck,
      strictValidation: strictValidation ?? this.strictValidation,
      flagsButtonPadding: flagsButtonPadding ?? this.flagsButtonPadding,
      invalidMessage: invalidMessage ?? this.invalidMessage,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      showCursor: showCursor ?? this.showCursor,
      pickerDialogStyle: pickerDialogStyle ?? this.pickerDialogStyle,
      flagsButtonMargin: flagsButtonMargin ?? this.flagsButtonMargin,
      magnifierConfiguration:
          magnifierConfiguration ?? this.magnifierConfiguration,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      dialogType: dialogType ?? this.dialogType,
      maxLength: maxLength ?? this.maxLength,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      expands: expands ?? this.expands,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      buildCounter: buildCounter ?? this.buildCounter,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      textInputAction: textInputAction ?? this.textInputAction,
      formatInput: formatInput ?? this.formatInput,
      showExampleAsHint: showExampleAsHint ?? this.showExampleAsHint,
      detectCountryOnPaste: detectCountryOnPaste ?? this.detectCountryOnPaste,
      restorationId: restorationId ?? this.restorationId,
    );
  }
}

/// Correctly spelled alias for [EmailPhoneTextFiledConfig], which configures
/// the email/phone identifier field.
///
/// The original name carries a typo ("TextFiled"). Both names work and mean
/// the same class; prefer this one. The misspelling will be deprecated in
/// 2.0.0 and removed in 3.0.0.
typedef EmailPhoneTextFieldConfig = EmailPhoneTextFiledConfig;
