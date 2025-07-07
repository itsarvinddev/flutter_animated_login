// File: src/controllers/auth_state.dart
import 'package:equatable/equatable.dart';

import '../constants/enums.dart';
import '../models/auth_data.dart';
import '../models/auth_result.dart';

/// State of the authentication flow
class AuthState extends Equatable {
  /// Current auth page
  final AuthPage currentPage;

  /// Previous auth page (for animations)
  final AuthPage previousPage;

  /// Loading state
  final bool isLoading;

  /// Success state
  final bool isSuccess;

  /// Error message
  final String? errorMessage;

  /// Success message
  final String? successMessage;

  /// Identifier for verification
  final String? verificationIdentifier;

  /// Callback for login action
  final Future<AuthResult> Function(LoginData)? onLogin;

  /// Callback for signup action
  final Future<AuthResult> Function(SignupData)? onSignup;

  /// Callback for password reset action
  final Future<AuthResult> Function(String)? onRecoverPassword;

  /// Callback for verification action
  final Future<AuthResult> Function(VerifyData)? onVerify;

  /// Callback for resend code action
  final Future<AuthResult> Function(String)? onResendCode;

  /// Callback for OAuth provider auth
  final Future<AuthResult> Function(AuthProvider)? onProviderAuth;

  const AuthState({
    this.currentPage = AuthPage.login,
    this.previousPage = AuthPage.login,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.verificationIdentifier,
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onVerify,
    this.onResendCode,
    this.onProviderAuth,
  });

  @override
  List<Object?> get props => [
        currentPage,
        previousPage,
        isLoading,
        isSuccess,
        errorMessage,
        successMessage,
        verificationIdentifier,
      ];

  /// Creates a copy of this [AuthState] with optional field replacements
  AuthState copyWith({
    AuthPage? currentPage,
    AuthPage? previousPage,
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
    String? Function()? successMessage,
    String? Function()? verificationIdentifier,
    Future<AuthResult> Function(LoginData)? onLogin,
    Future<AuthResult> Function(SignupData)? onSignup,
    Future<AuthResult> Function(String)? onRecoverPassword,
    Future<AuthResult> Function(VerifyData)? onVerify,
    Future<AuthResult> Function(String)? onResendCode,
    Future<AuthResult> Function(AuthProvider)? onProviderAuth,
  }) {
    return AuthState(
      currentPage: currentPage ?? this.currentPage,
      previousPage: previousPage ?? this.previousPage,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
      verificationIdentifier: verificationIdentifier != null
          ? verificationIdentifier()
          : this.verificationIdentifier,
      onLogin: onLogin ?? this.onLogin,
      onSignup: onSignup ?? this.onSignup,
      onRecoverPassword: onRecoverPassword ?? this.onRecoverPassword,
      onVerify: onVerify ?? this.onVerify,
      onResendCode: onResendCode ?? this.onResendCode,
      onProviderAuth: onProviderAuth ?? this.onProviderAuth,
    );
  }

  /// Creates a loading state
  AuthState loading() => copyWith(isLoading: true);

  /// Creates an error state
  AuthState error(String message) => copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: () => message,
      );

  /// Creates a success state
  AuthState success(String message) => copyWith(
        isLoading: false,
        isSuccess: true,
        successMessage: () => message,
      );

  /// Creates a state with changed page
  AuthState toPage(AuthPage page) => copyWith(
        previousPage: currentPage,
        currentPage: page,
        isLoading: false,
        isSuccess: false,
        errorMessage: () => null,
        successMessage: () => null,
      );

  /// Creates a state for verification
  AuthState toVerification(String identifier) => copyWith(
        previousPage: currentPage,
        currentPage: AuthPage.verify,
        verificationIdentifier: () => identifier,
        isLoading: false,
        isSuccess: false,
        errorMessage: () => null,
        successMessage: () => null,
      );

  /// Creates a reset state (no loading, errors or success)
  AuthState reset() => copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: () => null,
        successMessage: () => null,
      );
}
