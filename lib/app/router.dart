import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
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

    // e.g. "/login"
    final loc = state.matchedLocation;
    final loggingIn = loc == '/login';
    if (kDebugMode) debugPrint('[redirect] loc=$loc loggedIn=$loggedIn');

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/dashboard';
    return null;
  }

  // Stream of auth changes (from repository)
  final authChanges = ref.read(authRepositoryProvider).authStateChanges();

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
    // Auth 変更でルータを自動リフレッシュ
    refreshListenable: RouterRefreshStream(authChanges),
  );

  // 追加の保険（State変化で手動 refresh）
  ref.listen(authControllerProvider, (_, __) => router.refresh());

  return router;
});

/// Minimal Listenable that triggers GoRouter.refresh() on every stream event.
/// (Fallback for environments where GoRouterRefreshStream isn't available.)
class RouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;
  RouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
