import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.metadata,
    this.createdAt,
    this.lastSignInAt,
  });

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      metadata: user.userMetadata,
      createdAt: DateTime.tryParse(user.createdAt ?? ''),
      lastSignInAt: DateTime.tryParse(user.lastSignInAt ?? ''),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
