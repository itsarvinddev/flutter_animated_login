// File: src/widgets/fields/phone_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/auth_theme_extension.dart';
import '../../utils/form_utils.dart';

/// A styled phone number input field with country code
class PhoneField extends StatelessWidget {
  /// Text controller
  final TextEditingController controller;

  /// Field label
  final String label;

  /// Field hint
  final String? hint;

  /// Field validator
  final FormFieldValidator<String>? validator;

  /// Custom decoration
  final InputDecoration? decoration;

  /// Text input action
  final TextInputAction? textInputAction;

  /// On submit callback
  final ValueChanged<String>? onSubmitted;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto validation mode
  final AutovalidateMode? autovalidateMode;

  /// Selected country code
  final ValueNotifier<String> countryCode;

  /// On country code changed callback
  final ValueChanged<String>? onCountryCodeChanged;

  const PhoneField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.decoration,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autovalidateMode,
    required this.countryCode,
    this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    return ValueListenableBuilder<String>(
      valueListenable: countryCode,
      builder: (context, code, child) {
        final effectiveDecoration = decoration ??
            FormUtils.createInputDecoration(
              label: label,
              hint: hint,
              prefixIcon: _buildCountryCodeButton(context, code, authTheme),
              borderColor: authTheme.textFieldBorderColor,
              focusColor: authTheme.textFieldFocusColor,
              errorColor: authTheme.textFieldErrorColor,
            );

        return TextFormField(
          controller: controller,
          decoration: effectiveDecoration,
          keyboardType: TextInputType.phone,
          textInputAction: textInputAction,
          validator: validator,
          autovalidateMode:
              autovalidateMode ?? AutovalidateMode.onUserInteraction,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          style: TextStyle(color: authTheme.textFieldTextColor),
          cursorColor: authTheme.textFieldFocusColor,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        );
      },
    );
  }

  Widget _buildCountryCodeButton(
    BuildContext context,
    String code,
    AuthThemeExtension authTheme,
  ) {
    return InkWell(
      onTap: () => _showCountryCodePicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: TextStyle(
                color: authTheme.textFieldTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: authTheme.textFieldHintColor,
              size: 16,
            ),
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: authTheme.textFieldBorderColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCountryCodePicker(BuildContext context) async {
    // This would be a more complete implementation in a real package
    // with a proper country code picker
    final selectedCode = await showDialog<String>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Select Country Code'),
        content: Text('This is a simplified placeholder for a country picker.'),
      ),
    );

    if (selectedCode != null && onCountryCodeChanged != null) {
      countryCode.value = selectedCode;
      onCountryCodeChanged!(selectedCode);
    }
  }
}
