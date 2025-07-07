// File: src/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/auth_config.dart';
import '../constants/enums.dart';
import '../models/auth_data.dart';
import '../models/auth_result.dart';
import 'auth_state.dart';

/// Provider family for the auth controller that takes all necessary configuration
final authControllerProvider = StateNotifierProvider.family<AuthController,
    AuthState, AuthControllerConfig>(
  (ref, config) => AuthController(
    config: config.config,
    onLogin: config.onLogin,
    onSignup: config.onSignup,
    onRecoverPassword: config.onRecoverPassword,
    onVerify: config.onVerify,
    onResendCode: config.onResendCode,
    onProviderAuth: config.onProviderAuth,
    initialPage: config.initialPage,
  ),
);

/// Configuration class for AuthController to use with provider.family
class AuthControllerConfig {
  final AuthConfig config;
  final Future<AuthResult> Function(LoginData)? onLogin;
  final Future<AuthResult> Function(SignupData)? onSignup;
  final Future<AuthResult> Function(String)? onRecoverPassword;
  final Future<AuthResult> Function(VerifyData)? onVerify;
  final Future<AuthResult> Function(String)? onResendCode;
  final Future<AuthResult> Function(AuthProvider)? onProviderAuth;
  final AuthPage initialPage;

  AuthControllerConfig({
    required this.config,
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onVerify,
    this.onResendCode,
    this.onProviderAuth,
    this.initialPage = AuthPage.login,
  });
}

/// Controller for the authentication flow
class AuthController extends StateNotifier<AuthState> {
  /// Main configuration
  final AuthConfig config;

  /// Callback when user logs in
  final Future<AuthResult> Function(LoginData)? onLogin;

  /// Callback when user signs up
  final Future<AuthResult> Function(SignupData)? onSignup;

  /// Callback when user requests password reset
  final Future<AuthResult> Function(String)? onRecoverPassword;

  /// Callback when user submits OTP verification
  final Future<AuthResult> Function(VerifyData)? onVerify;

  /// Callback when user requests OTP resend
  final Future<AuthResult> Function(String)? onResendCode;

  /// Callback for OAuth provider authentication
  final Future<AuthResult> Function(AuthProvider)? onProviderAuth;

  AuthController({
    required this.config,
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onVerify,
    this.onResendCode,
    this.onProviderAuth,
    AuthPage initialPage = AuthPage.login,
  }) : super(AuthState(
          currentPage: initialPage,
          previousPage: initialPage,
          onLogin: onLogin,
          onSignup: onSignup,
          onRecoverPassword: onRecoverPassword,
          onVerify: onVerify,
          onResendCode: onResendCode,
          onProviderAuth: onProviderAuth,
        ));

  /// Change current auth page
  void changePage(AuthPage page) {
    state = state.toPage(page);
  }

  /// Start verification flow with identifier
  void startVerification(String identifier) {
    state = state.toVerification(identifier);
  }

  /// Set loading state
  void setLoading() {
    state = state.loading();
  }

  /// Set error state
  void setError(String message) {
    state = state.error(message);
  }

  /// Set success state
  void setSuccess(String message) {
    state = state.success(message);
  }

  /// Reset state (clear loading, errors, success)
  void resetState() {
    state = state.reset();
  }

  /// Handle login submission
  Future<void> handleLogin(LoginData data) async {
    try {
      setLoading();

      if (onLogin == null) {
        setError('Login handler not implemented');
        return;
      }

      final result = await onLogin!(data);

      if (result.success) {
        setSuccess('Login successful');
      } else {
        // Check if verification is required (OTP flow)
        if (result.additionalData != null &&
            result.additionalData!['requiresVerification'] == true) {
          // Transition to verification page
          startVerification(data.identifier);
        } else {
          // Regular error
          setError(result.errorMessage ?? 'Login failed');
        }
      }
    } catch (e) {
      setError('Login error: ${e.toString()}');
    }
  }

  /// Handle signup submission
  Future<void> handleSignup(SignupData data) async {
    try {
      setLoading();

      if (onSignup == null) {
        setError('Signup handler not implemented');
        return;
      }

      final result = await onSignup!(data);

      if (result.success) {
        setSuccess('Signup successful');

        // Auto transition to login or verification based on configuration
        if (config.signupConfig.loginAfterSignUp) {
          Future.delayed(const Duration(milliseconds: 500), () {
            resetState();
            changePage(AuthPage.login);
          });
        }
      } else {
        setError(result.errorMessage ?? 'Signup failed');
      }
    } catch (e) {
      setError('Signup error: ${e.toString()}');
    }
  }

  /// Handle password reset
  Future<void> handlePasswordReset(String email) async {
    try {
      setLoading();

      if (onRecoverPassword == null) {
        setError('Password reset handler not implemented');
        return;
      }

      final result = await onRecoverPassword!(email);

      if (result.success) {
        setSuccess('Password reset email sent');

        // Return to login after delay
        Future.delayed(const Duration(seconds: 2), () {
          resetState();
          changePage(AuthPage.login);
        });
      } else {
        setError(result.errorMessage ?? 'Password reset failed');
      }
    } catch (e) {
      setError('Password reset error: ${e.toString()}');
    }
  }

  /// Handle OTP verification
  Future<void> handleVerify(VerifyData data) async {
    try {
      setLoading();

      if (onVerify == null) {
        setError('Verification handler not implemented');
        return;
      }

      final result = await onVerify!(data);

      if (result.success) {
        setSuccess('Verification successful');

        // Return to login after delay
        Future.delayed(const Duration(seconds: 1), () {
          resetState();
          changePage(AuthPage.login);
        });
      } else {
        setError(result.errorMessage ?? 'Verification failed');
      }
    } catch (e) {
      setError('Verification error: ${e.toString()}');
    }
  }

  /// Handle OTP resend
  Future<void> handleResendCode(String identifier) async {
    try {
      setLoading();

      if (onResendCode == null) {
        setError('Resend code handler not implemented');
        return;
      }

      final result = await onResendCode!(identifier);

      if (result.success) {
        setSuccess('Verification code resent');
      } else {
        setError(result.errorMessage ?? 'Failed to resend code');
      }
    } catch (e) {
      setError('Resend code error: ${e.toString()}');
    }
  }

  /// Handle OAuth provider authentication
  Future<void> handleProviderAuth(AuthProvider provider) async {
    try {
      setLoading();

      if (onProviderAuth == null) {
        setError('Provider auth not implemented');
        return;
      }

      final result = await onProviderAuth!(provider);

      if (result.success) {
        setSuccess('Provider authentication successful');
      } else {
        setError(result.errorMessage ?? 'Provider authentication failed');
      }
    } catch (e) {
      setError('Provider auth error: ${e.toString()}');
    }
  }
}
