import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../widgets/detail_app_bar.dart';
import '../../widgets/section_label.dart';

class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

const _faqs = [
  _Faq(
    'Is Bitcoin Beauty School free to use?',
    'Yes! 100% free, always. No subscriptions, no hidden fees, no ads. '
        'Just glow-ups and good vibes.',
  ),
  _Faq(
    'What is a key phrase?',
    "It's your beauty-themed passphrase — no email, no password. It's "
        "mathematically transformed into your account's private keys, "
        'just like a seed phrase does for a Bitcoin wallet.',
  ),
  _Faq(
    'How do I restore my account on a new device?',
    'Head to Key Phrase in the menu, tap Restore From Another Phrase, '
        "and enter your key phrase. We'll pull your progress right back "
        'down.',
  ),
  _Faq(
    'Is my data private?',
    'Yes. Your progress, streaks, and chat history are encrypted before '
        "they ever leave your device — we can't read them, and neither "
        'can anyone else.',
  ),
  _Faq(
    'Is this app open source?',
    'Yep! The full source is public — poke around, fork it, or send a '
        'pull request.',
  ),
];

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedIndex = 0;

  static const _email = 'triciaux@gmail.com';

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: _email));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Got questions, bestie? We've got answers.",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedMauve,
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('FAQs'),
            const SizedBox(height: 12),
            for (var i = 0; i < _faqs.length; i++) ...[
              _FaqTile(
                faq: _faqs[i],
                expanded: _expandedIndex == i,
                onTap: () => setState(() {
                  _expandedIndex = _expandedIndex == i ? null : i;
                }),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glamPink,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still need help?',
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.bloomWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Send us an email and we'll get back to you as soon as "
                    'we can.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.bloomWhite.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: AppColors.bloomWhite,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _copyEmail,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.email_rounded,
                              size: 18,
                              color: AppColors.glamPink,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _email,
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.glamPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.faq,
    required this.expanded,
    required this.onTap,
  });

  final _Faq faq;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.bloomWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.mutedMauve,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: AppColors.mutedMauve.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faq.answer,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedMauve,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
