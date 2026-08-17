import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/dot_indicator.dart';
import '../home/home_screen.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.heroAsset,
    required this.headline,
    required this.body,
    required this.buttonLabel,
  });

  final String heroAsset;
  final String headline;
  final Widget body;
  final String buttonLabel;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static final _pages = [
    _OnboardingPageData(
      heroAsset: 'assets/images/bitcoin_perfume.png',
      headline: 'Your Glow-Up in Bitcoin Starts Here ✨',
      body: const _BodyText(
        'Learn Bitcoin like beauty products — with gloss, grace & good vibes.',
      ),
      buttonLabel: 'Next',
    ),
    _OnboardingPageData(
      heroAsset: 'assets/images/belle_avatar.png',
      headline: 'Meet Belle, Your Bitcoin BFF ✨',
      body: const _BodyText(
        "She'll teach you Bitcoin the way your best friend would — no "
        'confusing jargon, just makeup bags, skincare routines, and '
        'glow-ups.',
      ),
      buttonLabel: 'Next',
    ),
    _OnboardingPageData(
      heroAsset: 'assets/images/trophy.png',
      headline: 'How it Works ✨',
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BoldLeadText(
            lead: 'Your Key Phrase: ',
            rest: 'No login, no passwords. Access from anywhere.',
          ),
          SizedBox(height: 6),
          _BoldLeadText(
            lead: 'Learn with Belle: ',
            rest: 'Bitcoin explained your way, BFF-style.',
          ),
          SizedBox(height: 6),
          _BoldLeadText(
            lead: 'Quiz Anytime: ',
            rest: 'Beginner to Advanced, test yourself whenever.',
          ),
        ],
      ),
      buttonLabel: 'Get Started',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _onPrimaryPressed() {
    if (_currentPage == _pages.length - 1) {
      _goToHome();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _OnboardingPage(
                data: _pages[index],
                onSkip: _goToHome,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: _pages[_currentPage].buttonLabel,
                    variant: AppButtonVariant.accent,
                    onPressed: _onPrimaryPressed,
                  ),
                  const SizedBox(height: 16),
                  DotIndicator(controller: _controller, count: _pages.length),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.onSkip});

  final _OnboardingPageData data;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heroHeight = MediaQuery.of(context).size.height * 0.5;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: heroHeight,
              child: Image.asset(data.heroAsset, fit: BoxFit.cover),
            ),
            Expanded(
              child: Container(
                color: AppColors.softBabyPink,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.headline, style: textTheme.headlineMedium),
                    const SizedBox(height: 14),
                    data.body,
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: heroHeight - 20,
          left: 24,
          child: const _WordmarkBadge(),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 20,
          child: _SkipButton(onTap: onSkip),
        ),
      ],
    );
  }
}

class _WordmarkBadge extends StatelessWidget {
  const _WordmarkBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bloomWhite,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowWalletGray.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'BITCOIN BEAUTY SCHOOL',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.glamPink,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bloomWhite.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Skip',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedMauve,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedMauve,
            height: 1.4,
          ),
    );
  }
}

class _BoldLeadText extends StatelessWidget {
  const _BoldLeadText({required this.lead, required this.rest});

  final String lead;
  final String rest;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.mutedMauve,
          height: 1.4,
        );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: lead,
            style: base?.copyWith(
              color: AppColors.shadowWalletGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: rest),
        ],
      ),
    );
  }
}
