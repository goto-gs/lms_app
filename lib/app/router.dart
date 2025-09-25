import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/controller/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/course/presentation/course_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';

/// GoRouter configured with Riverpod-based redirect logic and a login route.
final routerProvider = Provider<GoRouter>((ref) {
  String? redirectGuard(BuildContext context, GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final loggedIn = auth.userId != null;

    // go_router 現行版: matchedLocation / uri が使えます
    final loc = state.matchedLocation; // e.g. "/login"
    final loggingIn = loc == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/dashboard';
    return null;
  }

  final router = GoRouter(
    // 未ログインは redirect で /login へ飛ぶ前提
    initialLocation: '/dashboard',
    redirect: redirectGuard,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CoursePage(courseId: id);
        },
      ),
    ],
  );

  // Auth 状態変化で redirect を再評価
  ref.listen(authControllerProvider, (_, __) => router.refresh());
  return router;
});
