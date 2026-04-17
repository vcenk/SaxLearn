import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/outline_button.dart';
import '../../../core/utils/score_calculator.dart';

enum DrillPhase { ready, listening, scored }

class DrillScreen extends StatefulWidget {
  final String drillType;
  final String targetNote;

  const DrillScreen({
    super.key,
    required this.drillType,
    required this.targetNote,
  });

  @override
  State<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends State<DrillScreen>
    with SingleTickerProviderStateMixin {
  DrillPhase _phase = DrillPhase.ready;
  late AnimationController _pulseController;
  Timer? _listenTimer;

  // Score results
  int _overallScore = 0;
  int _pitchScore = 0;
  int _stabilityScore = 0;
  int _sustainScore = 0;
  int _attackScore = 0;
  String _feedback = '';

  int get _listenDuration {
    switch (widget.drillType) {
      case 'hold':
        return 4;
      case 'pattern':
        return 6;
      default:
        return 3;
    }
  }

  String get _drillTitle {
    switch (widget.drillType) {
      case 'hold':
        return 'HOLD IT STEADY';
      case 'pattern':
        return 'FOLLOW THE PATTERN';
      default:
        return 'TUNE THE NOTE';
    }
  }

  String get _noteName => widget.targetNote.replaceAll(RegExp(r'\d'), '');

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _listenTimer?.cancel();
    super.dispose();
  }

  void _startListening() {
    setState(() => _phase = DrillPhase.listening);

    _listenTimer = Timer(Duration(seconds: _listenDuration), () {
      _generateDemoScore();
      setState(() => _phase = DrillPhase.scored);
    });
  }

  void _generateDemoScore() {
    final rng = Random();
    _pitchScore = 60 + rng.nextInt(40);
    _stabilityScore = 50 + rng.nextInt(50);
    _sustainScore = 65 + rng.nextInt(35);
    _attackScore = 55 + rng.nextInt(45);
    _overallScore = ScoreCalculator.overallScore(
      pitch: _pitchScore,
      stability: _stabilityScore,
      sustain: _sustainScore,
      attack: _attackScore,
    );
    _feedback = ScoreCalculator.pitchFeedback(_pitchScore);
  }

  void _reset() {
    _listenTimer?.cancel();
    setState(() => _phase = DrillPhase.ready);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_drillTitle,
            style: AppTypography.label.copyWith(fontSize: 13)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: switch (_phase) {
            DrillPhase.ready => _buildReady(),
            DrillPhase.listening => _buildListening(),
            DrillPhase.scored => _buildScored(),
          },
        ),
      ),
    );
  }

  Widget _buildReady() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Text('Play this note', style: AppTypography.bodySmall),
        const SizedBox(height: 8),
        Text(
          _noteName,
          style: AppTypography.displayLarge.copyWith(fontSize: 96),
        ),
        const SizedBox(height: 16),
        Text(
          'Hold it steady for $_listenDuration seconds',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(flex: 3),
        GoldButton(
          label: 'Start Listening',
          onPressed: _startListening,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildListening() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + _pulseController.value * 0.15;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(
                      alpha: 0.3 + _pulseController.value * 0.4,
                    ),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: AppColors.gold,
                      size: 48,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Listening... play your note now!',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.goldLight,
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildScored() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Your Score', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Text(
            '$_overallScore',
            style: AppTypography.displayLarge.copyWith(fontSize: 80),
          ),
          const SizedBox(height: 32),

          // Score breakdown
          _ScoreBar(label: 'Pitch', score: _pitchScore),
          const SizedBox(height: 16),
          _ScoreBar(label: 'Stability', score: _stabilityScore),
          const SizedBox(height: 16),
          _ScoreBar(label: 'Sustain', score: _sustainScore),
          const SizedBox(height: 16),
          _ScoreBar(label: 'Attack', score: _attackScore),
          const SizedBox(height: 24),

          // Feedback
          AppCard(
            highlighted: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_feedback, style: AppTypography.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          GoldButton(label: 'Try Again', onPressed: _reset),
          const SizedBox(height: 12),
          AppOutlineButton(
            label: 'Done',
            onPressed: () => context.pop(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: score),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '$value',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: score / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      score >= 70 ? AppColors.gold : AppColors.warning,
                      score >= 70 ? AppColors.goldLight : AppColors.error,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
