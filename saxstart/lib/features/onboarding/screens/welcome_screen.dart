import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/gold_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.music_note_rounded,
      title: 'Learn without feeling overwhelmed',
      subtitle: 'Step-by-step lessons designed for absolute beginners',
    ),
    _SlideData(
      icon: Icons.tune_rounded,
      title: 'Practice with beginner-friendly tools',
      subtitle: 'Built-in tuner, metronome, and fingering charts',
    ),
    _SlideData(
      icon: Icons.trending_up_rounded,
      title: 'Track your progress every single day',
      subtitle: 'Streaks, achievements, and detailed stats',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo area
              Icon(
                Icons.music_note_rounded,
                size: 64,
                color: AppColors.gold,
              ),
              const SizedBox(height: 12),
              Text('SaxStart', style: AppTypography.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Learn saxophone step by step',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 48),

              // Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 56,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: AppTypography.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => Container(
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.gold
                          : AppColors.textDisabled,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              GoldButton(
                label: 'Get Started',
                onPressed: () => context.go('/onboarding/level'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/auth'),
                child: Text(
                  'Sign In',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
