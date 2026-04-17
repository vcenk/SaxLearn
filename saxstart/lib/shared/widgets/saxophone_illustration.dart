import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Real saxophone photo centered on a soft gold radial glow.
///
/// Usage:
/// ```dart
/// const SaxophoneIllustration(size: 180)
/// ```
class SaxophoneIllustration extends StatelessWidget {
  final double size;
  final bool showGlow;

  const SaxophoneIllustration({
    super.key,
    this.size = 160,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.28),
                    AppColors.gold.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Image.asset(
              'assets/images/saxophone.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
