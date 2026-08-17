import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/section_label.dart';

/// Placeholder bank of full beauty-themed phrases. Real key-phrase
/// generation and Nostr derivation land in a later session.
const _mockPhraseBank = [
  'My blush never goes out of style',
  'Glow eternal, secret key',
  'Red lipstick, hidden balance',
  'Soft power, sharp focus',
  'Velvet touch, iron grip',
];

/// UI-only for now — reveal/restore are mocked. Real Nostr key derivation
/// and relay sync land in a later session.
class KeyPhraseScreen extends StatefulWidget {
  const KeyPhraseScreen({super.key});

  @override
  State<KeyPhraseScreen> createState() => _KeyPhraseScreenState();
}

class _KeyPhraseScreenState extends State<KeyPhraseScreen> {
  late final _mockPhrase =
      _mockPhraseBank[Random().nextInt(_mockPhraseBank.length)];

  final _restoreController = TextEditingController();
  bool _revealed = false;

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  void _copyPhrase() {
    Clipboard.setData(ClipboardData(text: _mockPhrase));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Key phrase copied')),
    );
  }

  void _restoreAccount() {
    if (_restoreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a key phrase first')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account restore isn't wired up yet — coming soon!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Key Phrase'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Key Phrase', style: textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              "This is what keeps your account yours. Save it somewhere "
              "safe — we can't recover it for you.",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    _revealed
                        ? _RevealedPhrase(phrase: _mockPhrase)
                        : const _BlurredPlaceholder(),
                    const SizedBox(height: 20),
                    AppButton(
                      label: _revealed ? 'Hide' : 'Reveal',
                      icon: _revealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      expand: false,
                      onPressed: () => setState(() => _revealed = !_revealed),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Copy Phrase',
              icon: Icons.copy_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: _copyPhrase,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorBlush.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.errorBlush.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Anyone with this phrase has full access to your account. '
                'Never screenshot, send, or show it to anyone — not even '
                'Belle.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.errorBlush,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.mutedMauve.withValues(alpha: 0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedMauve,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.mutedMauve.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: 24),
            const SectionLabel('Switched devices?'),
            const SizedBox(height: 8),
            Text('Restore From Another Phrase', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Paste a key phrase from another device to bring your '
              'account here. This will replace what\'s on this device.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _restoreController,
              decoration: const InputDecoration(hintText: 'Enter your key phrase...'),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Restore Account', onPressed: _restoreAccount),
          ],
        ),
      ),
    );
  }
}

class _BlurredPlaceholder extends StatelessWidget {
  const _BlurredPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 18,
          width: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 18,
          width: 170,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ],
    );
  }
}

class _RevealedPhrase extends StatelessWidget {
  const _RevealedPhrase({required this.phrase});

  final String phrase;

  @override
  Widget build(BuildContext context) {
    return Text(
      phrase,
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }
}
