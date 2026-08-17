import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/screens/quiz/quiz_categories_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  testWidgets('Full Beginner quiz flow: categories -> landing -> 10 '
      'questions -> result', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const QuizCategoriesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('10 Questions'), findsOneWidget);
    expect(find.text('Instant Results'), findsOneWidget);
    expect(find.text('Retake Anytime'), findsOneWidget);

    await tester.tap(find.text("Let's Glow 💅"));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1 of 10'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      expect(tester.takeException(), isNull);

      // Every question renders exactly 4 shuffled options labelled A-D.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      await tester.ensureVisible(find.text('A'));
      await tester.tap(find.text('A'));
      await tester.pump();

      final isLast = i == 9;
      final buttonFinder = find.text(isLast ? 'Finish' : 'Next Question');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
    }

    // Always tapping option "A" gives a randomized (not guaranteed-passing)
    // score, so this only checks the result screen renders correctly — the
    // 8/10 pass-threshold gating is covered deterministically in
    // quiz_result_screen_test.dart.
    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^\d{1,2}/10$').hasMatch(w.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('XP'), findsOneWidget);
    final backButtonFinder = find.text('Back to Quizzes');
    expect(backButtonFinder, findsOneWidget);

    await tester.ensureVisible(backButtonFinder);
    await tester.tap(backButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Beauty Quizzes 💅'), findsOneWidget);
  });
}
