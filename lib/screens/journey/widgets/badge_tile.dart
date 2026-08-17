import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BadgeTile extends StatelessWidget {
  const BadgeTile({
    super.key,
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

  static const _lockedBg = Color(0xFFEDE3E7);
  static const _lockedIcon = Color(0xFFB6A8AE);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: locked ? _lockedBg : backgroundColor,
              ),
              child: Icon(
                icon,
                color: locked ? _lockedIcon : iconColor,
                size: 26,
              ),
            ),
            if (locked)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bloomWhite,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 12,
                    color: AppColors.mutedMauve,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: locked ? AppColors.mutedMauve.withValues(alpha: 0.6) : AppColors.shadowWalletGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
