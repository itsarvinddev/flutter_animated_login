import 'package:flutter/foundation.dart';

import 'form_messages.dart';

/// How good a password is, as judged by [PasswordPolicy.strengthOf].
enum PasswordStrength {
  /// Nothing typed yet.
  empty,

  /// Trivially guessable.
  weak,

  /// Better than nothing, still short or single-class.
  fair,

  /// Long enough and mixed enough for everyday use.
  good,

  /// Long and varied.
  strong;

  /// A number in `0.0`–`1.0`, for driving a progress bar.
  double get score => switch (this) {
        PasswordStrength.empty => 0,
        PasswordStrength.weak => 0.25,
        PasswordStrength.fair => 0.5,
        PasswordStrength.good => 0.75,
        PasswordStrength.strong => 1,
      };

  /// The localized label for this strength.
  String label(FormMessages messages) => switch (this) {
        PasswordStrength.empty => '',
        PasswordStrength.weak => messages.strengthWeak,
        PasswordStrength.fair => messages.strengthFair,
        PasswordStrength.good => messages.strengthGood,
        PasswordStrength.strong => messages.strengthStrong,
      };
}

/// Rules a password must satisfy.
///
/// The default is [PasswordPolicy.none], which requires only that the field is
/// not empty — the behaviour every version before 1.0.0 had. Opt in to a real
/// policy on the screens where it matters:
///
/// ```dart
/// SignupConfig(
///   passwordTextFiledConfig: PasswordTextFiledConfig(
///     policy: const PasswordPolicy(minLength: 10, requireDigit: true),
///     showStrengthMeter: true,
///   ),
/// )
/// ```
@immutable
class PasswordPolicy {
  /// Fewest characters accepted.
  final int minLength;

  /// Most characters accepted, or `null` for no upper bound.
  final int? maxLength;

  /// Whether at least one `A`–`Z` is required.
  final bool requireUppercase;

  /// Whether at least one `a`–`z` is required.
  final bool requireLowercase;

  /// Whether at least one digit is required.
  final bool requireDigit;

  /// Whether at least one character outside letters and digits is required.
  final bool requireSpecial;

  /// Patterns the password must not match — the user's own email address, the
  /// product name, a leaked-password list.
  final List<Pattern> disallow;

  /// The weakest [PasswordStrength] accepted. [PasswordStrength.empty] means
  /// strength is not checked.
  final PasswordStrength minStrength;

  /// Creates a policy. Every rule is off by default except [minLength].
  const PasswordPolicy({
    this.minLength = 8,
    this.maxLength,
    this.requireUppercase = false,
    this.requireLowercase = false,
    this.requireDigit = false,
    this.requireSpecial = false,
    this.disallow = const <Pattern>[],
    this.minStrength = PasswordStrength.empty,
  });

  /// A policy that checks nothing beyond "not empty".
  const PasswordPolicy.none()
      : minLength = 0,
        maxLength = null,
        requireUppercase = false,
        requireLowercase = false,
        requireDigit = false,
        requireSpecial = false,
        disallow = const <Pattern>[],
        minStrength = PasswordStrength.empty;

  /// A reasonable starting point: 8 characters with a letter and a digit.
  const PasswordPolicy.standard()
      : minLength = 8,
        maxLength = null,
        requireUppercase = false,
        requireLowercase = true,
        requireDigit = true,
        requireSpecial = false,
        disallow = const <Pattern>[],
        minStrength = PasswordStrength.empty;

  /// Stricter: 12 characters across all four character classes.
  const PasswordPolicy.strict()
      : minLength = 12,
        maxLength = null,
        requireUppercase = true,
        requireLowercase = true,
        requireDigit = true,
        requireSpecial = true,
        disallow = const <Pattern>[],
        minStrength = PasswordStrength.good;

  /// Whether this policy checks anything at all.
  bool get isEmpty =>
      minLength <= 0 &&
      maxLength == null &&
      !requireUppercase &&
      !requireLowercase &&
      !requireDigit &&
      !requireSpecial &&
      disallow.isEmpty &&
      minStrength == PasswordStrength.empty;

  /// Every rule [value] breaks, already localized, in the order they should be
  /// shown. Empty when the password is acceptable.
  List<String> violations(String value,
      [FormMessages messages = FormMessages.fallback]) {
    final problems = <String>[];
    if (value.length < minLength) {
      problems.add(messages.passwordTooShortFor(minLength));
    }
    final max = maxLength;
    if (max != null && value.length > max) {
      problems.add(messages.passwordTooLongFor(max));
    }
    if (requireUppercase && !_hasUpper.hasMatch(value)) {
      problems.add(messages.passwordNeedsUppercase);
    }
    if (requireLowercase && !_hasLower.hasMatch(value)) {
      problems.add(messages.passwordNeedsLowercase);
    }
    if (requireDigit && !_hasDigit.hasMatch(value)) {
      problems.add(messages.passwordNeedsDigit);
    }
    if (requireSpecial && !_hasSpecial.hasMatch(value)) {
      problems.add(messages.passwordNeedsSpecial);
    }
    for (final pattern in disallow) {
      if (value.contains(pattern)) {
        problems.add(messages.passwordNotAllowed);
        break;
      }
    }
    if (minStrength != PasswordStrength.empty &&
        strengthOf(value).index < minStrength.index) {
      problems.add(messages.passwordTooWeak);
    }
    return problems;
  }

  /// The first violation of [value], or `null` when it satisfies the policy.
  ///
  /// Shaped for [FormFieldValidator].
  String? validate(String? value,
      [FormMessages messages = FormMessages.fallback]) {
    final text = value ?? '';
    if (text.isEmpty) return messages.passwordIsRequired;
    final problems = violations(text, messages);
    return problems.isEmpty ? null : problems.first;
  }

  /// Rates [value] on length and character variety.
  ///
  /// This is a heuristic for a progress bar, not a security guarantee: it
  /// knows nothing about dictionary words or breach corpora.
  PasswordStrength strengthOf(String value) {
    if (value.isEmpty) return PasswordStrength.empty;

    var classes = 0;
    if (_hasLower.hasMatch(value)) classes++;
    if (_hasUpper.hasMatch(value)) classes++;
    if (_hasDigit.hasMatch(value)) classes++;
    if (_hasSpecial.hasMatch(value)) classes++;

    // A password made of one repeated character is weak at any length.
    if (value.split('').toSet().length <= 2) return PasswordStrength.weak;

    var points = 0;
    if (value.length >= 8) points++;
    if (value.length >= 12) points++;
    if (value.length >= 16) points++;
    points += classes - 1;

    if (value.length < 6 || points <= 1) return PasswordStrength.weak;
    if (points <= 3) return PasswordStrength.fair;
    if (points <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static final RegExp _hasUpper = RegExp('[A-Z]');
  static final RegExp _hasLower = RegExp('[a-z]');
  static final RegExp _hasDigit = RegExp('[0-9]');
  static final RegExp _hasSpecial = RegExp('[^A-Za-z0-9]');

  /// A copy of this policy with the given rules replaced.
  PasswordPolicy copyWith({
    int? minLength,
    int? maxLength,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireDigit,
    bool? requireSpecial,
    List<Pattern>? disallow,
    PasswordStrength? minStrength,
  }) {
    return PasswordPolicy(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireDigit: requireDigit ?? this.requireDigit,
      requireSpecial: requireSpecial ?? this.requireSpecial,
      disallow: disallow ?? this.disallow,
      minStrength: minStrength ?? this.minStrength,
    );
  }
}
