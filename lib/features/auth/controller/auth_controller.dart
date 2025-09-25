import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_auth_repository.dart';
import '../domain/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? userId;
  final String? error;
  const AuthState({this.isLoading = false, this.userId, this.error});

  AuthState copyWith({bool? isLoading, String? userId, String? error}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        userId: userId,
        error: error,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  late final StreamSubscription _sub;

  AuthController(this._repo) : super(AuthState(userId: _repo.currentUserId)) {
    _sub = _repo.authStateChanges().listen((id) {
      state = state.copyWith(isLoading: false, userId: id, error: null);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, userId: state.userId);
    try {
      await _repo.signIn(email: email, password: password);
      // 成功時は repo 側のストリームで userId が入る
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        userId: null,
      );
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    // ★ 念のため即時に userId を null に（ストリームを待たない）
    state = state.copyWith(isLoading: false, error: null, userId: null);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
