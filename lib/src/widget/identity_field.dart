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
class IdentityField extends StatefulWidget {
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

  @override
  State<IdentityField> createState() => _IdentityFieldState();
}

class _IdentityFieldState extends State<IdentityField> {
  EmailPhoneTextFiledConfig get config => widget.config;
  FlutterAnimatedLoginController get controller => widget.controller;
  FormMessages get formMessages => widget.formMessages;
  LoginFieldInputType get loginFieldInputType => widget.loginFieldInputType;
  ValueChanged<String>? get onSubmitted => widget.onSubmitted;
  TextInputAction? get textInputAction => widget.textInputAction;

  // One node per variant, so that moving between them is a genuine focus
  // change. EditableText only opens its keyboard connection when its focus
  // *changes*: a field that mounts on an already-focused node never receives
  // input. A caller-supplied [EmailPhoneTextFiledConfig.focusNode] is used for
  // both variants instead, and never disposed here.
  FocusNode? _ownedEmailFocus;
  FocusNode? _ownedPhoneFocus;
  bool? _wasPhone;

  // The email field edits its own controller, mirrored to the shared
  // identifier controller in both directions, rather than the shared one.
  //
  // IntlPhoneField writes the shared controller in its initState. On the
  // email-to-phone swap that happens in the very frame the email field is
  // deactivated, and with formatInput on the write changes the text
  // ("2015550123" -> "(201) 555-0123") -- so a TextFormField still listening to
  // the shared controller was notified while deactivated: "Looking up a
  // deactivated widget's ancestor is unsafe". Mirroring only while in email
  // mode keeps the outgoing email field out of that notification entirely.
  final TextEditingController _emailController = TextEditingController();
  late TextEditingController _shared;

  @override
  void initState() {
    super.initState();
    _shared = controller.identifierController;
    _emailController.value = _shared.value;
    _shared.addListener(_sharedToEmail);
    _emailController.addListener(_emailToShared);
  }

  @override
  void didUpdateWidget(IdentityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = controller.identifierController;
    if (!identical(next, _shared)) {
      _shared.removeListener(_sharedToEmail);
      _shared = next;
      _shared.addListener(_sharedToEmail);
      _emailController.value = _shared.value;
    }
  }

  void _sharedToEmail() {
    // In phone mode the email field is gone or going; leave it alone.
    if (_wasPhone ?? false) return;
    if (_emailController.value == _shared.value) return;
    _emailController.value = _shared.value;
  }

  void _emailToShared() {
    if (_shared.value == _emailController.value) return;
    _shared.value = _emailController.value;
  }

  FocusNode get _emailFocus =>
      config.focusNode ??
      (_ownedEmailFocus ??= FocusNode(debugLabel: 'IdentityField.email'));

  FocusNode get _phoneFocus =>
      config.focusNode ??
      (_ownedPhoneFocus ??= FocusNode(debugLabel: 'IdentityField.phone'));

  @override
  void dispose() {
    _shared.removeListener(_sharedToEmail);
    _emailController.removeListener(_emailToShared);
    _emailController.dispose();
    _ownedEmailFocus?.dispose();
    _ownedPhoneFocus?.dispose();
    super.dispose();
  }

  bool get _isPhone => switch (loginFieldInputType) {
    LoginFieldInputType.phone => true,
    LoginFieldInputType.email => false,
    LoginFieldInputType.phoneOrEmail => controller.isPhone,
  };

  /// Carries keyboard focus across a swap between the email and phone fields.
  ///
  /// In [LoginFieldInputType.phoneOrEmail] the first digit typed replaces the
  /// email field with the phone field. Without this the new field mounted
  /// unfocused, the keyboard closed, and every keystroke after the first was
  /// dropped — phone entry in the default mode took one digit.
  void _carryFocusAcrossSwap(bool isPhone) {
    final was = _wasPhone;
    _wasPhone = isPhone;
    if (was == null || was == isPhone) return;

    final from = was ? _phoneFocus : _emailFocus;
    // Checked now, while the outgoing field is still mounted and focused.
    if (!from.hasFocus) return;
    final to = isPhone ? _phoneFocus : _emailFocus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!identical(from, to)) {
        to.requestFocus();
        return;
      }
      // A single caller-supplied node serves both fields. It still counts as
      // focused, so bounce it: the new field needs to see a change to open its
      // own keyboard connection.
      to.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) to.requestFocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _isPhone;
    _carryFocusAcrossSwap(isPhone);
    if (!isPhone && _emailController.value != _shared.value) {
      // Catch up on anything typed in phone mode. The copy back to the shared
      // controller is equal, so it notifies no one.
      _emailController.value = _shared.value;
    }
    return isPhone ? _buildPhone(context) : _buildEmail(context);
  }

  InputDecoration _decoration(BuildContext context, {required bool isPhone}) {
    final supplied = isPhone ? config.decoration : config.emailDecoration;
    if (supplied != null) return supplied;
    if (config.decoration != null) return config.decoration!;

    final radius =
        AnimatedLoginTheme.of(context).fieldRadius ??
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
      LoginFieldInputType.phoneOrEmail =>
        isPhone
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
      controller: _emailController,
      focusNode: _emailFocus,
      // An address reads left-to-right in every locale. Inheriting RTL lets
      // the bidi algorithm move neutral characters such as a trailing dot.
      textDirection: TextDirection.ltr,
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
      autofillHints:
          config.autofillHints ??
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
    // A phone number reads left-to-right in every locale. Left to inherit an
    // RTL Directionality, the space-separated digit groups were reordered by
    // the bidi algorithm, so the UAE number "50 123 4567" displayed as
    // "4567 123 50". IntlPhoneField does not take a text direction, so the
    // whole field is laid out LTR: country code first, as the number is
    // written.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _phoneField(context),
    );
  }

  Widget _phoneField(BuildContext context) {
    return IntlPhoneField(
      key: const ValueKey<String>('flutter_animated_login.identity.phone'),
      formFieldKey: config.formFieldKey,
      controller: controller.identifierController,
      phoneController: config.phoneController,
      focusNode: _phoneFocus,
      // The controller owns the country: a flow controller created by the
      // widget starts from EmailPhoneTextFiledConfig.initialCountryCode, and
      // one you pass starts from its own. Preferring the config here meant
      // reset() could restore the controller's country but never the picker's.
      initialCountryCode: controller.countryIsoCode,
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
        invalidCharacters: formMessages.digitsOnly,
        noCountriesFound: formMessages.noCountriesFound,
        countrySelectorLabel: formMessages.countrySelectorLabel,
        favoritesLabel: formMessages.favoriteCountries,
      ),
      keyboardType: config.keyboardType ?? TextInputType.phone,
      textInputAction:
          textInputAction ?? config.textInputAction ?? TextInputAction.next,
      // telephoneNumber first, so iOS QuickType offers the number rather than
      // an email address in a field that only takes digits.
      autofillHints:
          config.autofillHints ??
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
