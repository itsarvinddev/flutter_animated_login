import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Add our auth theme extension
        extensions: [
          AuthThemeExtension.defaults(context).copyWith(
            primaryButtonColor: Colors.blue.shade700,
            cardBorderRadius: 12.0,
          ),
        ],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        // Add our auth theme extension
        extensions: [
          AuthThemeExtension.defaults(context).copyWith(
            backgroundGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900,
                Colors.black,
              ],
            ),
            cardBackgroundColor: Colors.grey.shade800,
            primaryButtonColor: Colors.blue.shade700,
            cardBorderRadius: 12.0,
          ),
        ],
      ),
      themeMode: ThemeMode.system,
      home: const AuthDemo(),
    );
  }
}

// Simple user provider to store authentication results
final currentUserProvider = StateProvider<UserData?>((ref) => null);

// Loading state provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Login type selector for demo
final loginMethodProvider =
    StateProvider<LoginMethods>((ref) => LoginMethods.emailPassword);

class AuthDemo extends ConsumerWidget {
  const AuthDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user from our provider
    final currentUser = ref.watch(currentUserProvider);

    // Get the selected login method for demo
    final loginMethod = ref.watch(loginMethodProvider);

    // If user is logged in, show the home page
    if (currentUser != null) {
      return _buildHomePage(context, ref, currentUser);
    }

    // Otherwise show the auth flow
    return Scaffold(
      body: FlutterAuth(
        config: AuthConfig(
          // Set login method from the provider
          loginMethods: loginMethod,

          // Customize the auth flow
          loginConfig: const LoginConfig(
            title: 'Welcome Back',
            subtitle: 'Login to your account to continue',
            // emailValidator: FormBuilderValidators.compose(
            //   [
            //     FormBuilderValidators.minLength(10),
            //     FormBuilderValidators.phoneNumber(),
            //   ],
            // ),
          ),
          signupConfig: const SignupConfig(
            title: 'Join Us',
            subtitle: 'Create an account to get started',
            loginAfterSignUp: true,
          ),
          resetConfig: const ResetConfig(
            title: 'Reset Password',
            subtitle: 'Enter your email and we\'ll send you reset instructions',
          ),
          verifyConfig: const VerifyConfig(
            title: 'Verify Your Account',
            subtitle: 'Enter the code sent to {identifier}',
          ),
          // Add custom providers
          providers: [
            AuthProvider.google,
            AuthProvider.apple,
            AuthProvider.facebook,
          ],
          // Add terms and conditions
          termsAndConditions: const Text.rich(TextSpan(
            text: 'By continuing, you agree to our ',
            children: [
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          )),
        ),
        // Add callbacks
        onLogin: (data) => _handleLogin(ref, data),
        onSignup: (data) => _handleSignup(ref, data),
        onRecoverPassword: (email) => _handlePasswordReset(ref, email),
        onVerify: (data) => _handleVerify(ref, data),
        onResendCode: (identifier) => _handleResendCode(ref, identifier),
        onProviderAuth: (provider) => _handleProviderAuth(ref, provider),
        // Custom header
        headerBuilder: (context, page) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Icon(
                  Icons.flutter_dash,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Current Mode: ${_loginMethodToString(loginMethod)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
        // Custom footer
        footerBuilder: (context, page) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              '© 2025 Your Company',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to convert login method to string
  String _loginMethodToString(LoginMethods method) {
    switch (method) {
      case LoginMethods.emailPassword:
        return 'Email + Password';
      case LoginMethods.emailOtp:
        return 'Email + OTP';
      case LoginMethods.phoneOtp:
        return 'Phone + OTP';
      case LoginMethods.emailPhonePassword:
        return 'Email/Phone + Password';
      case LoginMethods.emailPhoneOtp:
        return 'Email/Phone + OTP';
      case LoginMethods.all:
        return 'All Methods';
    }
  }

  // Build home page after successful login
  Widget _buildHomePage(BuildContext context, WidgetRef ref, UserData user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Clear the user data to log out
              ref.read(currentUserProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user.displayName ?? user.email ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'You are now logged in',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (user.email != null) ...[
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
            ],
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${user.phoneNumber}'),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Clear the user data to log out
                ref.read(currentUserProvider.notifier).state = null;
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  // Login callback
  Future<AuthResult> _handleLogin(WidgetRef ref, LoginData data) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Login: ${data.identifier}, Remember me: ${data.rememberMe}');

      // Determine if this is OTP or password flow
      final loginMethod = ref.read(loginMethodProvider);

      if (_isOtpMethod(loginMethod)) {
        // Handle OTP flow
      } else {
        // Handle password flow
        // For demo, accept any email with password "password"
        if (data.password == 'password') {
          // Store user in provider
          ref.read(currentUserProvider.notifier).state = UserData(
            id: '123',
            email: data.identifier.contains('@') ? data.identifier : null,
            phoneNumber:
                !data.identifier.contains('@') ? data.identifier : null,
            displayName: 'Demo User',
          );

          return AuthResult.success(
            user: UserData(
              id: '123',
              email: data.identifier.contains('@') ? data.identifier : null,
              phoneNumber:
                  !data.identifier.contains('@') ? data.identifier : null,
              displayName: 'Demo User',
            ),
          );
        }

        return AuthResult.error('Invalid credentials');
      }

      return AuthResult.error('Invalid login flow');
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Helper to check if login method is OTP-based
  bool _isOtpMethod(LoginMethods method) {
    return method == LoginMethods.emailOtp ||
        method == LoginMethods.phoneOtp ||
        method == LoginMethods.emailPhoneOtp ||
        method == LoginMethods.all;
  }

  // Signup callback
  Future<AuthResult> _handleSignup(WidgetRef ref, SignupData data) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Signup: ${data.identifier}');

      // Always succeed for demo
      return AuthResult.success(
        user: UserData(
          id: '123',
          email: data.identifier,
          displayName: 'New User',
        ),
      );
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Password reset callback
  Future<AuthResult> _handlePasswordReset(WidgetRef ref, String email) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Reset password for: $email');

      // Always succeed for demo
      return AuthResult.success();
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // OTP verification callback
  Future<AuthResult> _handleVerify(WidgetRef ref, VerifyData data) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Verify: ${data.identifier} with code: ${data.code}');

      // For demo, accept code "123456"
      if (data.code == '123456') {
        // Store user in provider
        final user = UserData(
          id: '123',
          email: data.identifier.contains('@') ? data.identifier : null,
          phoneNumber: !data.identifier.contains('@') ? data.identifier : null,
          displayName: 'Verified User',
        );

        ref.read(currentUserProvider.notifier).state = user;

        return AuthResult.success(user: user);
      }

      return AuthResult.error('Invalid verification code');
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Resend OTP callback
  Future<AuthResult> _handleResendCode(WidgetRef ref, String identifier) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Resend code to: $identifier');

      // Always succeed for demo
      return AuthResult.success();
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // OAuth provider callback
  Future<AuthResult> _handleProviderAuth(
      WidgetRef ref, AuthProvider provider) async {
    try {
      // Set loading state
      ref.read(authLoadingProvider.notifier).state = true;

      // In a real app, call your auth service
      await Future.delayed(const Duration(seconds: 1));

      print('Auth with provider: $provider');

      // Store the user in our provider
      final user = UserData(
        id: '123',
        email: 'provider@example.com',
        displayName: '${provider.name.capitalize()} User',
      );

      ref.read(currentUserProvider.notifier).state = user;

      // Always succeed for demo
      return AuthResult.success(user: user);
    } finally {
      // Reset loading state
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
