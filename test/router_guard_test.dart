import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';
import 'package:lms_app/features/auth/domain/auth_repository.dart';
import 'package:lms_app/main.dart';
import 'package:flutter/material.dart';

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository({this.currentUserId});

  @override
  String? currentUserId;

  final _controller = StreamController<String?>.broadcast();

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    currentUserId = 'user-123';
    _controller.add(currentUserId);
    return currentUserId!;
  }

  @override
  Future<void> signOut() async {
    currentUserId = null;
    _controller.add(null);
  }
}

void main() {
  group('Router redirect guard', () {
    testWidgets(
      'should redirect unauthenticated users from /dashboard to /login',
      (tester) async {
        // Arrange
        final repo = _TestAuthRepository(currentUserId: null);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(repo)],
            child: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Login'), findsOneWidget);
      },
    );

    testWidgets('should redirect authenticated users away from /login', (
      tester,
    ) async {
      // Arrange
      final repo = _TestAuthRepository(currentUserId: 'user-123');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm dashboard shown initially
      expect(find.text('Dashboard'), findsWidgets);

      // Act
      final BuildContext context = tester.element(find.text('Dashboard').first);
      GoRouter.of(context).go('/login');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsWidgets);
    });
  });
}
