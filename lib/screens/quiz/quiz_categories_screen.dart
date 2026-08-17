import 'package:flutter/material.dart';

import '../../data/quiz_repository.dart';
import '../../theme/app_colors.dart';
import '../home/widgets/app_bottom_nav_bar.dart';
import '../journey/journey_screen.dart';
import '../menu/side_menu.dart';
import '../belle/belle_screen.dart';
import '../home/home_screen.dart';
import 'quiz_landing_screen.dart';

class _CategoryInfo {
  const _CategoryInfo({
    required this.difficulty,
    required this.description,
    required this.icon,
    required this.badgeColor,
    required this.badgeAlignment,
  });

  final QuizDifficulty difficulty;
  final String description;
  final IconData icon;
  final Color badgeColor;
  final Alignment badgeAlignment;
}

const _categories = [
  _CategoryInfo(
    difficulty: QuizDifficulty.beginner,
    description: 'New to Bitcoin? Start here — no dumb questions, promise.',
    icon: Icons.workspace_premium_rounded,
    badgeColor: AppColors.glamPink,
    badgeAlignment: Alignment.topLeft,
  ),
  _CategoryInfo(
    difficulty: QuizDifficulty.intermediate,
    description: "You know the basics. Let's level up your glow.",
    icon: Icons.auto_awesome_rounded,
    badgeColor: AppColors.bitcoinOrange,
    badgeAlignment: Alignment.topCenter,
  ),
  _CategoryInfo(
    difficulty: QuizDifficulty.advanced,
    description: 'For certified Bitcoin besties. Prove it.',
    icon: Icons.diamond_rounded,
    badgeColor: AppColors.deepGlamPink,
    badgeAlignment: Alignment.topRight,
  ),
];

class QuizCategoriesScreen extends StatelessWidget {
  const QuizCategoriesScreen({super.key});

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
        return;
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
            Text('Beauty Quizzes 💅', style: textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Test your glow-up knowledge.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 28),
            for (var i = 0; i < _categories.length; i++) ...[
              if (i != 0) const SizedBox(height: 24),
              _CategoryCard(
                key: ValueKey(_categories[i].difficulty),
                info: _categories[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizLandingScreen(difficulty: _categories[i].difficulty),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onTabTap(context, index),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({super.key, required this.info, required this.onTap});

  final _CategoryInfo info;
  final VoidCallback onTap;

  static const _badgeSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _badgeSize / 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 190),
            child: Material(
              color: AppColors.bloomWhite,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.difficulty.label,
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      // Fixed height (not just maxLines) so card height
                      // doesn't depend on whether a description happens to
                      // wrap to 1 or 2 lines.
                      SizedBox(
                        height: 44,
                        child: Text(
                          info.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.mutedMauve,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Take the Quiz',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.glamPink,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.glamPink,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (info.badgeAlignment == Alignment.topCenter)
          Positioned(top: 0, left: 0, right: 0, child: Center(child: _badge))
        else
          Positioned(
            top: 0,
            left: info.badgeAlignment == Alignment.topLeft ? 20 : null,
            right: info.badgeAlignment == Alignment.topRight ? 20 : null,
            child: _badge,
          ),
      ],
    );
  }

  Widget get _badge => Container(
    width: _badgeSize,
    height: _badgeSize,
    decoration: BoxDecoration(shape: BoxShape.circle, color: info.badgeColor),
    child: Icon(info.icon, color: AppColors.bloomWhite, size: 26),
  );
}
