import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/data/quiz_repository.dart';
import 'package:bitcoin_beauty_school/screens/quiz/quiz_result_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_colors.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  Future<void> pump(WidgetTester tester, int score) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: QuizResultScreen(
          difficulty: QuizDifficulty.beginner,
          score: score,
          total: 10,
        ),
      ),
    );
  }

  Color ringColorFor(WidgetTester tester, int score) {
    final text = tester.widget<Text>(find.text('$score/10'));
    return text.style!.color!;
  }

  testWidgets('8/10 passes: shows Try Next Level and celebratory copy', (
    tester,
  ) async {
    await pump(tester, 8);

    expect(find.text("You're Glowing! ✨"), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsOneWidget);
    expect(ringColorFor(tester, 8), AppColors.successGlow);
  });

  testWidgets('10/10 passes: shows the perfect-score copy', (tester) async {
    await pump(tester, 10);

    expect(find.text('Perfect Score! ✨'), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsOneWidget);
    expect(ringColorFor(tester, 10), AppColors.successGlow);
  });

  testWidgets('7/10 does not pass: "So Close" tier, no next-level button, '
      'Bitcoin Orange ring', (tester) async {
    await pump(tester, 7);

    expect(find.text('So Close! 💪'), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsNothing);
    expect(find.text('Back to Quizzes'), findsOneWidget);
    expect(ringColorFor(tester, 7), AppColors.bitcoinOrange);
  });

  testWidgets('6/10 does not pass: "So Close" tier, no next-level button, '
      'Bitcoin Orange ring', (tester) async {
    await pump(tester, 6);

    expect(find.text('So Close! 💪'), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsNothing);
    expect(ringColorFor(tester, 6), AppColors.bitcoinOrange);
  });

  testWidgets('5/10 does not pass: needs-review tier, no next-level button, '
      'neutral ring', (tester) async {
    await pump(tester, 5);

    expect(find.text("Let's Glow Up Your Knowledge 🌱"), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsNothing);
    expect(ringColorFor(tester, 5), AppColors.mutedMauve);
  });

  testWidgets('0/10 does not pass: needs-review tier, no next-level button, '
      'neutral ring', (tester) async {
    await pump(tester, 0);

    expect(find.text("Let's Glow Up Your Knowledge 🌱"), findsOneWidget);
    expect(find.text('Try Intermediate Level →'), findsNothing);
    expect(ringColorFor(tester, 0), AppColors.mutedMauve);
  });

  testWidgets('Advanced quiz never shows a next-level button, even at 10/10', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const QuizResultScreen(
          difficulty: QuizDifficulty.advanced,
          score: 10,
          total: 10,
        ),
      ),
    );

    expect(find.textContaining('Try'), findsNothing);
    expect(find.text('Back to Quizzes'), findsOneWidget);
  });
}
