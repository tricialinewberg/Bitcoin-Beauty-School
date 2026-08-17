import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const BitcoinBeautySchoolApp());
}

class BitcoinBeautySchoolApp extends StatelessWidget {
  const BitcoinBeautySchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Beauty School',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _FoundationPlaceholder(),
    );
  }
}

/// Temporary placeholder confirming the theme is wired up correctly.
/// Real screens (onboarding, home, Belle, quiz, etc.) come next.
class _FoundationPlaceholder extends StatelessWidget {
  const _FoundationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bitcoin Beauty School',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
