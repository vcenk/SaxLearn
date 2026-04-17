import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'gold_button.dart';

class PremiumGate extends StatelessWidget {
  final String title;
  final String description;

  const PremiumGate({
    super.key,
    this.title = 'Premium Content',
    this.description = 'Upgrade to SaxStart Pro to unlock this feature',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.displaySmall.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GoldButton(
            label: 'Upgrade to Pro',
            onPressed: () {
              // TODO: Show paywall
            },
          ),
          const SizedBox(height: 8),
          Text(
            '\$7.99/month or \$49.99/year',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
