import 'package:flutter/material.dart';

import '../../flutter_animated_login.dart';
import '../utils/extension.dart';

/// The field that asks who is signing in.
///
/// It renders one of two real widgets rather than one widget pretending to be
/// both:
///
/// * a plain [TextFormField] for an email address, and
/// * an [IntlPhoneField] — country picker, as-you-type formatting, per-country
///   length rules — for a phone number.
///
/// In [LoginFieldInputType.phoneOrEmail] it switches between them as the user
/// types. Before 1.0.0 an email was typed into the phone field with its
/// country selector hidden; since flutter_intl_phone_field 0.1.0 reduces that
/// field's value to digits, an email address came back as the empty string and
/// email sign-in stopped working altogether.
class IdentityField extends StatelessWidget {
  /// Creates the identifier field.
  const IdentityField({
    super.key,
    required this.config,
    required this.controller,
    required this.formMessages,
    required this.loginFieldInputType,
    this.onSubmitted,
    this.textInputAction,
  });

  /// How the field is configured.
  final EmailPhoneTextFiledConfig config;

  /// Owns the flow's state, including the shared text controller.
  final FlutterAnimatedLoginController controller;

  /// Every user-facing string.
  final FormMessages formMessages;

  /// What this field accepts.
  final LoginFieldInputType loginFieldInputType;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Which action key the keyboard shows. Overrides [config].
  final TextInputAction? textInputAction;

  bool get _isPhone => switch (loginFieldInputType) {
        LoginFieldInputType.phone => true,
        LoginFieldInputType.email => false,
        LoginFieldInputType.phoneOrEmail => controller.isPhone,
      };

  @override
  Widget build(BuildContext context) {
    return _isPhone ? _buildPhone(context) : _buildEmail(context);
  }

  InputDecoration _decoration(BuildContext context, {required bool isPhone}) {
    final supplied = isPhone ? config.decoration : config.emailDecoration;
    if (supplied != null) return supplied;
    if (config.decoration != null) return config.decoration!;

    final radius = AnimatedLoginTheme.of(context).fieldRadius ??
        const BorderRadius.all(Radius.circular(16));
    final (hint, label) = switch (loginFieldInputType) {
      LoginFieldInputType.phone => (
          formMessages.loginFieldEnterPhone,
          formMessages.phone,
        ),
      LoginFieldInputType.email => (
          formMessages.loginFieldEnterEmail,
          formMessages.email,
        ),
      LoginFieldInputType.phoneOrEmail => isPhone
          ? (formMessages.loginFieldEnterPhone, formMessages.phone)
          : (
              formMessages.loginFieldEnterEmailOrPhone,
              formMessages.emailOrPhone,
            ),
    };

    return InputDecoration(
      hintText: hint,
      labelText: label,
      border: OutlineInputBorder(borderRadius: radius),
      counter: const SizedBox.shrink(),
    );
  }

  // ------------------------------------------------------------------ email

  Widget _buildEmail(BuildContext context) {
    final acceptsPhoneToo =
        loginFieldInputType == LoginFieldInputType.phoneOrEmail;

    return TextFormField(
      key: const ValueKey<String>('flutter_animated_login.identity.email'),
      controller: controller.identifierController,
      focusNode: config.focusNode,
      enabled: config.enabled,
      readOnly: config.readOnly,
      autofocus: config.autofocus,
      obscureText: config.obscureText,
      style: config.style,
      textAlign: config.textAlign,
      textAlignVertical: config.textAlignVertical,
      maxLines: config.maxLines ?? 1,
      minLines: config.minLines,
      expands: config.expands,
      maxLength: config.maxLength,
      maxLengthEnforcement: config.maxLengthEnforcement,
      buildCounter: config.buildCounter,
      cursorColor: config.cursorColor,
      cursorHeight: config.cursorHeight,
      cursorRadius: config.cursorRadius,
      cursorWidth: config.cursorWidth,
      showCursor: config.showCursor,
      keyboardAppearance: config.keyboardAppearance,
      magnifierConfiguration: config.magnifierConfiguration,
      restorationId: config.restorationId,
      inputFormatters: config.inputFormatters,
      autovalidateMode: config.autovalidateMode,
      decoration: _decoration(context, isPhone: false),
      keyboardType: config.keyboardType ?? TextInputType.emailAddress,
      textInputAction:
          textInputAction ?? config.textInputAction ?? TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: config.autofillHints ??
          const <String>[AutofillHints.email, AutofillHints.username],
      onTap: config.onTap,
      onTapOutside: config.onTapOutside,
      onEditingComplete: config.onEditingComplete,
      onFieldSubmitted: (value) {
        config.onSubmitted?.call(value);
        onSubmitted?.call(value);
      },
      onChanged: (value) {
        config.onChanged?.call((number: null, value: value));
      },
      onSaved: (value) {
        config.onSaved?.call((number: null, value: value));
      },
      validator: (value) {
        final text = (value ?? '').trim();
        if (text.isEmpty) {
          return acceptsPhoneToo
              ? formMessages.loginFieldEnterPhoneValidatorEmpty
              : formMessages.invalidEmail;
        }
        if (text.isEmail) return null;
        // In phoneOrEmail mode a bare number is legitimate; the field just has
        // not switched yet, so report the combined message.
        if (acceptsPhoneToo) {
          return text.isIntlPhoneNumber
              ? null
              : formMessages.loginFieldEnterPhoneValidatorInvalid;
        }
        return formMessages.invalidEmail;
      },
    );
  }

