import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controller/auth_controller.dart';

class CoursePage extends ConsumerWidget {
  final String courseId;
  const CoursePage({super.key, required this.courseId});

  String _title() => courseId == 'intro' ? 'Course intro' : 'Course $courseId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(child: Text('Course: $courseId')),
    );
  }
}
