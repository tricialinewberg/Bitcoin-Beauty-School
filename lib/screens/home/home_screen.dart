import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../menu/side_menu.dart';
import 'widgets/app_bottom_nav_bar.dart';

/// Placeholder Home scaffold: background, bottom tab bar, and the hamburger
/// menu that opens the side menu. Real Home content comes in a later
/// session.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  void _onTabTap(int index) {
    if (index == 0) {
      setState(() => _tabIndex = index);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      endDrawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.softBabyPink,
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: AppColors.glamPink),
      ),
      body: Center(
        child: Text(
          'Home — coming soon',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.mutedMauve),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _tabIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
