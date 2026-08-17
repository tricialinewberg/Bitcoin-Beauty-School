import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/data/identity_repository.dart';
import 'package:bitcoin_beauty_school/data/progress_repository.dart';
import 'package:bitcoin_beauty_school/data/user_progress.dart';

// Covers the local-first cache path deterministically. save() does kick
// off a fire-and-forget background relay publish (unawaited, all errors
// swallowed internally) — that's the one bit of behavior here that isn't
// fully offline, but the test itself never awaits or depends on its
// outcome, so it doesn't affect pass/fail. The relay round trip itself is
// a documented manual check.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IdentityRepository.instance.resetForTesting();
  });

  test('load() with no cache and no identity falls back to a fresh account', () async {
    final progress = await ProgressRepository.instance.load();

    expect(progress.toJson(), UserProgress.fresh().toJson());
  });

  test('save() then load() round-trips through the local cache', () async {
    const progress = UserProgress(
      level: 2,
      xpCurrent: 40,
      xpTarget: 200,
      currentStreak: 1,
      bestStreak: 1,
      streakStates: [],
      quizzesCompleted: 1,
      categoriesMastered: '0/5',
      unlockedBadgeCount: 0,
    );

    await ProgressRepository.instance.save(progress);
    final loaded = await ProgressRepository.instance.load();

    expect(loaded.toJson(), progress.toJson());
  });

  test('clearLocalCache forces the next load() to rebuild from scratch', () async {
    await ProgressRepository.instance.save(
      const UserProgress(
        level: 9,
        xpCurrent: 1,
        xpTarget: 1,
        currentStreak: 1,
        bestStreak: 1,
        streakStates: [],
        quizzesCompleted: 1,
        categoriesMastered: '5/5',
        unlockedBadgeCount: 9,
      ),
    );

    await ProgressRepository.instance.clearLocalCache();

    // No identity is active in this test, so with the cache cleared,
    // load() can't find anything locally or on relays and falls back to
    // fresh — proving the stale level-9 snapshot is really gone, not just
    // shadowed.
    final loaded = await ProgressRepository.instance.load();
    expect(loaded.toJson(), UserProgress.fresh().toJson());
  });
}
