import 'dart:math';

class ScoreCalculator {
  static const Map<String, double> noteFrequencies = {
    'B4': 493.88,
    'A4': 440.00,
    'G4': 392.00,
    'C4': 261.63,
    'D4': 293.66,
  };

  static int pitchScore(double detectedHz, String targetNote) {
    final target = noteFrequencies[targetNote] ?? 440;
    final cents = 1200 * (log(detectedHz / target) / log(2));
    final absCents = cents.abs();
    if (absCents <= 5) return 100;
    if (absCents >= 50) return 0;
    return 100 - ((absCents - 5) / 45 * 100).round();
  }

  static int stabilityScore(List<double> centsOverTime) {
    if (centsOverTime.isEmpty) return 0;
    final variance = _variance(centsOverTime);
    if (variance <= 2) return 100;
    if (variance >= 30) return 0;
    return 100 - ((variance - 2) / 28 * 100).round();
  }

  static int sustainScore(double heldSeconds, double targetSeconds) {
    if (heldSeconds >= targetSeconds) return 100;
    return ((heldSeconds / targetSeconds) * 100).round().clamp(0, 100);
  }

  static int attackScore(double secondsToLock) {
    if (secondsToLock <= 0.2) return 100;
    if (secondsToLock >= 1.5) return 0;
    return 100 - ((secondsToLock - 0.2) / 1.3 * 100).round();
  }

  static int overallScore({
    required int pitch,
    required int stability,
    required int sustain,
    required int attack,
  }) {
    return ((pitch * 0.4) +
            (stability * 0.3) +
            (sustain * 0.2) +
            (attack * 0.1))
        .round();
  }

  static double _variance(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        values.length;
  }

  static String pitchFeedback(int score) {
    if (score >= 90) return 'Excellent pitch! Right on target.';
    if (score >= 75) return 'Good pitch. Just slightly off center.';
    if (score >= 55) return 'Slightly flat. Try relaxing your jaw slightly.';
    if (score >= 40) return 'Noticeably sharp. Try releasing jaw pressure.';
    return 'Pitch needs work. Check your embouchure and air speed.';
  }

  static String stabilityFeedback(int score) {
    if (score >= 90) return 'Rock steady! Great air control.';
    if (score >= 70) return 'Good stability. A little wobble at the end.';
    if (score >= 50) {
      return 'Note drifted. Try keeping belly support throughout.';
    }
    return 'Lot of wobble. Focus on slow, even air pressure.';
  }

  static String sustainFeedback(int score) {
    if (score >= 90) return 'Great sustain! You held the full note.';
    if (score >= 70) return 'Good. Try to push through to the end.';
    return 'Cut off too early. Keep air moving until time is up.';
  }
}
