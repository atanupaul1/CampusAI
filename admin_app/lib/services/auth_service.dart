import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService() : _supabase = Supabase.instance.client;

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentSession != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in and then fetch the user role from public.users
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  /// Fetch user profile (including role) from the public.users table
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
