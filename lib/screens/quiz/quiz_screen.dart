import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/detail_app_bar.dart';

/// Placeholder — real quiz content and scoring are built in a later
/// session.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, this.difficulty});

  final String? difficulty;

  @override
  Widget build(BuildContext context) {
    final message = difficulty == null
        ? 'Quiz — coming soon'
        : '$difficulty Quiz — coming soon';

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Quiz'),
      body: Center(
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.mutedMauve),
        ),
      ),
    );
  }
}
