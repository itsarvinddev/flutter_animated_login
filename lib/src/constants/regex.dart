// File: src/constants/regex.dart

/// Regular expressions for validation
class Regexes {
  /// Email validation regex
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation regex (basic)
  static final RegExp phone = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  /// Password strength regex (minimum 8 chars, at least 1 letter and 1 number)
  static final RegExp passwordStrength = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  /// Username validation regex (3-20 chars, letters, numbers, underscores, hyphens)
  static final RegExp username = RegExp(
    r'^[a-zA-Z0-9_-]{3,20}$',
  );

  /// OTP validation regex (digits only)
  static final RegExp otp = RegExp(
    r'^\d+$',
  );

  Regexes._();
}
