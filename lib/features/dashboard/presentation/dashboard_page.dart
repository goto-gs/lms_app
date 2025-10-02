// lib/features/dashboard/presentation/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../auth/controller/auth_controller.dart';

// Dummy data providers (replace with real data sources later)
final todaysTasksProvider = Provider<List<String>>(
  (ref) => const [
    'Review Module 1 summary',
    'Complete Quiz: Fundamentals',
    'Watch Video: Intro to Widgets',
  ],
);

final courseProgressProvider = Provider<Map<String, double>>(
  (ref) => const {
    'Intro Course': 0.75,
    'Advanced Widgets': 0.32,
    'State Management': 0.10,
  },
);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todaysTasksProvider);
    final progressMap = ref.watch(courseProgressProvider);
    final theme = Theme.of(context);

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int crossAxisCount;
          if (width <= 600) {
            crossAxisCount = 1;
          } else if (width <= 1024) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 3;
          }

          final cards = <Widget>[
            _DashboardCard(
              title: "Today's Tasks",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in tasks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Icon(Icons.check_circle_outline, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(t, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  if (tasks.isEmpty)
                    Text(
                      'No tasks for today.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            _DashboardCard(
              title: 'Progress by Course',
              child: Column(
                children: progressMap.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: e.value,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(e.value * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            _DashboardCard(
              title: 'Continue Learning',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jump back into your current module and keep your streak alive.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/course/intro'),
                    child: const Text('Resume "Intro Course"'),
                  ),
                ],
              ),
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 4 / 3,
                  ),
                  itemBuilder: (context, index) => cards[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28), // 2xl radius
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              // Using withAlpha for SDKs where withValues(alpha: ...) might not be available yet.
              // If on a newer SDK supporting withValues(alpha: 0.96), that could be used instead.
              colorScheme.surface.withAlpha((0.96 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
