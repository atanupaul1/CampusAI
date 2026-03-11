/// Campus AI Admin — User Data Model
///
/// Shared from main frontend app, updated with role support.

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String role; // 'user' or 'admin'
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.role = 'user',
    this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
