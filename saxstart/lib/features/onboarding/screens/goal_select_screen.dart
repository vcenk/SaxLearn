import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_sync.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../providers/onboarding_provider.dart';

class GoalSelectScreen extends ConsumerWidget {
  const GoalSelectScreen({super.key});

  static const _goals = [
    _GoalOption(
      id: 'first_notes',
      title: 'Learn my first notes',
      subtitle: 'Start from zero and make my first sounds',
      icon: Icons.piano_rounded,
    ),
    _GoalOption(
      id: 'improve_tone',
      title: 'Improve my tone',
      subtitle: 'Make my sound fuller and more stable',
      icon: Icons.graphic_eq_rounded,
    ),
    _GoalOption(
      id: 'daily_practice',
      title: 'Build a daily practice habit',
      subtitle: 'Consistent practice with streaks and goals',
      icon: Icons.calendar_today_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).goal;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text("What's your main goal?",
                  style: AppTypography.displaySmall),
              const SizedBox(height: 8),
              Text(
                "We'll tailor your experience accordingly",
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 32),
              ...List.generate(_goals.length, (i) {
                final goal = _goals[i];
                final isSelected = selected == goal.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(onboardingProvider.notifier)
                        .setGoal(goal.id),
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
                              goal.icon,
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
                                Text(goal.title,
                                    style: AppTypography.bodyLarge),
                                const SizedBox(height: 2),
                                Text(goal.subtitle,
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
                label: "Let's Go",
                onPressed: selected != null
                    ? () async {
                        ref
                            .read(onboardingProvider.notifier)
                            .completeOnboarding();

                        // If already authenticated, create/update user doc
                        // in Firestore right now. Otherwise, it'll be
                        // created after auth on the Auth screen.
                        final auth = ref.read(authProvider);
                        if (auth.isAuthenticated) {
                          await createUserOnOnboardingComplete(
                            auth: auth,
                            onboarding: ref.read(onboardingProvider),
                            userRepo: ref.read(userRepositoryProvider),
                            progressRepo:
                                ref.read(progressRepositoryProvider),
                          );
                          if (!context.mounted) return;
                          context.go('/home');
                        } else {
                          // Route through auth so we get a uid before
                          // writing to Firestore
                          context.go('/auth');
                        }
                      }
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

class _GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
