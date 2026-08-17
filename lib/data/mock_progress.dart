import '../widgets/streak_day_row.dart';

/// Hardcoded stand-in for the user's progress, shared by Home and Journey
/// so both screens agree. Real data comes from encrypted Nostr events in a
/// later session.
abstract final class MockProgress {
  static const level = 3;
  static const xpCurrent = 650;
  static const xpTarget = 1000;
  static const double xpProgress = xpCurrent / xpTarget;

  static const currentStreak = 3;
  static const bestStreak = 12;
  static const streakStates = [
    StreakDayState.done,
    StreakDayState.done,
    StreakDayState.done,
    StreakDayState.today,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
  ];

  static const quizzesCompleted = 14;
  static const categoriesMastered = '2/5';
}
