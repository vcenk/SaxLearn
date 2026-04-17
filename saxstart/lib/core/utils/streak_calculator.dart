class StreakCalculator {
  static int calculateStreak(List<DateTime> practiceDates) {
    if (practiceDates.isEmpty) return 0;

    final sorted = practiceDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (sorted.first != todayDate && sorted.first != yesterday) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final expected = sorted[i - 1].subtract(const Duration(days: 1));
      if (sorted[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static bool isStreakAtRisk(List<DateTime> practiceDates) {
    if (practiceDates.isEmpty) return false;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    final practicedToday = practiceDates.any((d) =>
        DateTime(d.year, d.month, d.day) == todayDate);

    // Streak at risk if it's past 8 PM and haven't practiced today
    return !practicedToday && now.hour >= 20;
  }
}
