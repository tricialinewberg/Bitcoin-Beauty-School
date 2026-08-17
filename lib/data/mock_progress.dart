import '../widgets/streak_day_row.dart';

/// Hardcoded stand-in for the user's progress, shared by Home and Journey
/// so both screens agree. Reflects a brand-new account (nothing done yet),
/// since that's what every real user actually sees first. Real data comes
/// from encrypted Nostr events in a later session.
abstract final class MockProgress {
  static const isFreshAccount = true;

  static const level = 1;
  static const xpCurrent = 0;
  static const xpTarget = 100;
  static const double xpProgress = xpCurrent / xpTarget;

  static const currentStreak = 0;
  static const bestStreak = 0;
  static const streakStates = [
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
    StreakDayState.upcoming,
  ];

  static const quizzesCompleted = 0;
  static const categoriesMastered = '0/5';

  /// How many entries at the front of the badges list are unlocked.
  static const unlockedBadgeCount = 0;
}
