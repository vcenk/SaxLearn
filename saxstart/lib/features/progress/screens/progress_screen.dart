import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../features/progress/providers/progress_provider.dart';
import '../../../features/learn/providers/lesson_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Progress', style: AppTypography.displayMedium),
              const SizedBox(height: 24),

              // Top stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${progress.totalPracticeMinutes}',
                      label: 'Minutes',
                      icon: Icons.timer_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '${progress.lessonsCompleted}',
                      label: 'Lessons',
                      icon: Icons.menu_book_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '${progress.currentStreak}',
                      label: 'Streak',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // This Week
              Text('THIS WEEK', style: AppTypography.label),
              const SizedBox(height: 12),
              _WeekRow(),
              const SizedBox(height: 32),

              // Module Progress
              Text('MODULE PROGRESS', style: AppTypography.label),
              const SizedBox(height: 12),
              ...modules.map((module) {
                final completed = module.lessons
                    .where((l) => progress.isLessonComplete(l.id))
                    .length;
                final pct = module.totalLessons > 0
                    ? completed / module.totalLessons
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(module.title, style: AppTypography.bodyMedium),
                          Text(
                            '${(pct * 100).round()}%',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppProgressBar(
                        value: pct,
                        color:
                            pct >= 1.0 ? AppColors.success : AppColors.gold,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Achievements
              Text('ACHIEVEMENTS', style: AppTypography.label),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _AchievementCard(
                    icon: Icons.music_note_rounded,
                    title: 'First Lesson',
                    earned: progress.lessonsCompleted >= 1,
                  ),
                  _AchievementCard(
                    icon: Icons.local_fire_department_rounded,
                    title: '3-Day Streak',
                    earned: progress.longestStreak >= 3,
                  ),
                  _AchievementCard(
                    icon: Icons.timer_rounded,
                    title: '30 Min Club',
                    earned: progress.totalPracticeMinutes >= 30,
                  ),
                  _AchievementCard(
                    icon: Icons.star_rounded,
                    title: 'First A Note',
                    earned: progress.isLessonComplete('m2_l3'),
                  ),
                  _AchievementCard(
                    icon: Icons.star_border_rounded,
                    title: 'First G Note',
                    earned: progress.isLessonComplete('m2_l4'),
                  ),
                  _AchievementCard(
                    icon: Icons.local_fire_department_rounded,
                    title: '7-Day Streak',
                    earned: progress.longestStreak >= 7,
                  ),
                  _AchievementCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Module 2 Done',
                    earned: progress.isLessonComplete('m2_l5'),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

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
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: AppTypography.displaySmall.copyWith(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final dayIndex = i + 1;
        final isToday = dayIndex == weekday;
        final isPast = dayIndex < weekday;

        return Column(
          children: [
            Text(_days[i], style: AppTypography.caption),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? AppColors.goldLight
                    : isPast
                        ? AppColors.gold.withValues(alpha: 0.3)
                        : AppColors.surfaceElevated,
                border: isToday
                    ? Border.all(color: AppColors.gold, width: 2)
                    : null,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool earned;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned ? AppColors.gold.withValues(alpha: 0.3) : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: earned ? AppColors.gold : AppColors.textDisabled, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: earned ? AppColors.textPrimary : AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
            if (earned) ...[
              const SizedBox(height: 4),
              Text(
                'Earned!',
                style: AppTypography.caption.copyWith(color: AppColors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
