import 'package:flutter/foundation.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';

/// What [FlutterAnimatedLogin.onSignup] receives.
@immutable
class SignupData {
  /// Who is signing up: an email address as typed, or a phone number in E.164
  /// form.
  final String? name;

  /// The password they chose.
  final String? password;

  /// Everything the extra signup fields collected, keyed by [SignupField.key].
  ///
  /// The confirm-password value is **not** in here. It is a check on the form,
  /// not data your backend asked for; set
  /// [SignupConfig.includeConfirmPasswordInData] if you really need it.
  final Map<String, String> additionalSignupData;

  /// The parsed phone number, when [name] is a phone number.
  final PhoneNumber? phoneNumber;

  /// Whether the consent checkbox was ticked, when [ConsentConfig] is in use.
  final bool acceptedTerms;

  /// Creates the payload handed to [FlutterAnimatedLogin.onSignup].
  const SignupData({
    this.name,
    this.password,
    Map<String, String>? additionalSignupData,
    this.phoneNumber,
    this.acceptedTerms = false,
  }) : additionalSignupData = additionalSignupData ?? const <String, String>{};

  /// Creates a payload from the signup form.
  const SignupData.fromSignupForm({
    required this.name,
    required this.password,
    Map<String, String>? additionalSignupData,
    this.phoneNumber,
    this.acceptedTerms = false,
  }) : additionalSignupData = additionalSignupData ?? const <String, String>{};

  /// Creates a payload for a social provider that needs extra details before
  /// the account can be created.
  const SignupData.fromProvider({
    required this.additionalSignupData,
    this.acceptedTerms = false,
  }) : name = null,
       password = null,
       phoneNumber = null;

  /// Whether [name] is a phone number rather than an email address.
  bool get isPhone => phoneNumber != null;

  /// A copy of this payload with the given fields replaced.
  SignupData copyWith({
    String? name,
    String? password,
    Map<String, String>? additionalSignupData,
    PhoneNumber? phoneNumber,
    bool? acceptedTerms,
  }) {
    return SignupData(
      name: name ?? this.name,
      password: password ?? this.password,
      additionalSignupData: additionalSignupData ?? this.additionalSignupData,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    );
  }

  /// Redacts [password], so logging a [SignupData] cannot leak it.
  @override
  String toString() =>
      'SignupData(name: $name, '
      'password: ${password == null ? 'null' : '***'}, '
      'additionalSignupData: $additionalSignupData, '
      'acceptedTerms: $acceptedTerms)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignupData &&
          other.name == name &&
          other.password == password &&
          other.phoneNumber == phoneNumber &&
          other.acceptedTerms == acceptedTerms &&
          // Maps compare by identity by default, which made two payloads
          // carrying the same entries unequal.
          _sameEntries(other.additionalSignupData, additionalSignupData);

  @override
  int get hashCode => Object.hash(
    name,
    password,
    phoneNumber,
    acceptedTerms,
    // Order-independent, so two maps built in a different order agree.
    Object.hashAllUnordered(
      additionalSignupData.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  static bool _sameEntries(Map<String, String> a, Map<String, String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
