import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/screens/home/home_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  testWidgets('Home renders without overflow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hi, Bestie 👋'), findsOneWidget);
    expect(find.text('Start Chatting with Belle'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
  });
}
