import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';

part 'auth_provider.g.dart';

/// Auth state enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth notifier provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);

    // Listen to auth state changes
    repo.authStateChanges.listen((authState) {
      if (authState.session != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: authState.session!.user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });

    // Check initial auth state
    if (repo.isAuthenticated) {
      return AuthState(
        status: AuthStatus.authenticated,
        user: repo.currentUser,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign in failed',
        );
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.signUpWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Note: User may need to verify email depending on Supabase settings
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign up failed',
        );
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign in with magic link
  Future<bool> signInWithMagicLink({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithMagicLink(email: email);

      // Magic link sent - stay in loading/pending state
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithApple();
      // OAuth flow will trigger auth state change listener
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
      // OAuth flow will trigger auth state change listener
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Still set to unauthenticated even if sign out fails
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Clear error
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

/// Convenience provider for checking authentication status
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
}
