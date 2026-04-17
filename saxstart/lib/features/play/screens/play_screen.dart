import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../providers/drill_provider.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drillState = ref.watch(drillProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Play Mode', style: AppTypography.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Test your skills with real-time scoring',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              _DrillCard(
                title: 'Tune the Note',
                description: 'Play a note and score your pitch accuracy',
                badge: 'Beginner',
                icon: Icons.music_note_rounded,
                onTap: () => context.go('/play/drill', extra: {
                  'drillType': 'tune',
                  'targetNote': 'B4',
                }),
              ),
              const SizedBox(height: 12),

              _DrillCard(
                title: 'Hold It Steady',
                description: 'Sustain a note and score your stability',
                badge: 'Beginner',
                icon: Icons.graphic_eq_rounded,
                onTap: () => context.go('/play/drill', extra: {
                  'drillType': 'hold',
                  'targetNote': 'B4',
                }),
              ),
              const SizedBox(height: 12),

              _DrillCard(
                title: 'Follow the Pattern',
                description: 'Play B, A, G in sequence',
                badge: 'Intermediate',
                icon: Icons.queue_music_rounded,
                onTap: () => context.go('/play/drill', extra: {
                  'drillType': 'pattern',
                  'targetNote': 'B4',
                }),
              ),
              const SizedBox(height: 32),

              Text('BEST SCORES', style: AppTypography.label),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    _ScoreRow(
                      drill: 'Tune the Note',
                      score: drillState.bestScores['tune']?.toString() ?? '--',
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 24),
                    _ScoreRow(
                      drill: 'Hold It Steady',
                      score: drillState.bestScores['hold']?.toString() ?? '--',
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 24),
                    _ScoreRow(
                      drill: 'Follow the Pattern',
                      score: drillState.bestScores['pattern']?.toString() ?? '--',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  final String title;
  final String description;
  final String badge;
  final IconData icon;
  final VoidCallback onTap;

  const _DrillCard({
    required this.title,
    required this.description,
    required this.badge,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.gold, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTypography.bodyLarge
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      BadgeChip(label: badge, type: BadgeType.muted),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String drill;
  final String score;

  const _ScoreRow({required this.drill, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(drill, style: AppTypography.bodyMedium),
        Text(
          score,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
