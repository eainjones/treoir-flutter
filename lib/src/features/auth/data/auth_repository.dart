import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

/// Repository handling authentication operations
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with magic link (passwordless)
  Future<void> signInWithMagicLink({required String email}) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'xyz.treoir.treoir://login-callback',
    );
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'xyz.treoir.treoir://login-callback',
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'xyz.treoir.treoir://login-callback',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Refresh session
  Future<AuthResponse> refreshSession() async {
    return await _client.auth.refreshSession();
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'xyz.treoir.treoir://reset-callback',
    );
  }

  /// Update password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Delete account
  Future<void> deleteAccount() async {
    // Note: This requires a Supabase Edge Function or admin API
    // For now, just sign out
    await signOut();
  }
}
