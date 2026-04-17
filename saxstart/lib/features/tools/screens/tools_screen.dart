import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/local_content/fingering_chart_data.dart';
import '../../../core/services/note_player_service.dart';
import '../metronome/metronome_provider.dart';
import '../tuner/tuner_provider.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  // Fingering state
  int _selectedNoteIndex = 0;
  final _notePlayer = NotePlayerService();

  @override
  void dispose() {
    _notePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metro = ref.watch(metronomeProvider);
    final tuner = ref.watch(tunerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Tools', style: AppTypography.displayMedium),
              const SizedBox(height: 24),

              // TUNER SECTION
              Text('TUNER', style: AppTypography.label),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    Text(tuner.detectedNote,
                        style: AppTypography.displayLarge),
                    const SizedBox(height: 8),
                    Text(
                      tuner.statusText,
                      style: AppTypography.bodyMedium.copyWith(
                        color: tuner.statusText == 'In tune'
                            ? AppColors.success
                            : tuner.status == TunerStatus.permissionDenied
                                ? AppColors.error
                                : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tuning meter
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        // Map cents (-50 to +50) to position (0 to width)
                        final cents = tuner.centsDeviation.clamp(-50.0, 50.0);
                        final needlePos =
                            (width / 2) + (cents / 50 * width / 2);

                        return SizedBox(
                          height: 24,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.error,
                                        AppColors.warning,
                                        AppColors.success,
                                        AppColors.warning,
                                        AppColors.error,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 150),
                                left: needlePos - 2,
                                top: -2,
                                child: Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.cream,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.cream
                                            .withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: tuner.status == TunerStatus.listening
                          ? 'Stop Listening'
                          : 'Start Listening',
                      onPressed: () =>
                          ref.read(tunerProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // METRONOME SECTION
              Text('METRONOME', style: AppTypography.label),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    Text(
                      '${metro.bpm}',
                      style: AppTypography.displayLarge,
                    ),
                    Text('BPM', style: AppTypography.bodySmall),
                    const SizedBox(height: 16),

                    // Beat indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: metro.beatFlash
                            ? AppColors.gold
                            : AppColors.surfaceElevated,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preset buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [60, 80, 100, 120].map((bpm) {
                        final isSelected = metro.bpm == bpm;
                        return GestureDetector(
                          onTap: () => ref
                              .read(metronomeProvider.notifier)
                              .setBpm(bpm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(color: AppColors.gold)
                                  : null,
                            ),
                            child: Text(
                              '$bpm',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Slider
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.gold,
                        inactiveTrackColor: AppColors.surfaceElevated,
                        thumbColor: AppColors.gold,
                        overlayColor: AppColors.gold.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: metro.bpm.toDouble(),
                        min: 40,
                        max: 200,
                        onChanged: (v) => ref
                            .read(metronomeProvider.notifier)
                            .setBpm(v.round()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GoldButton(
                      label: metro.isPlaying ? 'Stop' : 'Start',
                      onPressed: () =>
                          ref.read(metronomeProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // FINGERING CHART SECTION
              Text('FINGERING CHART', style: AppTypography.label),
              const SizedBox(height: 12),

              // Note selector
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: beginnerNotes.length,
                  itemBuilder: (context, i) {
                    final note = beginnerNotes[i];
                    final isSelected = _selectedNoteIndex == i;
                    final isLocked = note.isPremium;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: isLocked
                            ? null
                            : () => setState(() => _selectedNoteIndex = i),
                        child: Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold
                                : isLocked
                                    ? AppColors.surfaceElevated
                                        .withValues(alpha: 0.5)
                                    : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(color: AppColors.borderGold),
                          ),
                          child: Center(
                            child: isLocked
                                ? const Icon(Icons.lock_rounded,
                                    color: AppColors.textDisabled, size: 16)
                                : Text(
                                    note.name,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: isSelected
                                          ? const Color(0xFF1A0F00)
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Fingering diagram
              AppCard(
                child: Column(
                  children: [
                    Text(
                      beginnerNotes[_selectedNoteIndex].name,
                      style: AppTypography.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alto Saxophone',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 24),

                    // Two-column fingering chart (LH / RH)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HandColumn(
                            label: 'LEFT HAND',
                            keys: beginnerNotes[_selectedNoteIndex]
                                .keys
                                .sublist(0, 3),
                            fingerLabels: const ['1', '2', '3'],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 180,
                          color: AppColors.borderGold,
                        ),
                        Expanded(
                          child: _HandColumn(
                            label: 'RIGHT HAND',
                            keys: beginnerNotes[_selectedNoteIndex]
                                .keys
                                .sublist(3, 7),
                            fingerLabels: const ['1', '2', '3', '4'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              color: AppColors.gold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              beginnerNotes[_selectedNoteIndex].tip,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Play note button
                    GestureDetector(
                      onTap: () => _notePlayer.playNote(
                        beginnerNotes[_selectedNoteIndex].name,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up_rounded,
                                color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Play Note',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
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

/// Vertical column showing a hand's fingers stacked top-to-bottom,
/// with pressed keys filled gold and unpressed as hollow gold rings.
class _HandColumn extends StatelessWidget {
  final String label;
  final List<bool> keys;
  final List<String> fingerLabels;

  const _HandColumn({
    required this.label,
    required this.keys,
    required this.fingerLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 12),
        ...List.generate(keys.length, (i) {
          final pressed = keys[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pressed ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                      color: pressed
                          ? AppColors.gold
                          : AppColors.textDisabled,
                      width: 2,
                    ),
                    boxShadow: pressed
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fingerLabels[i],
                  style: AppTypography.bodySmall.copyWith(
                    color: pressed
                        ? AppColors.gold
                        : AppColors.textDisabled,
                    fontWeight:
                        pressed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
