import 'package:flutter/material.dart';

import '../../data/mock_progress.dart';
import '../../data/quiz_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/glow_progress_bar.dart';
import '../../widgets/section_label.dart';
import '../../widgets/streak_day_row.dart';
import '../belle/belle_screen.dart';
import '../journey/journey_screen.dart';
import '../menu/side_menu.dart';
import '../quiz/quiz_categories_screen.dart';
import '../quiz/quiz_landing_screen.dart';
import 'widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BelleScreen()),
        );
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuizCategoriesScreen()),
        );
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const JourneyScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            Text('Hi, Bestie 👋', style: textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Ready for today\'s glow-up?',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 20),
            const _JourneyStripCard(),
            const SizedBox(height: 20),
            const _StreakCard(),
            const SizedBox(height: 20),
            _ContinueWithBelleCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BelleScreen()),
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('Bitcoin Beauty Tip'),
            const SizedBox(height: 12),
            const _TipCard(),
            const SizedBox(height: 24),
            const SectionLabel('Quick Practice'),
            const SizedBox(height: 12),
            _QuickPracticeRow(
              onSelect: (difficulty) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizLandingScreen(difficulty: difficulty),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onTabTap(context, index),
      ),
    );
  }
}

class _JourneyStripCard extends StatelessWidget {
  const _JourneyStripCard();

  @override
  Widget build(BuildContext context) {
    final percent = (MockProgress.xpProgress * 100).round();

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
            'YOUR JOURNEY ✨',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.bloomWhite,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          const GlowProgressBar(progress: MockProgress.xpProgress),
          const SizedBox(height: 8),
          Text(
            '$percent% to next level',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.bloomWhite.withValues(alpha: 0.85),
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
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${MockProgress.currentStreak} Day Streak 🔥',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            StreakDayRow(states: MockProgress.streakStates),
            const SizedBox(height: 16),
            Center(
              child: Text(
                MockProgress.currentStreak == 0
                    ? 'Start your streak today!'
                    : 'Keep glowing — come back tomorrow!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedMauve,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueWithBelleCard extends StatelessWidget {
  const _ContinueWithBelleCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.glamPink,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(
                  'assets/images/belle_avatar.png',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MockProgress.isFreshAccount
                          ? 'Start Chatting with Belle'
                          : 'Continue with Belle',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.bloomWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      MockProgress.isFreshAccount
                          ? "She's ready to help you learn"
                          : 'Pick up where you left off',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.bloomWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.bloomWhite),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bitcoinOrange.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.bitcoinOrange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Private Key Is Like Your Diary 🔐',
                    style: textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Never share it — not even with your bestie. Some '
                    'things stay just yours.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedMauve,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPracticeRow extends StatelessWidget {
  const _QuickPracticeRow({required this.onSelect});

  final ValueChanged<QuizDifficulty> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < QuizDifficulty.values.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              label: QuizDifficulty.values[i].label,
              variant: AppButtonVariant.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              onPressed: () => onSelect(QuizDifficulty.values[i]),
            ),
          ),
        ],
      ],
    );
  }
}
