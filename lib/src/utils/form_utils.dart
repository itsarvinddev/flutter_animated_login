
// File: src/utils/form_utils.dart
import 'package:flutter/material.dart';

/// Utilities for form handling
class FormUtils {
  /// Create a standard input decoration
  static InputDecoration createInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? borderColor,
    Color? focusColor,
    Color? errorColor,
    double borderRadius = 8.0,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey.shade400,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: focusColor ?? Colors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: errorColor ?? Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: errorColor ?? Colors.red,
          width: 2,
        ),
      ),
    );
  }
  
  /// Create a standard button style
  static ButtonStyle createButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    double borderRadius = 8.0,
    double elevation = 2.0,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      minimumSize: const Size(double.infinity, 50),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  /// Create a standard outlined button style
  static ButtonStyle createOutlinedButtonStyle({
    required Color borderColor,
    required Color foregroundColor,
    double borderRadius = 8.0,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      minimumSize: const Size(double.infinity, 50),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  /// Create a text button style
  static ButtonStyle createTextButtonStyle({
    required Color foregroundColor,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Private constructor to prevent instantiation
  FormUtils._();
}