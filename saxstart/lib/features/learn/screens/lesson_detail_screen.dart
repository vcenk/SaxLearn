import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../../../features/learn/providers/lesson_provider.dart';
import '../../../features/progress/providers/progress_provider.dart';
import '../../../data/local_content/fingering_chart_data.dart';

class LessonDetailScreen extends ConsumerWidget {
  final String moduleId;
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonByIdProvider(lessonId));
    final progress = ref.watch(progressProvider);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final isComplete = progress.isLessonComplete(lessonId);
    final fingeringNote = lesson.noteReference != null
        ? beginnerNotes.where((n) => n.name == lesson.noteReference).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Module ${lesson.moduleNumber}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BadgeChip(
              label: '${lesson.durationMinutes} min',
              type: BadgeType.muted,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(lesson.title, style: AppTypography.displayMedium),
            const SizedBox(height: 16),

            // Objective
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBJECTIVE', style: AppTypography.label),
                  const SizedBox(height: 8),
                  Text(lesson.objective, style: AppTypography.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fingering Visual
            if (fingeringNote != null) ...[
              AppCard(
                highlighted: true,
                child: Column(
                  children: [
                    Text(
                      fingeringNote.name,
                      style: AppTypography.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    // Key diagram
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        final pressed = fingeringNote.keys[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pressed
                                  ? AppColors.gold
                                  : Colors.transparent,
                              border: Border.all(
                                color: pressed
                                    ? AppColors.gold
                                    : AppColors.textDisabled,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(fingeringNote.tip, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Practice Steps
            Text('PRACTICE STEPS', style: AppTypography.label),
            const SizedBox(height: 12),
            ...List.generate(lesson.steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.steps[i],
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(lesson.tip, style: AppTypography.bodyMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            if (lesson.noteReference != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoldButton(
                  label: 'Practice in Play Mode',
                  onPressed: () => context.go('/play/drill', extra: {
                    'drillType': 'tune',
                    'targetNote': '${lesson.noteReference}4',
                  }),
                ),
              ),

            if (!isComplete)
              GoldButton(
                label: 'Mark Complete',
                onPressed: () {
                  ref
                      .read(progressProvider.notifier)
                      .completeLesson(lessonId);
                  context.pop();
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lesson Complete',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
