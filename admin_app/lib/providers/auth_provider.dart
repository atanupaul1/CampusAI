import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AdminAuthStatus { unknown, authenticated, unauthenticated, unauthorized }

class AdminAuthState {
  final AdminAuthStatus status;
  final UserModel? user;
  final String? error;

  const AdminAuthState({
    this.status = AdminAuthStatus.unknown,
    this.user,
    this.error,
  });

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AdminAuthNotifier(authService);
});

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final AuthService _authService;

  AdminAuthNotifier(this._authService) : super(const AdminAuthState()) {
    _init();
  }

  void _init() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.id);
      if (profile != null && profile.role == 'admin') {
        state = state.copyWith(
          status: AdminAuthStatus.authenticated,
          user: profile,
        );
      } else {
        state = state.copyWith(status: AdminAuthStatus.unauthorized);
      }
    } else {
      state = state.copyWith(status: AdminAuthStatus.unauthenticated);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(status: AdminAuthStatus.unknown, error: null);
      final profile = await _authService.signIn(email: email, password: password);

      if (profile != null) {
        if (profile.role == 'admin') {
          state = state.copyWith(
            status: AdminAuthStatus.authenticated,
            user: profile,
          );
        } else {
          state = state.copyWith(
            status: AdminAuthStatus.unauthorized,
            error: 'You do not have administrative privileges.',
          );
          await _authService.signOut();
        }
      } else {
        state = state.copyWith(
          status: AdminAuthStatus.unauthenticated,
          error: 'Invalid credentials or network error.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AdminAuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AdminAuthState(status: AdminAuthStatus.unauthenticated);
  }
}
