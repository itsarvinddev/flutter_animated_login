// File: src/models/auth_result.dart
import 'package:equatable/equatable.dart';

import 'user_data.dart';

/// Result of an authentication operation
class AuthResult extends Equatable {
  /// Whether the operation was successful
  final bool success;
  
  /// Optional error message
  final String? errorMessage;
  
  /// Optional user data (when successful)
  final UserData? user;
  
  /// Additional data returned from auth operation
  final Map<String, dynamic>? additionalData;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.additionalData,
  });

  /// Create a successful result
  factory AuthResult.success({
    UserData? user,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResult(
      success: true,
      user: user,
      additionalData: additionalData,
    );
  }

  /// Create an error result
  factory AuthResult.error(String message, {Map<String, dynamic>? additionalData}) {
    return AuthResult(
      success: false,
      errorMessage: message,
      additionalData: additionalData,
    );
  }

  @override
  List<Object?> get props => [success, errorMessage, user, additionalData];
}
