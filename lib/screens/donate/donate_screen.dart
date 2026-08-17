import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/section_label.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const _lightningAddress = 'tricia1@evento.cash';

  void _copyAddress(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _lightningAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lightning address copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Donate'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: AppColors.bitcoinOrange.withValues(alpha: 0.4),
                  ),
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.bitcoinOrange, Color(0xFFFFC24D)],
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.bloomWhite,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Support the Creator',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.glamPink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Want to help keep this project alive? A few sats always '
                  'make my day.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.bitcoinOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              AppCard(
                onTap: () => _copyAddress(context),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SectionLabel('Lightning Address'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBabyPink,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _lightningAddress,
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: AppColors.glamPink,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to copy',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedMauve,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Thank you for being part of the glow-up 🌸',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.glamPink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = size.width / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    const dashCount = 36;
    const sweepPerDash = (2 * math.pi) / dashCount * 0.6;
    const gapPerDash = (2 * math.pi) / dashCount - sweepPerDash;

    var start = 0.0;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, start, sweepPerDash, false, paint);
      start += sweepPerDash + gapPerDash;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
