import '../widgets/streak_day_row.dart';

/// The user's progress: level, XP, streak, quiz stats, and badge unlocks.
///
/// This is the same shape Home and Journey have always displayed (it
/// used to be hardcoded in `MockProgress`); it's now the real persisted
/// model, backed locally by shared_preferences and synced to Nostr as an
/// encrypted NIP-78 event. See `ProgressRepository`.
class UserProgress {
  const UserProgress({
    required this.level,
    required this.xpCurrent,
    required this.xpTarget,
    required this.currentStreak,
    required this.bestStreak,
    required this.streakStates,
    required this.quizzesCompleted,
    required this.categoriesMastered,
    required this.unlockedBadgeCount,
  });

  final int level;
  final int xpCurrent;
  final int xpTarget;
  final int currentStreak;
  final int bestStreak;
  final List<StreakDayState> streakStates;
  final int quizzesCompleted;
  final String categoriesMastered;

  /// How many entries at the front of the Journey badges list are
  /// unlocked.
  final int unlockedBadgeCount;

  double get xpProgress => xpTarget == 0 ? 0 : xpCurrent / xpTarget;

  /// True when nothing has happened on this account yet. Derived rather
  /// than stored, so it can't drift out of sync with the fields it's
  /// based on.
  bool get isFreshAccount =>
      quizzesCompleted == 0 && currentStreak == 0 && xpCurrent == 0;

  /// The state every brand-new account starts from.
  factory UserProgress.fresh() => const UserProgress(
    level: 1,
    xpCurrent: 0,
    xpTarget: 100,
    currentStreak: 0,
    bestStreak: 0,
    streakStates: [
      StreakDayState.upcoming,
      StreakDayState.upcoming,
      StreakDayState.upcoming,
      StreakDayState.upcoming,
      StreakDayState.upcoming,
      StreakDayState.upcoming,
      StreakDayState.upcoming,
    ],
    quizzesCompleted: 0,
    categoriesMastered: '0/5',
    unlockedBadgeCount: 0,
  );

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'] as int,
      xpCurrent: json['xpCurrent'] as int,
      xpTarget: json['xpTarget'] as int,
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      streakStates: (json['streakStates'] as List)
          .map((s) => StreakDayState.values.byName(s as String))
          .toList(),
      quizzesCompleted: json['quizzesCompleted'] as int,
      categoriesMastered: json['categoriesMastered'] as String,
      unlockedBadgeCount: json['unlockedBadgeCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'xpCurrent': xpCurrent,
    'xpTarget': xpTarget,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'streakStates': streakStates.map((s) => s.name).toList(),
    'quizzesCompleted': quizzesCompleted,
    'categoriesMastered': categoriesMastered,
    'unlockedBadgeCount': unlockedBadgeCount,
  };
}
