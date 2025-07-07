

// File: src/models/user_data.dart
import 'package:equatable/equatable.dart';

/// User data model
class UserData extends Equatable {
  /// Unique identifier
  final String id;
  
  /// User's email (if available)
  final String? email;
  
  /// User's phone number (if available)
  final String? phoneNumber;
  
  /// User's display name (if available)
  final String? displayName;
  
  /// User's photo URL (if available)
  final String? photoUrl;
  
  /// Additional user metadata
  final Map<String, dynamic>? metadata;

  const UserData({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, email, phoneNumber, displayName, photoUrl, metadata];

  /// Creates a copy of this [UserData] with optional field replacements
  UserData copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}