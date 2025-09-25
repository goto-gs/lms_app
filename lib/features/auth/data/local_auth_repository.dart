import 'dart:async';
import '../domain/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  String? _current;
  final _ctrl = StreamController<String?>.broadcast();

  LocalAuthRepository();

  @override
  String? get currentUserId => _current;

  @override
  Stream<String?> authStateChanges() => _ctrl.stream;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid credentials');
    }
    _current = 'user_${email.hashCode}';
    _ctrl.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _ctrl.add(null); // ★ 確実に通知
  }
}
