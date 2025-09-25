import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/controller/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/course/presentation/course_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';

/// GoRouter configured with Riverpod-based redirect logic and a login route.
final routerProvider = Provider<GoRouter>((ref) {
  String? redirectLogic(BuildContext context, GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final loggedIn = auth.userId != null;
    final loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/dashboard';
    return null;
  }

  final router = GoRouter(
    initialLocation: '/dashboard',
    redirect: redirectLogic,
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

  // Refresh router when auth state changes so redirect re-evaluates.
  ref.listen(authControllerProvider, (_, __) => router.refresh());

  return router;
});
