// test/dashboard_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_app/features/auth/controller/auth_controller.dart';
import 'helpers/pump_app.dart';

void main() {
  testWidgets(
    'Dashboard renders expected cards and navigates to intro course',
    (tester) async {
      // 広めのビューポートにしてスクロール不要に（保険として後でscrollも実施）
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1200, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

      final resumeFinder = find.text('Resume "Intro Course"');

      // 画面外の可能性に備えて可視化してからタップ
      await tester.scrollUntilVisible(
        resumeFinder,
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(resumeFinder);
      await tester.pumpAndSettle();

      expect(find.text('Course intro'), findsOneWidget);
    },
  );
}
