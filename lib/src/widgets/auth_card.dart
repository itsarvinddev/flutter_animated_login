import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animations/card_flip.dart';
import '../config/auth_config.dart';
import '../constants/enums.dart';
import '../controllers/auth_state.dart';
import '../theme/auth_theme_extension.dart';
import 'pages/login_page.dart';
import 'pages/reset_page.dart';
import 'pages/signup_page.dart';
import 'pages/verify_page.dart';

/// The AuthCard is the main container for all authentication forms.
///
/// It handles the animations between different auth pages and provides
/// a consistent card-like UI for the entire auth flow.
class AuthCard extends ConsumerWidget {
  /// Main configuration for the auth flow
  final AuthConfig config;

  /// Current authentication state
  final AuthState authState;

  /// Callback when page changes
  final Function(AuthPage) onPageChange;

  const AuthCard({
    super.key,
    required this.config,
    required this.authState,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: authTheme.cardElevation,
      shadowColor: authTheme.cardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(authTheme.cardBorderRadius),
        side: BorderSide(
          color: authTheme.cardBorderColor,
          width: authTheme.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _buildCurrentPage(context),
        ),
      ),
    );
  }

  Widget _buildCurrentPage(BuildContext context) {
    // Use a custom animation for page transitions
    return CardFlipTransition(
      key: ValueKey(authState.currentPage),
      direction: _getAnimationDirection(),
      child: _getPageWidget(),
    );
  }

  FlipDirection _getAnimationDirection() {
    // Determine the animation direction based on page navigation
    final oldIndex = AuthPage.values.indexOf(authState.previousPage);
    final newIndex = AuthPage.values.indexOf(authState.currentPage);

    if (oldIndex < newIndex) {
      return FlipDirection.horizontal;
    } else {
      return FlipDirection.horizontalReverse;
    }
  }

  Widget _getPageWidget() {
    // Return the appropriate page widget based on current auth state
    switch (authState.currentPage) {
      case AuthPage.login:
        return LoginPage(
          config: config.loginConfig,
          loginType: config.loginType, // Pass loginType from config
          onSignupTap: () => onPageChange(AuthPage.signup),
          onForgotPasswordTap: () => onPageChange(AuthPage.reset),
          onLoginSubmit: authState.onLogin,
        );

      case AuthPage.signup:
        return SignupPage(
          config: config.signupConfig,
          onLoginTap: () => onPageChange(AuthPage.login),
          onSignupSubmit: authState.onSignup,
        );

      case AuthPage.reset:
        return ResetPage(
          config: config.resetConfig,
          onLoginTap: () => onPageChange(AuthPage.login),
          onResetSubmit: authState.onRecoverPassword,
        );

      case AuthPage.verify:
        return VerifyPage(
          config: config.verifyConfig,
          identifier: authState.verificationIdentifier ?? '',
          onVerifySubmit: authState.onVerify,
          onResendCode: authState.onResendCode != null
              ? () => authState.onResendCode!.call(
                    authState.verificationIdentifier ?? '',
                  )
              : null,
          onBackTap: () => onPageChange(AuthPage.login),
        );
    }
  }
}
