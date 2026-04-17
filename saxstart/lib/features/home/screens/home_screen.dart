import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../features/progress/providers/progress_provider.dart';
import '../../../features/learn/providers/lesson_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final currentLesson = ref.watch(lessonByIdProvider(progress.currentLessonId));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(), style: AppTypography.bodySmall),
                      const SizedBox(height: 2),
                      Text('Saxophonist',
                          style: AppTypography.displaySmall),
                    ],
                  ),
                  Row(
                    children: [
                      if (progress.currentStreak > 0)
                        BadgeChip(
                          label: '${progress.currentStreak} day streak',
                          type: BadgeType.gold,
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderGold),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Continue Lesson Card
              if (currentLesson != null)
                AppCard(
                  highlighted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONTINUE LEARNING', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Text(currentLesson.title,
                          style: AppTypography.bodyLarge
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'Module ${currentLesson.moduleNumber} — Lesson ${currentLesson.lessonNumber}',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      AppProgressBar(
                        value: progress.lessonsCompleted / 17,
                      ),
                      const SizedBox(height: 12),
                      GoldButton(
                        label: 'Resume Lesson',
                        onPressed: () => context.go(
                          '/learn/${currentLesson.moduleId}/${currentLesson.id}',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Daily Practice Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Practice",
                            style: AppTypography.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600)),
                        const BadgeChip(label: '10 min', type: BadgeType.muted),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TaskRow(
                      title: 'Long tone warm-up',
                      status: _TaskStatus.done,
                    ),
                    _TaskRow(
                      title: 'Continue lesson',
                      status: _TaskStatus.current,
                    ),
                    _TaskRow(
                      title: 'Play Mode drill',
                      status: _TaskStatus.upcoming,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Tools
              Text('QUICK TOOLS', style: AppTypography.label),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _ToolCard(
                    icon: Icons.tune_rounded,
                    label: 'Tuner',
                    onTap: () => context.go('/tools'),
                  ),
                  _ToolCard(
                    icon: Icons.timer_rounded,
                    label: 'Metronome',
                    onTap: () => context.go('/tools'),
                  ),
                  _ToolCard(
                    icon: Icons.piano_rounded,
                    label: 'Fingering',
                    onTap: () => context.go('/tools'),
                  ),
                  _ToolCard(
                    icon: Icons.star_rounded,
                    label: 'Play Mode',
                    onTap: () => context.go('/play'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              Text('YOUR STATS', style: AppTypography.label),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '${progress.lessonsCompleted}',
                      label: 'Lessons',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      value: '${progress.totalPracticeMinutes}m',
                      label: 'Practice',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      value: '${progress.currentStreak}',
                      label: 'Streak',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TaskStatus { done, current, upcoming }

class _TaskRow extends StatelessWidget {
  final String title;
  final _TaskStatus status;

  const _TaskRow({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            status == _TaskStatus.done
                ? Icons.check_circle
                : status == _TaskStatus.current
                    ? Icons.play_circle_filled
                    : Icons.circle_outlined,
            color: status == _TaskStatus.done
                ? AppColors.success
                : status == _TaskStatus.current
                    ? AppColors.gold
                    : AppColors.textDisabled,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: status == _TaskStatus.upcoming
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGold),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.gold, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTypography.displaySmall.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
