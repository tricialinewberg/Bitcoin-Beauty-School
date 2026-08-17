import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small uppercase muted label used to head off a section (e.g. "APPEARANCE").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mutedMauve,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
    );
  }
}
