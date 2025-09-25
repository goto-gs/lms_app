import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_repository.dart';
import '../data/local_auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? userId;
  final String? error;

  const AuthState({this.isLoading = false, this.userId, this.error});

  AuthState copyWith({bool? isLoading, String? userId, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState()) {
    _sub = _repo.authStateChanges().listen((uid) {
      state = state.copyWith(userId: uid, isLoading: false, error: null);
    });
  }

  final AuthRepository _repo;
  StreamSubscription<String?>? _sub;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final uid = await _repo.signIn(email: email, password: password);
      state = state.copyWith(userId: uid, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    await _repo.signOut();
    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = LocalAuthRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.watch(authRepositoryProvider);
    return AuthController(repo);
  },
);
