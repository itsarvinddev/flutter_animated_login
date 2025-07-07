// File: src/widgets/fields/email_field.dart
import 'package:flutter/material.dart';

import '../../theme/auth_theme_extension.dart';
import '../../utils/form_utils.dart';

/// A styled email input field
class EmailField extends StatelessWidget {
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

  const EmailField({
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
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    final effectiveDecoration = decoration ??
        FormUtils.createInputDecoration(
          label: label,
          hint: hint,
          prefixIcon: const Icon(Icons.email_outlined),
          borderColor: authTheme.textFieldBorderColor,
          focusColor: authTheme.textFieldFocusColor,
          errorColor: authTheme.textFieldErrorColor,
        );

    return TextFormField(
      controller: controller,
      decoration: effectiveDecoration,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      style: TextStyle(color: authTheme.textFieldTextColor),
      cursorColor: authTheme.textFieldFocusColor,
      autocorrect: false,
      enableSuggestions: true,
      autofillHints: const [AutofillHints.email],
    );
  }
}
