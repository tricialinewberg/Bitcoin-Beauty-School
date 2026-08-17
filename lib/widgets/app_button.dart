import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonVariant { primary, accent, secondary }

/// Fully rounded pill button matching the Figma design system.
///
/// [AppButtonVariant.primary] uses Glam Pink, [AppButtonVariant.accent] uses
/// Bitcoin Orange for standout CTAs, and [AppButtonVariant.secondary] is an
/// outlined pill for lower-emphasis actions.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSecondary = variant == AppButtonVariant.secondary;

    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.glamPink,
      AppButtonVariant.accent => AppColors.bitcoinOrange,
      AppButtonVariant.secondary => AppColors.bloomWhite,
    };

    final pressedColor = switch (variant) {
      AppButtonVariant.primary => AppColors.deepGlamPink,
      AppButtonVariant.accent => AppColors.bitcoinOrange,
      AppButtonVariant.secondary => AppColors.softBabyPink,
    };

    final foregroundColor =
        isSecondary ? AppColors.glamPink : AppColors.bloomWhite;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: foregroundColor),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.mutedMauve.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          shape: StadiumBorder(
            side: isSecondary
                ? const BorderSide(color: AppColors.glamPink, width: 1.5)
                : BorderSide.none,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? pressedColor
                : null,
          ),
        ),
        child: child,
      ),
    );
  }
}
