/// Campus AI Assistant — Auth Service
///
/// Wraps Supabase Flutter SDK for authentication flows.
/// Also manages the FastAPI access token after login.

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
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
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
}
