import 'package:flutter_animated_login/flutter_animated_login.dart';

/// Stands in for the backend a real app would call.
///
/// Every method waits [latency] before answering, so the demos exercise the
/// same spinner, disabled-button and error paths a real network call would.
/// Each returns `null` on success and a message on failure — exactly the
/// contract [FlutterAnimatedLogin]'s callbacks expect.
class FakeAuth {
  const FakeAuth._();

  /// The only phone number these demos know about, in E.164 form.
  static const String phone = '+919876543210';

  /// [phone] without its country code, for prefilling the phone field.
  static const String phoneNational = '9876543210';

  /// The only email address these demos know about.
  static const String email = 'demo@example.com';

  /// The only one-time code these demos accept.
  static const String otp = '123456';

  /// The only password these demos accept.
  static const String password = 'flutter1234';

  /// How long every call pretends the network took.
  static const Duration latency = Duration(milliseconds: 900);

  /// Sends a one-time code to [identifier].
  static Future<String?> sendOtp(String identifier) async {
    await Future<void>.delayed(latency);
    if (_isKnown(identifier)) return null;
    return 'No account for $identifier. Try $phone or $email.';
  }

  /// Checks the one-time code the user typed.
  static Future<String?> verifyOtp(String code) async {
    await Future<void>.delayed(latency);
    if (code == otp) return null;
    return 'That code is wrong. This demo only accepts $otp.';
  }

  /// Signs in with a password.
  static Future<String?> signIn(String identifier, String secret) async {
    await Future<void>.delayed(latency);
    if (!_isKnown(identifier)) return 'No account for $identifier.';
    if (secret == password) return null;
    return 'Wrong password. This demo only accepts "$password".';
  }

  /// Creates an account.
  static Future<String?> signUp(SignupData data) async {
    await Future<void>.delayed(latency);
    if (_isKnown(data.name ?? '')) {
      return 'An account for ${data.name} already exists.';
    }
    return null;
  }

  /// Sends a password-reset link to [identifier].
  static Future<String?> sendResetLink(String identifier) async {
    await Future<void>.delayed(latency);
    if (_isKnown(identifier)) return null;
    return 'No account for $identifier.';
  }

  /// Signs in with a social provider.
  ///
  /// Google and Apple succeed; anything else fails, so both halves of
  /// [LoginProvider.callback]'s contract are visible in the demo.
  static Future<String?> signInWithProvider(String provider) async {
    await Future<void>.delayed(latency);
    if (provider == 'Google' || provider == 'Apple') return null;
    return '$provider is not configured in this demo.';
  }

  static bool _isKnown(String identifier) =>
      identifier == phone || identifier == email;
}
