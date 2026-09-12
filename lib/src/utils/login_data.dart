import 'package:flutter/foundation.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';

/// Which path the user took to sign in.
enum LoginMethod {
  /// A one-time code sent to the identifier.
  otp,

  /// A password typed into the form.
  password,

  /// A social or federated provider.
  provider,
}

/// What [FlutterAnimatedLogin.onLogin], [FlutterAnimatedLogin.onVerify] and
/// [FlutterAnimatedLogin.onResendOtp] receive.
@immutable
class LoginData {
  /// Who is signing in.
  ///
  /// An email address exactly as typed, or a phone number in E.164 form
  /// (`+919876543210`) — never a mix, and never a national number without its
  /// country code.
  final String name;

  /// The secret that proves it.
  ///
  /// The password for [LoginMethod.password], the one-time code for
  /// [LoginMethod.otp], and `null` when there is nothing to prove yet — a
  /// resend request, or the first leg of an OTP sign-in.
  final String? secret;

  /// How the user is signing in.
  ///
  /// Lets one `onLogin` serve [LoginType.otpAndPassword] without inspecting
  /// [secret] to guess which path ran.
  final LoginMethod method;

  /// The parsed phone number, when [name] is a phone number.
  ///
  /// Gives you the country and the national part without re-parsing [name].
  /// `null` when the user signed in with an email address.
  final PhoneNumber? phoneNumber;

  /// Whether the consent checkbox was ticked, when [ConsentConfig] is in use.
  final bool acceptedTerms;

  /// Creates the payload handed to a login callback.
  const LoginData({
    required this.name,
    this.secret,
    this.method = LoginMethod.otp,
    this.phoneNumber,
    this.acceptedTerms = false,
  });

  /// Whether [name] is a phone number rather than an email address.
  bool get isPhone => phoneNumber != null;

  /// A copy of this payload with the given fields replaced.
  LoginData copyWith({
    String? name,
    String? secret,
    LoginMethod? method,
    PhoneNumber? phoneNumber,
    bool? acceptedTerms,
  }) {
    return LoginData(
      name: name ?? this.name,
      secret: secret ?? this.secret,
      method: method ?? this.method,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    );
  }

  /// Redacts [secret], so logging a [LoginData] cannot leak a password or a
  /// one-time code.
  @override
  String toString() =>
      'LoginData(name: $name, method: ${method.name}, '
      'secret: ${secret == null ? 'null' : '***'}, '
      'acceptedTerms: $acceptedTerms)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginData &&
          other.name == name &&
          other.secret == secret &&
          other.method == method &&
          other.phoneNumber == phoneNumber &&
          other.acceptedTerms == acceptedTerms;

  @override
  int get hashCode =>
      Object.hash(name, secret, method, phoneNumber, acceptedTerms);
}
