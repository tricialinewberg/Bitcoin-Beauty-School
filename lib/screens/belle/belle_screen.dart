import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/detail_app_bar.dart';

/// Placeholder — Belle's chat experience is built in a later session.
class BelleScreen extends StatelessWidget {
  const BelleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Belle'),
      body: Center(
        child: Text(
          'Belle chat — coming soon',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.mutedMauve),
        ),
      ),
    );
  }
}
