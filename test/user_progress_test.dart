import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/data/user_progress.dart';
import 'package:bitcoin_beauty_school/widgets/streak_day_row.dart';

void main() {
  test('fresh-account defaults round-trip through JSON unchanged', () {
    final fresh = UserProgress.fresh();

    final roundTripped = UserProgress.fromJson(fresh.toJson());

    expect(roundTripped.toJson(), fresh.toJson());
    expect(roundTripped.isFreshAccount, isTrue);
  });

  test('a populated snapshot (including mixed streak states) round-trips', () {
    const progress = UserProgress(
      level: 3,
      xpCurrent: 650,
      xpTarget: 1000,
      currentStreak: 3,
      bestStreak: 12,
      streakStates: [
        StreakDayState.done,
        StreakDayState.done,
        StreakDayState.done,
        StreakDayState.today,
        StreakDayState.upcoming,
        StreakDayState.upcoming,
        StreakDayState.upcoming,
      ],
      quizzesCompleted: 14,
      categoriesMastered: '2/5',
      unlockedBadgeCount: 4,
    );

    final roundTripped = UserProgress.fromJson(progress.toJson());

    expect(roundTripped.level, 3);
    expect(roundTripped.xpCurrent, 650);
    expect(roundTripped.xpTarget, 1000);
    expect(roundTripped.currentStreak, 3);
    expect(roundTripped.bestStreak, 12);
    expect(roundTripped.streakStates, progress.streakStates);
    expect(roundTripped.quizzesCompleted, 14);
    expect(roundTripped.categoriesMastered, '2/5');
    expect(roundTripped.unlockedBadgeCount, 4);
    expect(roundTripped.xpProgress, closeTo(0.65, 0.0001));
    expect(roundTripped.isFreshAccount, isFalse);
  });
}
