import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A row of dots that tracks a [PageController]'s scroll position smoothly,
/// rather than snapping between pages.
class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.activeColor = AppColors.glamPink,
    this.inactiveColor = const Color(0xFFF6C6DD),
  });

  final PageController controller;
  final int count;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double page = 0;
        if (controller.hasClients && controller.position.hasContentDimensions) {
          page = controller.page ?? controller.initialPage.toDouble();
        } else {
          page = controller.initialPage.toDouble();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final distance = (page - index).abs().clamp(0.0, 1.0);
            final t = 1 - distance;
            final width = 8.0 + (16.0 * t);
            final color = Color.lerp(inactiveColor, activeColor, t)!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: 8,
                width: width,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
