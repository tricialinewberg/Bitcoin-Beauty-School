import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../donate/donate_screen.dart';
import '../key_phrase/key_phrase_screen.dart';
import '../settings/settings_screen.dart';
import '../support/support_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.68;

    return Drawer(
      width: width,
      backgroundColor: AppColors.glamPink,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _MenuItem(
              icon: Icons.key_rounded,
              label: 'Key Phrase',
              onTap: () => _openScreen(context, const KeyPhraseScreen()),
            ),
            const _MenuDivider(),
            _MenuItem(
              icon: Icons.headset_mic_rounded,
              label: 'Support',
              onTap: () => _openScreen(context, const SupportScreen()),
            ),
            const _MenuDivider(),
            _MenuItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => _openScreen(context, const SettingsScreen()),
            ),
            const _MenuDivider(),
            _MenuItem(
              icon: Icons.bolt_rounded,
              label: 'Donate',
              onTap: () => _openScreen(context, const DonateScreen()),
            ),
            const _MenuDivider(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Bitcoin Beauty School v1.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.bloomWhite.withValues(alpha: 0.75),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.bloomWhite, size: 22),
              const SizedBox(width: 16),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.bloomWhite,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.bloomWhite.withValues(alpha: 0.25),
      height: 1,
      thickness: 1,
      indent: 24,
      endIndent: 24,
    );
  }
}
