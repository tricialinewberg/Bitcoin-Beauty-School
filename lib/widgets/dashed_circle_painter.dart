import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a dashed circle outline. Used for decorative rings (Donate) and
/// the "today" indicator in [StreakDayRow].
class DashedCirclePainter extends CustomPainter {
  const DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashCount = 36,
  });

  final Color color;
  final double strokeWidth;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = size.width / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final sweepPerDash = (2 * math.pi) / dashCount * 0.6;
    final gapPerDash = (2 * math.pi) / dashCount - sweepPerDash;

    var start = 0.0;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, start, sweepPerDash, false, paint);
      start += sweepPerDash + gapPerDash;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
