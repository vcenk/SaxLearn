import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum BadgeType { gold, green, muted }

class BadgeChip extends StatelessWidget {
  final String label;
  final BadgeType type;

  const BadgeChip({
    super.key,
    required this.label,
    this.type = BadgeType.gold,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;

    switch (type) {
      case BadgeType.gold:
        bg = AppColors.gold.withValues(alpha: 0.15);
        text = AppColors.goldLight;
      case BadgeType.green:
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
      case BadgeType.muted:
        bg = Colors.white.withValues(alpha: 0.06);
        text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
}
