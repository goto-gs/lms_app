// lib/features/dashboard/presentation/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ← 相対パスを1つ短くする（../../）
import '../../auth/controller/auth_controller.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              if (kDebugMode) debugPrint('[logout] pressed');

              await ref.read(authControllerProvider.notifier).signOut();

              if (kDebugMode) {
                final uid = ref.read(authControllerProvider).userId;
                debugPrint('[logout] userId after signOut = $uid');
              }

              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Dashboard')),
    );
  }
}
