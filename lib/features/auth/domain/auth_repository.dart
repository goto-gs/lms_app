import 'dart:async';

/// Abstraction for authentication operations.
abstract class AuthRepository {
  /// The current user's id, or null if signed out.
  String? get currentUserId;

  /// Attempts to sign in. Returns the user id on success.
  Future<String> signIn({required String email, required String password});

  /// Signs out the current user.
  Future<void> signOut();

  /// Emits the current user id whenever it changes.
  Stream<String?> authStateChanges();
}
