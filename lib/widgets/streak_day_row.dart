import 'package:flutter/material.dart';

import 'dashed_circle_painter.dart';
import '../theme/app_colors.dart';

enum StreakDayState { done, today, upcoming }

/// The S M T W T F S row of streak-day circles used on Home and Journey.
class StreakDayRow extends StatelessWidget {
  const StreakDayRow({super.key, required this.states}) : assert(states.length == 7);

  final List<StreakDayState> states;

  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.mutedMauve,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return Column(
          children: [
            Text(_labels[index], style: labelStyle),
            const SizedBox(height: 8),
            _DayCircle(state: states[index]),
          ],
        );
      }),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.state});

  final StreakDayState state;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StreakDayState.done:
        return Container(
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bitcoinOrange,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.bloomWhite,
            size: 18,
          ),
        );
      case StreakDayState.today:
        return SizedBox(
          width: _size,
          height: _size,
          child: CustomPaint(
            painter: DashedCirclePainter(
              color: AppColors.glamPink,
              strokeWidth: 2,
              dashCount: 14,
            ),
          ),
        );
      case StreakDayState.upcoming:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.mutedMauve.withValues(alpha: 0.25),
            ),
          ),
        );
    }
  }
}
