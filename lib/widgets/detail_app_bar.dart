import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The shared AppBar style used across the side menu's destination screens:
/// a pink back arrow, a pink Fredoka title, and an overflow icon.
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key, required this.title, this.onOverflowTap});

  final String title;
  final VoidCallback? onOverflowTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.softBabyPink,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.glamPink),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.glamPink,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.mutedMauve),
          onPressed: onOverflowTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing here yet')),
                );
              },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
