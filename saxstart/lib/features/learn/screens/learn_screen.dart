import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../../../features/progress/providers/progress_provider.dart';
import '../../../features/learn/providers/lesson_provider.dart';
import '../../../data/models/module_model.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  int? _expandedModule;

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(modulesProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Lessons', style: AppTypography.displayMedium),
              const SizedBox(height: 24),
              ...List.generate(modules.length, (i) {
                final module = modules[i];
                final isUnlocked =
                    progress.isModuleUnlocked(module.number);
                final completedCount = module.lessons
                    .where((l) => progress.isLessonComplete(l.id))
                    .length;
                final isExpanded = _expandedModule == i;

                return _ModuleCard(
                  module: module,
                  isUnlocked: isUnlocked,
                  completedCount: completedCount,
                  isExpanded: isExpanded,
                  onTap: isUnlocked
                      ? () => setState(() {
                            _expandedModule = isExpanded ? null : i;
                          })
                      : null,
                  progress: progress,
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final bool isUnlocked;
  final int completedCount;
  final bool isExpanded;
  final VoidCallback? onTap;
  final dynamic progress;

  const _ModuleCard({
    required this.module,
    required this.isUnlocked,
    required this.completedCount,
    required this.isExpanded,
    required this.onTap,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = completedCount == module.totalLessons;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? AppColors.borderGold
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isUnlocked
                          ? Text(
                              '${module.number}',
                              style: AppTypography.displaySmall.copyWith(
                                fontSize: 20,
                                color: AppColors.gold,
                              ),
                            )
                          : const Icon(Icons.lock_rounded,
                              color: AppColors.textDisabled, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount of ${module.totalLessons} complete',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  BadgeChip(
                    label: isComplete
                        ? 'Done'
                        : isUnlocked
                            ? 'In Progress'
                            : 'Locked',
                    type: isComplete
                        ? BadgeType.green
                        : isUnlocked
                            ? BadgeType.gold
                            : BadgeType.muted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded lesson list
          if (isExpanded && isUnlocked)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: module.lessons.map((lesson) {
                  final isDone = progress.isLessonComplete(lesson.id);
                  final isCurrent =
                      progress.currentLessonId == lesson.id;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      isDone
                          ? Icons.check_circle
                          : isCurrent
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.circle_outlined,
                      color: isDone
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.gold
                              : AppColors.textDisabled,
                      size: 18,
                    ),
                    title: Text(
                      lesson.title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDone || isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '${lesson.durationMinutes} min',
                      style: AppTypography.caption,
                    ),
                    onTap: (isDone || isCurrent)
                        ? () => context.go(
                              '/learn/${lesson.moduleId}/${lesson.id}',
                            )
                        : null,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
