import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/auth_config.dart';
import '../constants/enums.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../models/auth_data.dart';
import '../models/auth_result.dart';
import '../theme/auth_theme_extension.dart';
import '../utils/responsive.dart';
import 'auth_card.dart';

/// FlutterAuth is the main widget that manages the authentication flow.
///
/// It handles login, signup, password reset, and OTP verification in a
/// unified experience with smooth animations and transitions.
class FlutterAuth extends ConsumerStatefulWidget {
  /// Main configuration for the auth flow
  final AuthConfig config;

  /// Callback when user logs in
  final Future<AuthResult> Function(LoginData data)? onLogin;

  /// Callback when user signs up
  final Future<AuthResult> Function(SignupData data)? onSignup;

  /// Callback when user requests password reset
  final Future<AuthResult> Function(String email)? onRecoverPassword;

  /// Callback when user submits OTP verification
  final Future<AuthResult> Function(VerifyData data)? onVerify;

  /// Callback when user requests OTP resend
  final Future<AuthResult> Function(String identifier)? onResendCode;

  /// Callback for OAuth provider authentication
  final Future<AuthResult> Function(AuthProvider provider)? onProviderAuth;

  /// Initial auth page to show
  final AuthPage initialPage;

  /// Function to build custom footer
  final Widget Function(BuildContext, AuthPage)? footerBuilder;

  /// Function to build custom header
  final Widget Function(BuildContext, AuthPage)? headerBuilder;

  const FlutterAuth({
    super.key,
    required this.config,
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onVerify,
    this.onResendCode,
    this.onProviderAuth,
    this.initialPage = AuthPage.login,
    this.footerBuilder,
    this.headerBuilder,
  });

  @override
  ConsumerState<FlutterAuth> createState() => _FlutterAuthState();
}

class _FlutterAuthState extends ConsumerState<FlutterAuth> {
  /// Provider instance for this specific auth flow
  late final StateNotifierProvider<AuthController, AuthState> _authProvider;

  @override
  void initState() {
    super.initState();

    // Create a provider instance with our specific configuration
    final config = AuthControllerConfig(
      config: widget.config,
      onLogin: widget.onLogin,
      onSignup: widget.onSignup,
      onRecoverPassword: widget.onRecoverPassword,
      onVerify: widget.onVerify,
      onResendCode: widget.onResendCode,
      onProviderAuth: widget.onProviderAuth,
      initialPage: widget.initialPage,
    );

    // Create a provider instance specific to this widget
    _authProvider = authControllerProvider(config);
  }

  @override
  void dispose() {
    // The controller is managed by the provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current auth state from our provider instance
    final authState = ref.watch(_authProvider);

    // Get our theme extension (or default)
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    // Determine if we're on a small screen
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);

    return Scaffold(
      // Use theme background or a gradient as fallback
      backgroundColor: authTheme.backgroundColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: authTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16.0 : 32.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional custom header
                    if (widget.headerBuilder != null)
                      widget.headerBuilder!(context, authState.currentPage),

                    // Main auth card with all forms
                    AuthCard(
                      config: widget.config,
                      authState: authState,
                      onPageChange: (page) {
                        ref.read(_authProvider.notifier).changePage(page);
                      },
                    ),

                    // Optional custom footer
                    if (widget.footerBuilder != null)
                      widget.footerBuilder!(context, authState.currentPage),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
