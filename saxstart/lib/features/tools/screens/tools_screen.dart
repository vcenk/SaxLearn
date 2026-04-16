import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/local_content/fingering_chart_data.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  // Tuner state
  bool _tunerActive = false;
  String _detectedNote = '--';
  String _tunerStatus = 'Tap to start';

  // Metronome state
  int _bpm = 80;
  bool _metronomeActive = false;

  // Fingering state
  int _selectedNoteIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      _detectedNote,
                      style: AppTypography.displayLarge,
                    ),
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
                      '$_bpm',
                      style: AppTypography.displayLarge,
                    ),
                    Text('BPM', style: AppTypography.bodySmall),
                    const SizedBox(height: 16),

                    // Beat indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _metronomeActive
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
                        final isSelected = _bpm == bpm;
                        return GestureDetector(
                          onTap: () => setState(() => _bpm = bpm),
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
                        value: _bpm.toDouble(),
                        min: 40,
                        max: 200,
                        onChanged: (v) => setState(() => _bpm = v.round()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GoldButton(
                      label: _metronomeActive ? 'Stop' : 'Start',
                      onPressed: () {
                        setState(() => _metronomeActive = !_metronomeActive);
                      },
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedNoteIndex = i),
                        child: Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(color: AppColors.borderGold),
                          ),
                          child: Center(
                            child: Text(
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
