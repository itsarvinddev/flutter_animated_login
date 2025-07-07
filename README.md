# Flutter Animated Login

[![Pub Version](https://img.shields.io/pub/v/flutter_animated_login?color=blue&style=plastic)](https://pub.dev/packages/flutter_animated_login)
[![GitHub Repo stars](https://img.shields.io/github/stars/rvndsngwn/flutter_animated_login?color=gold&style=plastic)](https://github.com/rvndsngwn/flutter_animated_login/stargazers)
[![GitHub Repo forks](https://img.shields.io/github/forks/rvndsngwn/flutter_animated_login?color=slateblue&style=plastic)](https://github.com/rvndsngwn/flutter_animated_login/fork)
[![GitHub Repo issues](https://img.shields.io/github/issues/rvndsngwn/flutter_animated_login?color=coral&style=plastic)](https://github.com/rvndsngwn/flutter_animated_login/issues)
[![GitHub Repo contributors](https://img.shields.io/github/contributors/rvndsngwn/flutter_animated_login?color=green&style=plastic)](https://github.com/rvndsngwn/flutter_animated_login/graphs/contributors)

A beautiful, customizable, and feature-rich authentication solution for Flutter applications. Flutter Auth provides a complete authentication flow including login, signup, password reset, and OTP verification with beautiful animations and a modern UI.

<p align="center">
  <img src="https://github.com/yourusername/flutter_auth/raw/main/screenshots/login_light.png" width="200" alt="Login Screen Light Theme">
  <img src="https://github.com/yourusername/flutter_auth/raw/main/screenshots/signup_dark.png" width="200" alt="Signup Screen Dark Theme">
  <img src="https://github.com/yourusername/flutter_auth/raw/main/screenshots/verify_light.png" width="200" alt="OTP Verification Screen">
</p>

## Features

- 🔐 **Complete Authentication Flow**: Login, signup, password reset, and OTP verification
- 🎨 **Highly Customizable**: Change colors, styles, texts, and more
- 📱 **Responsive Design**: Works great on all screen sizes
- 🔄 **Animated Transitions**: Smooth animations between authentication states
- 🌗 **Theme Support**: Built-in light and dark theme support with ThemeExtension
- 🌐 **Social Login**: Support for OAuth providers (Google, Apple, Facebook, etc.)
- 📊 **Form Validation**: Built-in validation with customizable rules
- 🧩 **Modular Architecture**: Clean code that's easy to understand and extend
- ♿ **Accessibility Friendly**: Proper focus handling and semantics
- 🔨 **Developer Friendly**: Clear APIs and comprehensive documentation

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_auth: ^1.0.0
  flutter_riverpod: ^2.4.0  # Required dependency
```

Run `flutter pub get` to install.

## Basic Usage

The simplest implementation needs just a few lines of code:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth/flutter_auth.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterAuth(
        config: const AuthConfig(),
        onLogin: (data) async {
          // Handle login logic
          print('Login with: ${data.identifier}');
          return AuthResult.success();
        },
        onSignup: (data) async {
          // Handle signup logic
          print('Signup with: ${data.identifier}');
          return AuthResult.success();
        },
        onRecoverPassword: (email) async {
          // Handle password reset
          print('Reset password for: $email');
          return AuthResult.success();
        },
      ),
    );
  }
}
```

Don't forget to wrap your app with `ProviderScope`:

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## Configuration

Flutter Auth is highly configurable. Here's an example with custom configurations:

```dart
FlutterAuth(
  config: AuthConfig(
    // Login page configuration
    loginConfig: const LoginConfig(
      title: 'Welcome Back',
      subtitle: 'Login to continue to our app',
      emailFieldLabel: 'Email Address',
      passwordFieldLabel: 'Password',
      loginButtonText: 'Sign In',
      forgotPasswordText: 'Forgot Password?',
      noAccountText: 'Don\'t have an account?',
      signUpText: 'Create Account',
    ),
    
    // Signup page configuration
    signupConfig: const SignupConfig(
      title: 'Create Account',
      subtitle: 'Sign up to get started',
      loginAfterSignUp: true,
    ),
    
    // Reset password configuration
    resetConfig: const ResetConfig(
      title: 'Reset Password',
      subtitle: 'Enter your email to receive reset instructions',
    ),
    
    // OTP verification configuration
    verifyConfig: const VerifyConfig(
      title: 'Verify Your Account',
      subtitle: 'Enter the code sent to {identifier}',
      otpLength: 6,
      resendCooldown: 60,
    ),
    
    // OAuth providers
    providers: [
      AuthProvider.google,
      AuthProvider.apple,
      AuthProvider.facebook,
    ],
    
    // Legal text
    termsAndConditions: TextSpan(
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
    ),
  ),
  
  // Callbacks
  onLogin: _handleLogin,
  onSignup: _handleSignup,
  onRecoverPassword: _handlePasswordReset,
  onVerify: _handleVerify,
  onResendCode: _handleResendCode,
  onProviderAuth: _handleProviderAuth,
  
  // Custom builders
  headerBuilder: (context, page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Image.asset('assets/logo.png', height: 70),
    );
  },
  
  footerBuilder: (context, page) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        '© 2025 Your Company',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  },
)
```

## Theming

Flutter Auth supports theming through Flutter's ThemeExtension system:

```dart
MaterialApp(
  theme: ThemeData(
    // Your normal theme configuration
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    
    // Add the auth theme extension
    extensions: [
      AuthThemeExtension.defaults(context).copyWith(
        primaryButtonColor: Colors.blue.shade700,
        cardBorderRadius: 12.0,
        textFieldBorderColor: Colors.grey.shade300,
      ),
    ],
  ),
  
  // Dark theme support
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    
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
        primaryButtonColor: Colors.blue.shade600,
      ),
    ],
  ),
  
  // ...rest of your app
)
```

## Authentication Callbacks

Each authentication method has a corresponding callback:

### Login

```dart
Future<AuthResult> _handleLogin(LoginData data) async {
  try {
    // Call your authentication service
    final user = await authService.signIn(
      email: data.identifier,
      password: data.password,
    );
    
    return AuthResult.success(
      user: UserData(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
      ),
    );
  } catch (e) {
    return AuthResult.error('Invalid email or password');
  }
}
```

### Signup

```dart
Future<AuthResult> _handleSignup(SignupData data) async {
  try {
    // Call your authentication service
    final user = await authService.createAccount(
      email: data.identifier,
      password: data.password,
    );
    
    return AuthResult.success(
      user: UserData(
        id: user.uid,
        email: user.email,
        displayName: data.additionalData?['name'],
      ),
    );
  } catch (e) {
    return AuthResult.error('Failed to create account');
  }
}
```

### Password Reset

```dart
Future<AuthResult> _handlePasswordReset(String email) async {
  try {
    await authService.sendPasswordResetEmail(email);
    return AuthResult.success();
  } catch (e) {
    return AuthResult.error('Failed to send reset email');
  }
}
```

### OTP Verification

```dart
Future<AuthResult> _handleVerify(VerifyData data) async {
  try {
    await authService.verifyOtp(
      identifier: data.identifier, 
      code: data.code
    );
    return AuthResult.success();
  } catch (e) {
    return AuthResult.error('Invalid verification code');
  }
}
```

### Resend OTP

```dart
Future<AuthResult> _handleResendCode(String identifier) async {
  try {
    await authService.resendOtp(identifier);
    return AuthResult.success();
  } catch (e) {
    return AuthResult.error('Failed to resend code');
  }
}
```

### OAuth Provider Authentication

```dart
Future<AuthResult> _handleProviderAuth(AuthProvider provider) async {
  try {
    // Map to your auth service provider type
    final authProvider = _mapToProviderType(provider);
    
    final user = await authService.signInWithProvider(authProvider);
    
    return AuthResult.success(
      user: UserData(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      ),
    );
  } catch (e) {
    return AuthResult.error('Failed to authenticate with ${provider.name}');
  }
}
```

## Additional Customization

### Custom Form Fields

You can add custom fields to the signup form:

```dart
SignupConfig(
  // ...other configs
  additionalFields: (context) => [
    TextFormField(
      decoration: InputDecoration(
        labelText: 'Full Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
      onSaved: (value) {
        // Store in additionalSignupData
      },
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: ['User', 'Admin', 'Manager']
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
          .toList(),
      onChanged: (value) {
        // Store in additionalSignupData
      },
    ),
  ],
)
```

### Custom Validators

Provide your own validation logic:

```dart
LoginConfig(
  // ...other configs
  emailValidator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  },
  passwordValidator: (value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  },
)
```

### Initial Page

By default, the package shows the login page first, but you can change this:

```dart
FlutterAuth(
  // ...other config
  initialPage: AuthPage.signup,  // Start with signup page
)
```

## Advanced Examples

### Firebase Authentication Integration

```dart
import 'package:firebase_auth/firebase_auth.dart';

// ...

FlutterAuth(
  // ...configs
  onLogin: (data) async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.identifier,
        password: data.password,
      );
      
      User? user = result.user;
      if (user != null) {
        return AuthResult.success(
          user: UserData(
            id: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
          ),
        );
      } else {
        return AuthResult.error('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_handleFirebaseError(e.code));
    }
  },
  // ...other callbacks
)

String _handleFirebaseError(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Email address is not valid';
    case 'user-disabled':
      return 'This user has been disabled';
    case 'user-not-found':
      return 'No user found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    default:
      return 'Authentication failed';
  }
}
```

### Multi-step Registration Flow

```dart
// Define a custom controller to track registration steps
final registrationStepProvider = StateProvider<int>((ref) => 0);

// In your widget
FlutterAuth(
  // ...configs
  signupConfig: SignupConfig(
    // ...other configs
    formBuilder: (context) {
      // Use a Consumer to watch the registration step
      return Consumer(
        builder: (context, ref, child) {
          final step = ref.watch(registrationStepProvider);
          
          switch (step) {
            case 0:
              return _buildAccountInfoStep(context, ref);
            case 1:
              return _buildPersonalInfoStep(context, ref);
            case 2:
              return _buildPreferencesStep(context, ref);
            default:
              return Container();
          }
        },
      );
    },
  ),
  // ...callbacks
)

Widget _buildAccountInfoStep(BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      // Email field, password fields...
      
      ElevatedButton(
        onPressed: () {
          // Validate first step
          if (_formKey.currentState!.validate()) {
            ref.read(registrationStepProvider.notifier).state = 1;
          }
        },
        child: Text('Next'),
      ),
    ],
  );
}

// Similar for other steps...
```

## API Reference

For a complete API reference, please check the [API documentation](https://pub.dev/documentation/flutter_auth/latest/) on pub.dev.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'Add some amazing feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [flutter_login](https://github.com/NearHuscarl/flutter_login)
- Icons from [Material Design Icons](https://materialdesignicons.com/)

---

<p align="center">Made with ❤️ by Arvind Sangwan</p>