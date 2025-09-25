import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';
import 'package:lms_app/features/auth/domain/auth_repository.dart';
import 'package:lms_app/main.dart';
import 'package:lms_app/features/auth/presentation/login_page.dart';

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository({this.currentUserId});

  @override
  String? currentUserId;

  final _controller = StreamController<String?>.broadcast();

  bool shouldThrow = false;

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<String> signIn({required String email, required String password}) async {
    if (shouldThrow) {
      throw Exception('Invalid credentials');
    }
    currentUserId = 'user-${email.hashCode}';
    _controller.add(currentUserId);
    return currentUserId!;
  }

  @override
  Future<void> signOut() async {
    currentUserId = null;
    _controller.add(null);
  }
}

Future<void> _pumpApp(WidgetTester tester, AuthRepository repository,
    {Widget? child}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: child ?? const LoginPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoginPage', () {
    testWidgets('should show validation errors when email/password invalid',
        (tester) async {
      // Arrange
      final repo = _TestAuthRepository();
      await _pumpApp(tester, repo);

      // Act
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      // Assert
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);

      // Act
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'abc');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      // Assert
      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.text('Min 6 characters'), findsOneWidget);
    });

    testWidgets('should call signIn and navigate to Dashboard on success',
        (tester) async {
      // Arrange
      final repo = _TestAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert initial screen
      expect(find.text('Login'), findsOneWidget);

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsWidgets);
    });
  });
}
