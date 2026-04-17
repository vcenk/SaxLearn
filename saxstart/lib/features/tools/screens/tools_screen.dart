import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/local_content/fingering_chart_data.dart';
import '../../../core/services/note_player_service.dart';
import '../metronome/metronome_provider.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  // Tuner state (local until pitch_detector integration)
  bool _tunerActive = false;
  String _detectedNote = '--';
  String _tunerStatus = 'Tap to start';

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
                    Text(_detectedNote, style: AppTypography.displayLarge),
                    const SizedBox(height: 8),
                    Text(
                      _tunerStatus,
                      style: AppTypography.bodyMedium.copyWith(
                        color: _tunerStatus == 'In tune'
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tuning meter
                    Container(
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
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: _tunerActive ? 'Stop Listening' : 'Start Listening',
                      onPressed: () {
                        setState(() {
                          _tunerActive = !_tunerActive;
                          if (!_tunerActive) {
                            _detectedNote = '--';
                            _tunerStatus = 'Tap to start';
                          } else {
                            _tunerStatus = 'Listening...';
                          }
                        });
                      },
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
                    const SizedBox(height: 20),
                    // Key diagram
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left hand keys (0-2)
                        ...List.generate(3, (i) {
                          final pressed =
                              beginnerNotes[_selectedNoteIndex].keys[i];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 36,
                              height: 36,
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
                        const SizedBox(width: 16),
                        // Right hand keys (3-6)
                        ...List.generate(4, (i) {
                          final pressed =
                              beginnerNotes[_selectedNoteIndex].keys[i + 3];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 36,
                              height: 36,
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('L', style: AppTypography.caption),
                        const SizedBox(width: 100),
                        Text('R', style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      beginnerNotes[_selectedNoteIndex].tip,
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
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
