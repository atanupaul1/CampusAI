/// Campus AI Assistant — Auth Service
///
/// Wraps Supabase Flutter SDK for authentication flows.
/// Also manages the FastAPI access token after login.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService() : _supabase = Supabase.instance.client;

  /// Get the current Supabase session (may be null if not logged in).
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get the current user (may be null).
  User? get currentUser => _supabase.auth.currentUser;

  /// Get the current access token (JWT).
  String? get accessToken => currentSession?.accessToken;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => currentSession != null;

  /// Stream of auth state changes (login, logout, token refresh).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (displayName != null) 'display_name': displayName,
      },
    );

    // Ensure the student row exists in the public users table immediately
    final user = response.user;
    if (user != null) {
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'display_name': displayName,
        'role': 'student',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Update user profile metadata.
  Future<UserResponse> updateProfile({String? displayName, String? avatarUrl}) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );

    // Sync with the public 'users' table so the Admin App can see it
    if (currentUser != null) {
      try {
        await _supabase.from('users').upsert({
          'id': currentUser!.id,
          'email': currentUser!.email,
          if (displayName != null) 'display_name': displayName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'role': 'student', // Default if row is missing
        });
      } catch (e) {
        print('Warning: Failed to sync to users table. Check RLS policies: $e');
      }
    }

    return response;
  }

  /// Upload an avatar to Supabase Storage and return the public URL.
  Future<String> uploadAvatar(File imageFile) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'avatars/$fileName';

    await _supabase.storage.from('avatars').upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    return _supabase.storage.from('avatars').getPublicUrl(filePath);
  }
}
