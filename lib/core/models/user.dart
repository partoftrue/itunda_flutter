import 'package:equatable/equatable.dart';

/// Represents a user in the application
class User extends Equatable {
  /// The unique identifier of the user
  final String id;
  
  /// The user's email address
  final String email;
  
  /// The user's display name
  final String username;
  
  /// URL to the user's profile image, if any
  final String? profileImageUrl;
  
  /// Creates a new [User] instance
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
  });
  
  /// Creates a [User] from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
  
  /// Converts this [User] to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }
  
  /// Creates a copy of this [User] with the given fields replaced with the new values
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  /// Creates an empty User
  factory User.empty() {
    return const User(
      id: '',
      email: '',
      username: '',
      profileImageUrl: null,
    );
  }

  @override
  List<Object?> get props => [id, email, username, profileImageUrl];
} 