import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';

/// Assembles the design tokens into a single [ThemeData] for the app.
abstract final class AppTheme {
  static ThemeData get light {
    final textTheme = AppTextTheme.textTheme;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.glamPink,
      brightness: Brightness.light,
      primary: AppColors.glamPink,
      onPrimary: AppColors.bloomWhite,
      secondary: AppColors.bitcoinOrange,
      onSecondary: AppColors.bloomWhite,
      surface: AppColors.bloomWhite,
      onSurface: AppColors.shadowWalletGray,
      error: AppColors.errorBlush,
      onError: AppColors.bloomWhite,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.softBabyPink,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.softBabyPink,
        foregroundColor: AppColors.shadowWalletGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bloomWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.glamPink,
          foregroundColor: AppColors.bloomWhite,
          disabledBackgroundColor: AppColors.mutedMauve.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? AppColors.deepGlamPink
                : null,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.glamPink,
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.glamPink),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bloomWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
