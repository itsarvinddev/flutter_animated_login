import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One extra field on the signup screen, beyond the identifier and password.
///
/// Whatever the user types arrives in [SignupData.additionalSignupData] keyed
/// by [key]:
///
/// ```dart
/// SignupConfig(
///   additionalFields: [
///     SignupField(key: 'name', label: 'Full name', isRequired: true),
///     SignupField(
///       key: 'age',
///       label: 'Age',
///       keyboardType: TextInputType.number,
///       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
///     ),
///   ],
/// )
/// ```
///
/// For anything a text field cannot express — a dropdown, a date picker, a
/// checkbox — use [SignupConfig.customFields] instead.
@immutable
class SignupField {
  /// The key this field's value takes in [SignupData.additionalSignupData].
  ///
  /// Must be unique within one [SignupConfig].
  final String key;

  /// Label shown above the field. Defaults to [key].
  final String? label;

  /// Placeholder shown while the field is empty.
  final String? hint;

  /// Text the field starts with.
  final String? initialValue;

  /// Whether an empty value fails validation.
  final bool isRequired;

  /// Message shown when [isRequired] is set and the field is empty.
  /// Defaults to "<label> is required".
  final String? requiredMessage;

  /// Extra validation, run after the [isRequired] check passes.
  final FormFieldValidator<String>? validator;

  /// Replaces the generated decoration entirely.
  final InputDecoration? decoration;

  /// Which keyboard to show.
  final TextInputType? keyboardType;

  /// Which action key the keyboard shows.
  final TextInputAction? textInputAction;

  /// Restricts or reformats what can be typed.
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill categories this field belongs to.
  final Iterable<String>? autofillHints;

  /// How to capitalize typed text.
  final TextCapitalization textCapitalization;

  /// Whether to hide the typed text.
  final bool obscureText;

  /// Most characters accepted.
  final int? maxLength;

  /// Most lines shown before the field scrolls.
  final int? maxLines;

  /// Fewest lines the field occupies.
  final int? minLines;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether this field takes focus when the signup screen opens.
  final bool autofocus;

  /// Style of the typed text.
  final TextStyle? style;

  /// When this widget is supplied, it is rendered above the field.
  final Widget? header;

  /// Creates the specification for one extra signup field.
  const SignupField({
    required this.key,
    this.label,
    this.hint,
    this.initialValue,
    this.isRequired = false,
    this.requiredMessage,
    this.validator,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.style,
    this.header,
  });

  /// Runs [isRequired] and then [validator] against [value].
  String? validate(String? value) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return requiredMessage ?? '${label ?? key} is required';
    }
    return validator?.call(value);
  }

  /// A copy of this specification with the given properties replaced.
  SignupField copyWith({
    String? key,
    String? label,
    String? hint,
    String? initialValue,
    bool? isRequired,
    String? requiredMessage,
    FormFieldValidator<String>? validator,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    TextCapitalization? textCapitalization,
    bool? obscureText,
    int? maxLength,
    int? maxLines,
    int? minLines,
    bool? enabled,
    bool? autofocus,
    TextStyle? style,
    Widget? header,
  }) {
    return SignupField(
      key: key ?? this.key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      initialValue: initialValue ?? this.initialValue,
      isRequired: isRequired ?? this.isRequired,
      requiredMessage: requiredMessage ?? this.requiredMessage,
      validator: validator ?? this.validator,
      decoration: decoration ?? this.decoration,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      autofillHints: autofillHints ?? this.autofillHints,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      obscureText: obscureText ?? this.obscureText,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      enabled: enabled ?? this.enabled,
      autofocus: autofocus ?? this.autofocus,
      style: style ?? this.style,
      header: header ?? this.header,
    );
  }
}

/// Builds a signup control the [SignupField] specification cannot express.
///
/// Write into [values] and the package forwards the map to
/// [SignupData.additionalSignupData] on submit:
///
/// ```dart
/// SignupConfig(
///   customFields: [
///     (context, values) => CheckboxListTile(
///           title: const Text('Send me product news'),
///           value: values['newsletter'] == 'true',
///           onChanged: (v) => values['newsletter'] = '$v',
///         ),
///   ],
/// )
/// ```
typedef SignupFieldBuilder =
    Widget Function(BuildContext context, Map<String, String> values);

/// Asks the user to accept terms before the form can be submitted.
///
/// ```dart
/// FlutterAnimatedLogin(
///   consent: ConsentConfig(
///     label: Text.rich(TextSpan(text: 'I accept the terms')),
///     isRequired: true,
///   ),
/// )
/// ```
@immutable
class ConsentConfig {
  /// The text beside the checkbox. Use [Text.rich] for tappable links.
  final Widget label;

  /// Whether the primary button stays disabled until the box is ticked.
  final bool isRequired;

  /// Whether the box starts ticked.
  final bool initialValue;

  /// Whether to show the checkbox on the login screen.
  final bool showOnLogin;

  /// Whether to show the checkbox on the signup screen.
  final bool showOnSignup;

  /// Called whenever the box is ticked or unticked.
  final ValueChanged<bool>? onChanged;

  /// Replaces [FormMessages.consentRequired] when the box is required and
  /// still unticked.
  final String? errorText;

  /// How the checkbox and its label are laid out.
  final ListTileControlAffinity controlAffinity;

  /// Padding around the checkbox row.
  final EdgeInsetsGeometry? contentPadding;

  /// Creates a consent gate.
  const ConsentConfig({
    required this.label,
    this.isRequired = false,
    this.initialValue = false,
    this.showOnLogin = false,
    this.showOnSignup = true,
    this.onChanged,
    this.errorText,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.contentPadding = EdgeInsets.zero,
  });

  /// A copy of this configuration with the given properties replaced.
  ConsentConfig copyWith({
    Widget? label,
    bool? isRequired,
    bool? initialValue,
    bool? showOnLogin,
    bool? showOnSignup,
    ValueChanged<bool>? onChanged,
    String? errorText,
    ListTileControlAffinity? controlAffinity,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return ConsentConfig(
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
      initialValue: initialValue ?? this.initialValue,
      showOnLogin: showOnLogin ?? this.showOnLogin,
      showOnSignup: showOnSignup ?? this.showOnSignup,
      onChanged: onChanged ?? this.onChanged,
      errorText: errorText ?? this.errorText,
      controlAffinity: controlAffinity ?? this.controlAffinity,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
