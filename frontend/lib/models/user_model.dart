/// Campus AI Assistant — User Data Model
///
/// Represents a user profile as returned by the backend API.
/// Used across auth flows and the profile screen.

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final Map<String, bool>? notificationPreferences;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.notificationPreferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? Map<String, bool>.from(json['notification_preferences'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'notification_preferences': notificationPreferences,
    };
  }
}
