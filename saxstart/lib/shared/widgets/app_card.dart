import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool highlighted;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF1E1700) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.borderGold,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
