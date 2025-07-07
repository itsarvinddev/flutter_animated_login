// File: src/widgets/fields/password_field.dart
import 'package:flutter/material.dart';

import '../../theme/auth_theme_extension.dart';
import '../../utils/form_utils.dart';

/// A styled password input field with show/hide toggle
class PasswordField extends StatelessWidget {
  /// Text controller
  final TextEditingController controller;

  /// Obscure text notifier
  final ValueNotifier<bool> obscureText;

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

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
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

    return ValueListenableBuilder<bool>(
      valueListenable: obscureText,
      builder: (context, isObscured, child) {
        final effectiveDecoration = decoration ??
            FormUtils.createInputDecoration(
              label: label,
              hint: hint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: authTheme.textFieldHintColor,
                ),
                onPressed: () => obscureText.value = !isObscured,
              ),
              borderColor: authTheme.textFieldBorderColor,
              focusColor: authTheme.textFieldFocusColor,
              errorColor: authTheme.textFieldErrorColor,
            );

        return TextFormField(
          controller: controller,
          decoration: effectiveDecoration,
          obscureText: isObscured,
          keyboardType: TextInputType.visiblePassword,
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
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }
}
