// File: src/models/auth_data.dart
import 'package:equatable/equatable.dart';

/// Base class for authentication data
abstract class BaseAuthData extends Equatable {
  const BaseAuthData();
}

/// Data for login authentication
class LoginData extends BaseAuthData {
  /// Identifier (email or phone)
  final String identifier;
  
  /// Password or OTP
  final String password;
  
  /// Remember session flag
  final bool rememberMe;

  const LoginData({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];

  /// Creates a copy of this [LoginData] with optional field replacements
  LoginData copyWith({
    String? identifier,
    String? password,
    bool? rememberMe,
  }) {
    return LoginData(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

/// Data for signup registration
class SignupData extends BaseAuthData {
  /// Identifier (email or phone)
  final String identifier;
  
  /// User's password
  final String password;
  
  /// Password confirmation
  final String? confirmPassword;
  
  /// Additional user data
  final Map<String, dynamic>? additionalData;

  const SignupData({
    required this.identifier,
    required this.password,
    this.confirmPassword,
    this.additionalData,
  });

  @override
  List<Object?> get props => [identifier, password, confirmPassword, additionalData];

  /// Creates a copy of this [SignupData] with optional field replacements
  SignupData copyWith({
    String? identifier,
    String? password,
    String? confirmPassword,
    Map<String, dynamic>? additionalData,
  }) {
    return SignupData(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Data for OTP verification
class VerifyData extends BaseAuthData {
  /// User identifier to verify
  final String identifier;
  
  /// OTP/verification code
  final String code;

  const VerifyData({
    required this.identifier,
    required this.code,
  });

  @override
  List<Object?> get props => [identifier, code];

  /// Creates a copy of this [VerifyData] with optional field replacements
  VerifyData copyWith({
    String? identifier,
    String? code,
  }) {
    return VerifyData(
      identifier: identifier ?? this.identifier,
      code: code ?? this.code,
    );
  }
}
