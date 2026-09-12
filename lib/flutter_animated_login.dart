/// A beautiful animated login flow for Flutter.
///
/// One widget covers sign-in, one-time codes, sign-up, reset-password and
/// social providers, on every platform Flutter targets:
///
/// ```dart
/// FlutterAnimatedLogin(
///   onLogin: (data) async {
///     await api.sendOtp(data.name);
///     return null;   // null means success
///   },
///   onVerify: (data) async => api.verify(data.name, data.secret!),
/// )
/// ```
///
/// Pass a [FlutterAnimatedLoginController] to drive the flow yourself, a
/// [FormMessages] to translate it, and an [AnimatedLoginTheme] to brand it.
library;

export 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
export 'package:pinput/pinput.dart';

export 'src/controller.dart' show FlutterAnimatedLoginController, LoginStep;
export 'src/login.dart';
export 'src/reset_password.dart' show FlutterAnimatedReset;
export 'src/signup.dart' show FlutterAnimatedSignup;
// Only the controller type is exported; the String and BuildContext
// extensions in this file stay internal so they cannot collide with a
// consumer's own.
export 'src/utils/extension.dart' show TextFieldController;
export 'src/utils/form_messages.dart';
export 'src/utils/login_config.dart';
export 'src/utils/login_data.dart';
export 'src/utils/login_provider.dart';
export 'src/utils/page_config.dart';
export 'src/utils/password_config.dart';
export 'src/utils/password_policy.dart';
export 'src/utils/reset_config.dart';
export 'src/utils/signup_config.dart';
export 'src/utils/signup_data.dart';
export 'src/utils/signup_field.dart';
export 'src/utils/theme.dart';
export 'src/utils/verify_config.dart';
export 'src/verify.dart' show FlutterAnimatedVerify;
export 'src/widget/page.dart' show PageBuilder, PageWidget;
export 'src/widget/password_strength.dart'
    show PasswordRequirementList, PasswordStrengthMeter;
export 'src/widget/title.dart' show TitleWidget;
