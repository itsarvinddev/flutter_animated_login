// File: src/utils/validation.dart
import '../constants/regex.dart';

/// Utility class for form field validation
class ValidationUtils {
  /// Validate email address
  static String? validateEmail(String? value, {bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter your email';
    }

    if (value != null && value.isNotEmpty && !Regexes.email.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter your password';
    }

    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value, {bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter your phone number';
    }

    if (value != null && value.isNotEmpty && !Regexes.phone.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate OTP code
  static String? validateOtp(String? value,
      {int length = 6, bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter the verification code';
    }

    if (value != null && value.isNotEmpty) {
      if (value.length != length) {
        return 'Code must be $length digits';
      }

      if (!Regexes.otp.hasMatch(value)) {
        return 'Code must contain only numbers';
      }
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value, {bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter your username';
    }

    if (value != null &&
        value.isNotEmpty &&
        !Regexes.username.hasMatch(value)) {
      return 'Username must be 3-20 characters and contain only letters, numbers, underscores or hyphens';
    }

    return null;
  }

  /// Validate that a field is not empty
  static String? validateNotEmpty(String? value, {String fieldName = 'field'}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }

    return null;
  }

  /// Private constructor to prevent instantiation
  ValidationUtils._();
}
