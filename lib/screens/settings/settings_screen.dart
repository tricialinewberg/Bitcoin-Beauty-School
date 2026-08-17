import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/section_label.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum _AppLanguage { english, spanish, portugueseBr }

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  _AppLanguage _language = _AppLanguage.english;
  bool _streakReminders = true;
  bool _soundEffects = true;
  bool _haptics = true;

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data?'),
        content: const Text(
          "This clears locally cached progress on this device. It won't "
          'affect data already synced to your key phrase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.errorBlush),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App data cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const SectionLabel('Appearance'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionLabel('Language'),
          const SizedBox(height: 12),
          RadioGroup<_AppLanguage>(
            groupValue: _language,
            onChanged: (value) {
              if (value != null) setState(() => _language = value);
            },
            child: _SettingsCard(
              children: const [
                _RadioRow<_AppLanguage>(
                  icon: Icons.language_rounded,
                  label: 'English',
                  value: _AppLanguage.english,
                ),
                _RadioRow<_AppLanguage>(
                  icon: Icons.translate_rounded,
                  label: 'Español',
                  value: _AppLanguage.spanish,
                ),
                _RadioRow<_AppLanguage>(
                  icon: Icons.translate_rounded,
                  label: 'Português (BR)',
                  value: _AppLanguage.portugueseBr,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Notifications & Sound'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.notifications_rounded,
                label: 'Streak Reminders',
                value: _streakReminders,
                onChanged: (value) => setState(() => _streakReminders = value),
              ),
              _ToggleRow(
                icon: Icons.volume_up_rounded,
                label: 'Sound Effects',
                value: _soundEffects,
                onChanged: (value) => setState(() => _soundEffects = value),
              ),
              _ToggleRow(
                icon: Icons.vibration_rounded,
                label: 'Haptics',
                value: _haptics,
                onChanged: (value) => setState(() => _haptics = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionLabel('App Info'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _InfoRow(label: 'App Version', trailing: '1.0.0'),
              _ActionRow(
                icon: Icons.delete_rounded,
                label: 'Clear App Data',
                onTap: _confirmClearData,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bloomWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: AppColors.mutedMauve.withValues(alpha: 0.15),
              ),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.glamPink, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.glamPink,
          ),
        ],
      ),
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final T value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => RadioGroup.maybeOf<T>(context)?.onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.glamPink, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ),
            Radio<T>(value: value, activeColor: AppColors.glamPink),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.trailing});

  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.titleLarge?.copyWith(fontSize: 16)),
          Text(
            trailing,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedMauve),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.errorBlush, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    color: AppColors.errorBlush,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
