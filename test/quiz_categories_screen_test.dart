import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/data/quiz_repository.dart';
import 'package:bitcoin_beauty_school/screens/quiz/quiz_categories_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  testWidgets('All 3 category cards render at the same height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const QuizCategoriesScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final beginnerHeight = tester
        .getSize(find.byKey(const ValueKey(QuizDifficulty.beginner)))
        .height;
    final intermediateHeight = tester
        .getSize(find.byKey(const ValueKey(QuizDifficulty.intermediate)))
        .height;
    final advancedHeight = tester
        .getSize(find.byKey(const ValueKey(QuizDifficulty.advanced)))
        .height;

    expect(beginnerHeight, closeTo(intermediateHeight, 0.5));
    expect(beginnerHeight, closeTo(advancedHeight, 0.5));
  });
}
