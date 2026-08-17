import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded progress bar: translucent white track, Bitcoin Orange fill.
/// Used on the gradient level/journey cards.
class GlowProgressBar extends StatelessWidget {
  const GlowProgressBar({super.key, required this.progress, this.height = 10});

  /// 0.0 to 1.0
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(
            height: height,
            color: AppColors.bloomWhite.withValues(alpha: 0.35),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(height: height, color: AppColors.bitcoinOrange),
          ),
        ],
      ),
    );
  }
}
