import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('Course page logout routes back to login', (tester) async {
    final authRepo = TestAuthRepository(currentUserId: 'user-123');
    addTearDown(authRepo.dispose);

    await pumpAppWithRouter(
      tester,
      overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
      initialLocation: '/course/intro',
    );

    expect(find.widgetWithText(AppBar, 'Course intro'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
  });
}
