/// Campus AI Assistant — Auth Provider (Riverpod)
///
/// Manages authentication state across the app. Provides the
/// current user, login/register methods, and token management.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

// --------------- Service Providers ---------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000'); // Android emulator → localhost
  final authService = ref.watch(authServiceProvider);
  return ApiService(
    baseUrl: baseUrl,
    accessToken: authService.accessToken,
  );
});

// --------------- Auth State ---------------

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isProfileUpdating;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isProfileUpdating = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isProfileUpdating,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
    );
  }
}

// --------------- Auth Notifier ---------------

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Check if already authenticated
    if (_authService.isAuthenticated) {
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: user.id,
            email: user.email ?? '',
            displayName: user.userMetadata?['display_name'] as String?,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
          ),
        );
        _ref.read(apiServiceProvider).setAccessToken(_authService.accessToken!);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen for auth state changes
    _authService.authStateChanges.listen((authState) {
      final event = authState.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        final user = _authService.currentUser;
        if (user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel(
              id: user.id,
              email: user.email ?? '',
              displayName: user.userMetadata?['display_name'] as String?,
              avatarUrl: user.userMetadata?['avatar_url'] as String?,
            ),
          );
          if (_authService.accessToken != null) {
            _ref.read(apiServiceProvider).setAccessToken(_authService.accessToken!);
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signIn(email: email, password: password);
      // Auth state listener will update the state
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signUp(email: email, password: password, displayName: displayName);
      // Auth state listener will update the state
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    state = state.copyWith(isProfileUpdating: true);
    try {
      final response = await _authService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      
      final user = response.user;
      if (user != null) {
        state = state.copyWith(
          user: UserModel(
            id: user.id,
            email: user.email ?? '',
            displayName: user.userMetadata?['display_name'] as String?,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
          ),
          isProfileUpdating: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isProfileUpdating: false);
      print('Error updating profile: $e');
    }
  }

  Future<void> uploadAndSaveAvatar(File imageFile) async {
    state = state.copyWith(isProfileUpdating: true);
    try {
      final avatarUrl = await _authService.uploadAvatar(imageFile);
      await updateProfile(avatarUrl: avatarUrl);
    } catch (e) {
      state = state.copyWith(
        isProfileUpdating: false,
        errorMessage: 'Failed to upload image: ${e.toString()}',
      );
    }
  }
}

// --------------- Provider ---------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
