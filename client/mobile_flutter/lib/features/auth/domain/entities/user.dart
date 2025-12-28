import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, username, email, displayName, avatarUrl, bio, createdAt];
}
