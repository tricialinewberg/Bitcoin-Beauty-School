import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/screens/journey/journey_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  testWidgets('Journey renders without overflow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const JourneyScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Your Journey'), findsOneWidget);
    expect(find.text('Level 1 ✨'), findsOneWidget);
    expect(find.text("Belle's Best Friend"), findsOneWidget);
    expect(find.text('0 of 9 unlocked'), findsOneWidget);
  });
}
