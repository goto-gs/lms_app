import 'dart:async';

import '../../auth/domain/auth_repository.dart';

/// A local in-memory implementation of [AuthRepository].
class LocalAuthRepository implements AuthRepository {
  final _controller = StreamController<String?>.broadcast();
  String? _currentUserId;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid credentials');
    }

    // Generate a simple user id from email.
    _currentUserId = email;
    _controller.add(_currentUserId);
    return _currentUserId!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _currentUserId = null;
    _controller.add(_currentUserId);
  }

  @override
  Stream<String?> authStateChanges() async* {
    // Emit initial state then subsequent changes.
    yield _currentUserId;
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
