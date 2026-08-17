import 'package:flutter/material.dart';

import '../../data/quiz_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import 'quiz_landing_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.difficulty,
    required this.score,
    required this.total,
  });

  final QuizDifficulty difficulty;
  final int score;
  final int total;

  double get _percent => total == 0 ? 0 : score / total;

  /// Only the passing tier (80%+) unlocks progression to the next level.
  bool get _passed => _percent >= 0.8;

  ({String headline, String subtitle, String belleQuote}) get _copy {
    if (_percent == 1) {
      return (
        headline: 'Perfect Score! ✨',
        subtitle: 'Flawless, bestie — you know your stuff inside and out.',
        belleQuote: "I'm so proud of you! Ready for the next level? 💕",
      );
    }
    if (_passed) {
      return (
        headline: "You're Glowing! ✨",
        subtitle: 'Almost perfect, bestie — you really know your stuff.',
        belleQuote: "I'm so proud of you! Ready for the next level? 💕",
      );
    }
    if (_percent >= 0.6) {
      return (
        headline: 'So Close! 💪',
        subtitle:
            "You're getting the hang of it — a bit more practice and "
            "you'll ace it.",
        belleQuote: "You're getting there! I believe in you. 💪",
      );
    }
    return (
      headline: "Let's Glow Up Your Knowledge 🌱",
      subtitle: "This one needs a little more practice — that's what the "
          "journey's for.",
      belleQuote: "No worries, bestie — even the best glow-ups take a few "
          'tries. Want to review and come back stronger? 💕',
    );
  }

  /// Green for the passing tier, Bitcoin Orange for "So Close!", and a
  /// neutral muted tone for the tier that most needs review.
  Color get _ringColor {
    if (_passed) return AppColors.successGlow;
    if (_percent >= 0.6) return AppColors.bitcoinOrange;
    return AppColors.mutedMauve;
  }

  void _backToQuizzes(BuildContext context) {
    // Pop this Result screen and the Landing screen beneath it, back to
    // the categories list.
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final copy = _copy;
    final ringColor = _ringColor;
    final next = _passed ? difficulty.next : null;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: AppBar(
        backgroundColor: AppColors.softBabyPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.glamPink),
          onPressed: () => _backToQuizzes(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            Text(
              copy.headline,
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.glamPink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              copy.subtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedMauve,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bloomWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowWalletGray.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$score/$total',
                  style: textTheme.displayLarge?.copyWith(color: ringColor),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _ResultChip(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.bitcoinOrange,
                  label: '+50 XP',
                  labelColor: AppColors.shadowWalletGray,
                ),
                if (_passed) ...[
                  const SizedBox(width: 12),
                  const _ResultChip(
                    icon: Icons.emoji_events_rounded,
                    iconColor: Color(0xFFE8B923),
                    label: 'New Badge Unlocked',
                    labelColor: AppColors.glamPink,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bloomWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      'assets/images/belle_avatar.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '"${copy.belleQuote} — Belle"',
                      style: textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (next != null) ...[
              AppButton(
                label: 'Try ${next.label} Level →',
                variant: AppButtonVariant.accent,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizLandingScreen(difficulty: next),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Back to Quizzes',
              variant: AppButtonVariant.secondary,
              onPressed: () => _backToQuizzes(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bloomWhite,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
