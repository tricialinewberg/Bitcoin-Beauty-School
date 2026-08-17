import 'package:flutter/material.dart';

import '../../data/quiz_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/section_label.dart';
import 'quiz_question_screen.dart';

const _intros = {
  QuizDifficulty.beginner:
      "Let's see how much you already know about Bitcoin — beauty-style. "
      'No boring jargon, just vibes and facts.',
  QuizDifficulty.intermediate:
      "You've got the basics down. Time to see how deep your glow-up "
      'knowledge really goes.',
  QuizDifficulty.advanced:
      'The final glow-up test. These questions are for certified Bitcoin '
      'besties only.',
};

class QuizLandingScreen extends StatefulWidget {
  const QuizLandingScreen({super.key, required this.difficulty});

  final QuizDifficulty difficulty;

  @override
  State<QuizLandingScreen> createState() => _QuizLandingScreenState();
}

class _QuizLandingScreenState extends State<QuizLandingScreen> {
  bool _starting = false;

  Future<void> _startQuiz() async {
    setState(() => _starting = true);
    final questions = await QuizRepository.startAttempt(widget.difficulty);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(
          difficulty: widget.difficulty,
          questions: questions,
        ),
      ),
    );
    setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = '${widget.difficulty.label} Quiz';

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: DetailAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('10 Questions · ~2 min'),
            const SizedBox(height: 8),
            Text(title, style: textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              _intros[widget.difficulty]!,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedMauve,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: AppColors.mutedMauve.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            const _RuleRow(icon: Icons.description_rounded, label: '10 Questions'),
            const SizedBox(height: 18),
            const _RuleRow(icon: Icons.bolt_rounded, label: 'Instant Results'),
            const SizedBox(height: 18),
            const _RuleRow(icon: Icons.replay_rounded, label: 'Retake Anytime'),
            const SizedBox(height: 32),
            AppButton(
              label: "Let's Glow 💅",
              variant: AppButtonVariant.accent,
              onPressed: _starting ? null : _startQuiz,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Belle's cheering you on from the sidelines 👋",
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedMauve,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.glamPink.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.glamPink, size: 22),
        ),
        const SizedBox(width: 14),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
