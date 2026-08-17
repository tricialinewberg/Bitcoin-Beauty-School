import 'package:flutter/material.dart';

import '../../data/identity_repository.dart';
import '../../theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _displayDuration = Duration(milliseconds: 1500);
  static const _fadeDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    // Run the splash timer and identity bootstrap concurrently — first
    // launch generates and persists a suggested key phrase, later
    // launches just load the existing one. Either way Home always has an
    // active identity to read/write progress against by the time it's
    // reached.
    Future.wait([
      Future.delayed(_displayDuration),
      IdentityRepository.instance.ensureIdentity(),
    ]).then((_) => _goToOnboarding());
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: _fadeDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White (not Soft Baby Pink) so logo.png's own white background
      // blends in seamlessly with no visible edge.
      backgroundColor: AppColors.bloomWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}
