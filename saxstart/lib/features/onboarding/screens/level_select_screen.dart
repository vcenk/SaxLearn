import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/onboarding_provider.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  static const _levels = [
    _LevelOption(
      id: 'beginner',
      title: 'Absolute Beginner',
      subtitle: 'I just bought a saxophone',
      icon: Icons.child_care_rounded,
    ),
    _LevelOption(
      id: 'returning',
      title: 'Returning Player',
      subtitle: 'I played before and want a refresher',
      icon: Icons.refresh_rounded,
    ),
    _LevelOption(
      id: 'school_band',
      title: 'School Band Starter',
      subtitle: 'I\'m in a school band and want extra practice',
      icon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).level;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Where are you starting?',
                  style: AppTypography.displaySmall),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your learning path',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 32),
              ...List.generate(_levels.length, (i) {
                final level = _levels[i];
                final isSelected = selected == level.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(onboardingProvider.notifier)
                        .setLevel(level.id),
                    child: AppCard(
                      highlighted: isSelected,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold.withValues(alpha: 0.2)
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              level.icon,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(level.title,
                                    style: AppTypography.bodyLarge),
                                const SizedBox(height: 2),
                                Text(level.subtitle,
                                    style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.gold, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              GoldButton(
                label: 'Continue',
                onPressed: selected != null
                    ? () => context.go('/onboarding/goal')
                    : () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _LevelOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