  // ------------------------------------------------------------------ phone

  Widget _buildPhone(BuildContext context) {
    return IntlPhoneField(
      key: const ValueKey<String>('flutter_animated_login.identity.phone'),
      formFieldKey: config.formFieldKey,
      controller: controller.identifierController,
      phoneController: config.phoneController,
      focusNode: config.focusNode,
      initialCountryCode:
          config.initialCountryCode ?? controller.countryIsoCode,
      initialValue: config.initialValue,
      initialValueFormat: config.initialValueFormat,
      languageCode: config.languageCode,
      enabled: config.enabled,
      readOnly: config.readOnly,
      autofocus: config.autofocus,
      obscureText: config.obscureText,
      style: config.style,
      dropdownTextStyle: config.dropdownTextStyle ?? config.style,
      textAlign: config.textAlign,
      textAlignVertical: config.textAlignVertical,
      maxLines: config.maxLines,
      minLines: config.minLines,
      expands: config.expands,
      maxLength: config.maxLength,
      maxLengthEnforcement: config.maxLengthEnforcement,
      buildCounter: config.buildCounter,
      cursorColor: config.cursorColor,
      cursorHeight: config.cursorHeight,
      cursorRadius: config.cursorRadius,
      cursorWidth: config.cursorWidth,
      showCursor: config.showCursor,
      keyboardAppearance: config.keyboardAppearance,
      magnifierConfiguration: config.magnifierConfiguration,
      restorationId: config.restorationId,
      decoration: _decoration(context, isPhone: true),
      // Left null on purpose: IntlPhoneField then installs its own chain —
      // paste-country detection, digit filtering, the per-country length cap
      // and as-you-type formatting. Passing `const []`, as versions before
      // 1.0.0 did, silently disabled all four.
      inputFormatters: config.inputFormatters,
      countries: config.countries,
      onlyCountries: config.onlyCountries,
      excludeCountries: config.excludeCountries,
      favoriteCountries: config.favoriteCountries,
      showCountryFlag: config.showCountryFlag,
      showCountryCode: config.showCountryCode,
      flagShape: config.flagShape,
      flagSize: config.flagSize,
      flagBuilder: config.flagBuilder,
      dialCodeBuilder: config.dialCodeBuilder,
      countrySelectorBuilder: config.countrySelectorBuilder,
      showDropdownIcon: config.showDropdownIcon,
      dropdownDecoration: config.dropdownDecoration,
      dropdownIcon: config.dropdownIcon,
      dropdownIconPosition: config.dropdownIconPosition,
      flagsButtonMargin: config.flagsButtonMargin,
      flagsButtonPadding: config.flagsButtonPadding,
      pickerDialogStyle: config.pickerDialogStyle,
      dialogType: config.dialogType,
      prefixIcon: config.prefixIcon,
      formatInput: config.formatInput,
      showExampleAsHint: config.showExampleAsHint,
      detectCountryOnPaste: config.detectCountryOnPaste,
      disableLengthCheck: config.disableLengthCheck ?? false,
      strictValidation: config.strictValidation,
      invalidMessage: config.invalidMessage ?? formMessages.invalidPhoneNumber,
      autovalidateMode: config.autovalidateMode,
      localizations: IntlPhoneFieldLocalizations(
        searchHint: formMessages.searchCountry,
        invalidNumber: formMessages.invalidPhoneNumber,
        requiredNumber: formMessages.loginFieldEnterPhoneValidatorEmpty,
      ),
      keyboardType: config.keyboardType ?? TextInputType.phone,
      textInputAction:
          textInputAction ?? config.textInputAction ?? TextInputAction.next,
      // telephoneNumber first, so iOS QuickType offers the number rather than
      // an email address in a field that only takes digits.
      autofillHints: config.autofillHints ??
          const <String>[
            AutofillHints.telephoneNumberNational,
            AutofillHints.telephoneNumber,
          ],
      onTap: config.onTap,
      onTapOutside: config.onTapOutside,
      onEditingComplete: config.onEditingComplete,
      onCountryChanged: config.onCountryChanged,
      onSubmitted: (value) {
        config.onSubmitted?.call(value);
        onSubmitted?.call(value);
      },
      onChanged: (phone) {
        controller.updatePhoneNumber(phone);
        config.onChanged?.call((number: phone, value: phone.number));
      },
      onSaved: (phone) {
        if (phone == null) return;
        controller.updatePhoneNumber(phone);
        config.onSaved?.call((number: phone, value: phone.number));
      },
    );
  }
}
