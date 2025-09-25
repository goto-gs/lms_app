import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';
import 'package:lms_app/features/auth/domain/auth_repository.dart';

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository();

  @override
  String? currentUserId;

  final _controller = StreamController<String?>.broadcast();

  final List<String?> emittedUserIds = <String?>[];

  bool shouldThrow = false;

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw Exception('Invalid credentials');
    }
    currentUserId = 'user-123';
    emittedUserIds.add(currentUserId);
    _controller.add(currentUserId);
    return currentUserId!;
  }

  @override
  Future<void> signOut() async {
    currentUserId = null;
    emittedUserIds.add(null);
    _controller.add(null);
  }
}

void main() {
  group('AuthController', () {
    test('signIn should set userId and clear error on success', () async {
      // Arrange
      final repo = _TestAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);

      // Act
      await controller.signIn('test@example.com', 'password');
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = container.read(authControllerProvider);
      expect(state.userId, isNotNull);
      expect(state.error, isNull);
      expect(repo.emittedUserIds.last, isNotNull);
    });

    test('signIn should expose error and reset loading on failure', () async {
      // Arrange
      final repo = _TestAuthRepository()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);

      // Act
      await controller.signIn('invalid', '123');
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = container.read(authControllerProvider);
      expect(state.userId, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Invalid credentials'));
    });

    test('signOut should clear userId immediately and emit null', () async {
      // Arrange
      final repo = _TestAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('test@example.com', 'password');
      await Future<void>.delayed(Duration.zero);

      // Act
      await controller.signOut();
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state = container.read(authControllerProvider);
      expect(state.userId, isNull);
      expect(repo.emittedUserIds.contains(null), isTrue);
    });
  });
}
