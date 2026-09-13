import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

import '../demo_page.dart';
import '../fake_auth.dart';

/// Every user-facing string, in Spanish.
///
/// The package ships English defaults and takes no localization dependency:
/// hand [LoginConfig.messages] a [FormMessages] built from whatever your app
/// already uses — `AppLocalizations`, `intl`, a map from your CMS. Anything
/// left out keeps its English default, so this list can grow without breaking
/// you.
const FormMessages _spanish = FormMessages(
  signUp: 'Crear cuenta',
  signUpShort: 'Registrarse',
  signIn: 'Iniciar sesión',
  continueButton: 'Continuar',
  forgotPassword: '¿Olvidaste tu contraseña?',
  createAccountLong: 'Crea una cuenta para empezar.',
  confirmPassword: 'Confirmar contraseña*',
  reEnterPassword: 'Vuelve a escribir tu contraseña',
  passwordsUnmatched: 'Las contraseñas no coinciden',
  passwordIsRequired: 'La contraseña es obligatoria',
  enterYourPassword: 'Escribe tu contraseña',
  password: 'Contraseña*',
  showPassword: 'Mostrar contraseña',
  hidePassword: 'Ocultar contraseña',
  capsLockOn: 'El bloqueo de mayúsculas está activado',
  passwordTooShort: 'Usa al menos {min} caracteres',
  passwordTooLong: 'Usa como máximo {max} caracteres',
  passwordNeedsUppercase: 'Añade una letra mayúscula',
  passwordNeedsLowercase: 'Añade una letra minúscula',
  passwordNeedsDigit: 'Añade un número',
  passwordNeedsSpecial: 'Añade un carácter especial',
  passwordNotAllowed: 'Esta contraseña no está permitida',
  passwordTooWeak: 'Esta contraseña es demasiado débil',
  strengthWeak: 'Débil',
  strengthFair: 'Aceptable',
  strengthGood: 'Buena',
  strengthStrong: 'Fuerte',
  loginFieldEnterPhone: 'Escribe tu teléfono',
  loginFieldEnterEmailOrPhone: 'Escribe tu correo o teléfono',
  loginFieldEnterEmail: 'Escribe tu correo',
  phone: 'Teléfono*',
  emailOrPhone: 'Correo o teléfono*',
  email: 'Correo*',
  loginFieldEnterPhoneValidatorEmpty: 'Escribe tu correo o teléfono',
  loginFieldEnterPhoneValidatorInvalid:
      'Escribe un correo o un teléfono válido',
  invalidEmail: 'Escribe una dirección de correo válida',
  invalidPhoneNumber: 'Escribe un número de teléfono válido',
  searchCountry: 'Buscar país',
  resendOTP: 'Reenviar código',
  otpSentToEmail: 'Escribe el código enviado a tu correo',
  otpSentToPhone: 'Escribe el código enviado a tu teléfono',
  otpFieldLabel: 'Código de un solo uso',
  edit: 'Editar',
  resendLimitReached: 'No quedan intentos, inténtalo más tarde',
  resetTitle: 'Restablecer la contraseña',
  resetSubtitle: 'Te enviaremos un enlace para restablecerla.',
  resetButton: 'Restablecer contraseña',
  resetLinkSent: 'Enlace de restablecimiento enviado',
  invalidFormData: 'Datos no válidos, completa todos los campos',
  errorTitle: 'Error',
  successTitle: 'Listo',
  orDivider: 'O',
  consentRequired: 'Acepta los términos para continuar',
  useOtpInstead: 'Usar un código de un solo uso',
  usePasswordInstead: 'Usar una contraseña',
);

/// Runs the whole flow — login, code, signup, reset — with [_spanish].
class LocalizationDemo extends StatefulWidget {
  /// Creates the localization demo.
  const LocalizationDemo({super.key});

  @override
  State<LocalizationDemo> createState() => _LocalizationDemoState();
}

class _LocalizationDemoState extends State<LocalizationDemo> {
  final DemoEventLog _log = DemoEventLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  /// One callback serves both paths: [LoginData.method] says which one ran,
  /// so there is no need to guess from [LoginData.secret].
  Future<String?> _signIn(LoginData data) async {
    if (data.method == LoginMethod.otp) {
      final sendError = await FakeAuth.sendOtp(data.name);
      if (sendError != null) {
        _log.failure(sendError);
        return sendError;
      }
      _log.success('Código ${FakeAuth.otp} enviado a ${data.name}');
      return null;
    }

    final error = await FakeAuth.signIn(data.name, data.secret ?? '');
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Sesión iniciada como ${data.name}');
    return null;
  }

  Future<String?> _verifyCode(LoginData data) async {
    final error = await FakeAuth.verifyOtp(data.secret ?? '');
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Sesión iniciada como ${data.name}');
    return null;
  }

  Future<String?> _signUp(SignupData data) async {
    final error = await FakeAuth.signUp(data);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Cuenta creada para ${data.name}');
    return null;
  }

  Future<String?> _sendResetLink(String identifier) async {
    final error = await FakeAuth.sendResetLink(identifier);
    if (error != null) {
      _log.failure(error);
      return error;
    }
    _log.success('Enlace enviado a $identifier');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Localization',
      log: _log,
      child: FlutterAnimatedLogin(
        // otpAndPassword shows both paths, so the toggle's strings show too.
        loginType: LoginType.otpAndPassword,
        onLogin: _signIn,
        onSignup: _signUp,
        onResetPassword: _sendResetLink,
        onVerify: _verifyCode,
        config: const PageConfig(useScaffold: false),
        loginConfig: const LoginConfig(
          title: 'Hola de nuevo',
          subtitle: 'Cada cadena viene de FormMessages.',
          logo: Icon(Icons.translate_outlined, size: 64),
          loginFieldInputType: LoginFieldInputType.email,
          messages: _spanish,
        ),
      ),
    );
  }
}
