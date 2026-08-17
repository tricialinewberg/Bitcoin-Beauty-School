import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens: Fredoka for headlines, Nunito Sans for body text.
abstract final class AppTextTheme {
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: AppColors.shadowWalletGray,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.shadowWalletGray,
        ),
        headlineLarge: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.shadowWalletGray,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.shadowWalletGray,
        ),
        headlineSmall: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.shadowWalletGray,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.shadowWalletGray,
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.shadowWalletGray,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.shadowWalletGray,
        ),
        bodySmall: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedMauve,
        ),
        labelLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.bloomWhite,
        ),
      );
}
