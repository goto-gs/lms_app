import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets(
    'Dashboard renders expected cards and navigates to intro course',
    (tester) async {
      final authRepo = TestAuthRepository(currentUserId: 'user-123');
      addTearDown(authRepo.dispose);

      await pumpAppWithRouter(
        tester,
        overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
        initialLocation: '/dashboard',
      );

      expect(find.text("Today's Tasks"), findsOneWidget);
      expect(find.text('Progress by Course'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);

      await tester.tap(find.text('Resume "Intro Course"'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Course intro'), findsOneWidget);
    },
  );
}
