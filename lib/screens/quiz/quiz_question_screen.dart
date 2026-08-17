import 'package:flutter/material.dart';

import '../../data/quiz_repository.dart';
import '../../models/quiz_question.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/glow_progress_bar.dart';
import 'quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({
    super.key,
    required this.difficulty,
    required this.questions,
  });

  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _currentIndex = 0;
  String? _selectedOptionId;
  int _correctCount = 0;

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;

  Future<void> _confirmQuit() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text("Your progress on this attempt won't be saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Quit',
              style: TextStyle(color: AppColors.errorBlush),
            ),
          ),
        ],
      ),
    );

    if (shouldQuit == true && mounted) {
      // Pop this question screen and the landing screen beneath it, back
      // to the categories list.
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  void _onPrimaryPressed() {
    final correct = _selectedOptionId == _currentQuestion.correctOptionId;
    final updatedCount = _correctCount + (correct ? 1 : 0);

    if (_isLastQuestion) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            difficulty: widget.difficulty,
            score: updatedCount,
            total: widget.questions.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      _correctCount = updatedCount;
      _currentIndex += 1;
      _selectedOptionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = widget.questions.length;
    final percent = (((_currentIndex + 1) / total) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: AppBar(
        backgroundColor: AppColors.softBabyPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.glamPink),
          onPressed: _confirmQuit,
        ),
        actions: [
          TextButton(
            onPressed: _confirmQuit,
            child: Text(
              'Quit',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.difficulty.label} Quiz',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.glamPink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Question ${_currentIndex + 1} of $total · $percent% completed',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 14),
            GlowProgressBar(progress: (_currentIndex + 1) / total),
            const SizedBox(height: 24),
            Text(
              _currentQuestion.question,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.bitcoinOrange,
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < _currentQuestion.options.length; i++) ...[
              if (i != 0) const SizedBox(height: 12),
              _OptionRow(
                letter: String.fromCharCode(65 + i),
                text: _currentQuestion.options[i].text,
                selected:
                    _currentQuestion.options[i].originalId == _selectedOptionId,
                onTap: () => setState(
                  () => _selectedOptionId =
                      _currentQuestion.options[i].originalId,
                ),
              ),
            ],
            const SizedBox(height: 28),
            AppButton(
              label: _isLastQuestion ? 'Finish' : 'Next Question',
              icon: _isLastQuestion ? null : Icons.arrow_forward_rounded,
              variant: AppButtonVariant.accent,
              onPressed: _selectedOptionId == null ? null : _onPrimaryPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.bloomWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.glamPink : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.glamPink
                      : const Color(0xFFECE7E9),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? AppColors.bloomWhite
                          : AppColors.shadowWalletGray,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(text, style: textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
