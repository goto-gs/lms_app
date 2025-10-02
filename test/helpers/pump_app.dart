import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_app/app/router.dart';
import 'package:lms_app/features/auth/controller/auth_controller.dart';
import 'package:lms_app/features/auth/domain/auth_repository.dart';
import 'package:lms_app/main.dart';

class TestAuthRepository implements AuthRepository {
  TestAuthRepository({String? currentUserId}) : _currentUserId = currentUserId;

  String? _currentUserId;
  late final StreamController<String?> _controller =
      StreamController<String?>.broadcast(
    onListen: () => _controller.add(_currentUserId),
  );

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<String?> authStateChanges() => _controller.stream;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    _currentUserId = 'user-123';
    _controller.add(_currentUserId);
    return _currentUserId!;
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

Future<void> pumpAppWithRouter(
  WidgetTester tester, {
  List<Override> overrides = const [],
  String? initialLocation,
}) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  final router = container.read(routerProvider);
  if (initialLocation != null) {
    router.go(initialLocation);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();
}
