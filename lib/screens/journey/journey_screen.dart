import 'package:flutter/material.dart';

import '../../data/mock_progress.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/glow_progress_bar.dart';
import '../../widgets/streak_day_row.dart';
import '../belle/belle_screen.dart';
import '../home/home_screen.dart';
import '../home/widgets/app_bottom_nav_bar.dart';
import '../menu/side_menu.dart';
import '../quiz/quiz_screen.dart';
import 'widgets/badge_tile.dart';

class _BadgeData {
  const _BadgeData({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.mutedMauve,
    this.backgroundColor = const Color(0xFFEDE3E7),
    this.locked = false,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final bool locked;
}

const _creamBg = Color(0xFFFCEFD1);
const _pinkBg = Color(0xFFFAD7E6);

const _badges = [
  _BadgeData(
    icon: Icons.emoji_events_rounded,
    label: 'First Quiz',
    iconColor: AppColors.bitcoinOrange,
    backgroundColor: _creamBg,
  ),
  _BadgeData(
    icon: Icons.local_fire_department_rounded,
    label: '7-Day Streak',
    iconColor: AppColors.bitcoinOrange,
    backgroundColor: _creamBg,
  ),
  _BadgeData(
    icon: Icons.school_rounded,
    label: 'Beginner Master',
    iconColor: AppColors.glamPink,
    backgroundColor: _pinkBg,
  ),
  _BadgeData(
    icon: Icons.star_rounded,
    label: 'Perfect Score',
    iconColor: Color(0xFFE8B923),
    backgroundColor: _creamBg,
  ),
  _BadgeData(
    icon: Icons.lightbulb_rounded,
    label: 'Quick Learner',
    iconColor: AppColors.glamPink,
    backgroundColor: _pinkBg,
  ),
  _BadgeData(
    icon: Icons.vpn_key_rounded,
    label: 'Key Keeper',
    iconColor: AppColors.bitcoinOrange,
    backgroundColor: _creamBg,
  ),
  _BadgeData(
    icon: Icons.school_rounded,
    label: 'Intermediate Master',
    locked: true,
  ),
  _BadgeData(
    icon: Icons.school_rounded,
    label: 'Advanced Master',
    locked: true,
  ),
  _BadgeData(
    icon: Icons.favorite_rounded,
    label: "Belle's Best Friend",
    locked: true,
  ),
];

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BelleScreen()));
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
      case 3:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unlockedCount = _badges.where((b) => !b.locked).length;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      endDrawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.softBabyPink,
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: AppColors.glamPink),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Journey', style: textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              "Look how far you've glowed.",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 20),
            const _LevelCard(),
            const SizedBox(height: 20),
            const _StreakCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '${MockProgress.quizzesCompleted}',
                    label: 'Quizzes Completed',
                    color: AppColors.glamPink,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    value: MockProgress.categoriesMastered,
                    label: 'Categories Mastered',
                    color: AppColors.bitcoinOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Badges', style: textTheme.headlineSmall),
                ),
                Text(
                  '$unlockedCount of ${_badges.length} unlocked',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedMauve,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
              children: [
                for (final badge in _badges)
                  BadgeTile(
                    icon: badge.icon,
                    label: badge.label,
                    iconColor: badge.iconColor,
                    backgroundColor: badge.backgroundColor,
                    locked: badge.locked,
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onTabTap(context, index),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glamPink, AppColors.deepGlamPink],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT LEVEL',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.bloomWhite.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${MockProgress.level} ✨',
            style: textTheme.displaySmall?.copyWith(color: AppColors.bloomWhite),
          ),
          const SizedBox(height: 18),
          const GlowProgressBar(progress: MockProgress.xpProgress),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${MockProgress.xpCurrent} / ${MockProgress.xpTarget} XP to '
              'Level ${MockProgress.level + 1}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.bloomWhite.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${MockProgress.currentStreak} Day Streak 🔥',
                    style: textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Best: ${MockProgress.bestStreak} days 🏆',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedMauve,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreakDayRow(states: MockProgress.streakStates),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.displaySmall?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
