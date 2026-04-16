# SaxStart — Database Schema

## Overview

| Storage | What It Holds |
|---------|--------------|
| Firestore | User profiles, progress, drill scores, sessions |
| Hive (local) | Lesson content cache, offline data |
| Assets (bundled) | Lesson content JSON, audio files, fingering images |

---

## Firestore Collections

### `users/{userId}`

```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "level": "beginner | returning",
  "goal": "first_notes | improve_tone | daily_practice",
  "instrument": "alto",
  "isPremium": false,
  "reminderTime": "18:00",
  "createdAt": "timestamp",
  "lastActiveAt": "timestamp"
}
```

---

### `users/{userId}/progress/summary`

```json
{
  "totalPracticeMinutes": 47,
  "lessonsCompleted": 5,
  "currentStreak": 5,
  "longestStreak": 7,
  "lastPracticeDate": "2024-01-15",
  "streakDates": ["2024-01-11", "2024-01-12", "2024-01-13", "2024-01-14", "2024-01-15"],
  "completedLessonIds": ["m1_l1", "m1_l2", "m1_l3", "m1_l4", "m2_l1"],
  "currentLessonId": "m2_l2",
  "modulesUnlocked": [1, 2]
}
```

---

### `users/{userId}/sessions/{sessionId}`

```json
{
  "id": "string",
  "date": "timestamp",
  "durationMinutes": 12,
  "lessonsViewed": ["m2_l2"],
  "drillsCompleted": [
    {
      "drillType": "tune",
      "targetNote": "B",
      "overallScore": 82,
      "pitchScore": 84,
      "stabilityScore": 72,
      "sustainScore": 88,
      "attackScore": 76
    }
  ],
  "toolsUsed": ["tuner", "metronome"]
}
```

---

### `users/{userId}/drill_scores/{drillId}`

```json
{
  "drillType": "tune | hold | pattern",
  "targetNote": "B",
  "attemptedAt": "timestamp",
  "overallScore": 82,
  "pitchScore": 84,
  "stabilityScore": 72,
  "sustainScore": 88,
  "attackScore": 76,
  "feedback": "Slightly flat. Try relaxing your jaw."
}
```

---

## Local Data Models (Dart)

### `lib/data/models/user_model.dart`

```dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String email;
  @HiveField(3) final String level;
  @HiveField(4) final String goal;
  @HiveField(5) final bool isPremium;
  @HiveField(6) final String reminderTime;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.goal,
    required this.isPremium,
    required this.reminderTime,
  });
}
```

---

### `lib/data/models/lesson_model.dart`

```dart
class LessonModel {
  final String id;           // e.g. "m2_l2"
  final String moduleId;     // e.g. "module_2"
  final int moduleNumber;
  final int lessonNumber;
  final String title;
  final int durationMinutes;
  final String difficulty;   // "beginner" | "intermediate"
  final String objective;
  final List<String> steps;
  final String? noteReference; // e.g. "B" for fingering chart
  final String tip;
  final bool isPremium;

  LessonModel({
    required this.id,
    required this.moduleId,
    required this.moduleNumber,
    required this.lessonNumber,
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.objective,
    required this.steps,
    this.noteReference,
    required this.tip,
    required this.isPremium,
  });
}
```

---

### `lib/data/models/module_model.dart`

```dart
class ModuleModel {
  final String id;
  final int number;
  final String title;
  final String description;
  final List<LessonModel> lessons;
  final bool isPremium;

  ModuleModel({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.lessons,
    required this.isPremium,
  });

  int get totalLessons => lessons.length;
  
  double completionPercent(List<String> completedIds) {
    final done = lessons.where((l) => completedIds.contains(l.id)).length;
    return done / totalLessons;
  }
}
```

---

### `lib/data/models/drill_result_model.dart`

```dart
class DrillResultModel {
  final String drillType;     // "tune" | "hold" | "pattern"
  final String targetNote;    // "B" | "A" | "G" | "B→A→G"
  final int overallScore;
  final int pitchScore;
  final int stabilityScore;
  final int sustainScore;
  final int attackScore;
  final String feedback;
  final DateTime attemptedAt;

  DrillResultModel({
    required this.drillType,
    required this.targetNote,
    required this.overallScore,
    required this.pitchScore,
    required this.stabilityScore,
    required this.sustainScore,
    required this.attackScore,
    required this.feedback,
    required this.attemptedAt,
  });
}
```

---

### `lib/data/models/progress_model.dart`

```dart
class ProgressModel {
  final int totalPracticeMinutes;
  final int lessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;
  final List<String> completedLessonIds;
  final String currentLessonId;
  final List<int> modulesUnlocked;

  ProgressModel({
    required this.totalPracticeMinutes,
    required this.lessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    this.lastPracticeDate,
    required this.completedLessonIds,
    required this.currentLessonId,
    required this.modulesUnlocked,
  });

  bool isLessonComplete(String lessonId) => completedLessonIds.contains(lessonId);
  bool isModuleUnlocked(int moduleNumber) => modulesUnlocked.contains(moduleNumber);
}
```

---

## Fingering Chart Data

### `lib/data/local_content/fingering_chart_data.dart`

```dart
class FingeringNote {
  final String name;
  final String octave;       // "4" for middle octave
  final List<bool> keys;     // true = pressed, 7 keys indexed
  final String tip;
  final String audioAsset;   // "assets/audio/notes/note_b4.mp3"
  final bool isPremium;

  FingeringNote({
    required this.name,
    required this.octave,
    required this.keys,
    required this.tip,
    required this.audioAsset,
    required this.isPremium,
  });
}

final List<FingeringNote> beginnerNotes = [
  FingeringNote(
    name: 'B', octave: '4',
    keys: [true, false, false, false, false, false, false],
    tip: 'Press only the top left key. Keep other fingers raised.',
    audioAsset: 'assets/audio/notes/note_b4.mp3',
    isPremium: false,
  ),
  FingeringNote(
    name: 'A', octave: '4',
    keys: [true, true, false, false, false, false, false],
    tip: 'Add your second finger. Note A is lower than B.',
    audioAsset: 'assets/audio/notes/note_a4.mp3',
    isPremium: false,
  ),
  FingeringNote(
    name: 'G', octave: '4',
    keys: [true, true, true, false, false, false, false],
    tip: 'Three fingers down. Slow steady air gives the best G.',
    audioAsset: 'assets/audio/notes/note_g4.mp3',
    isPremium: false,
  ),
  FingeringNote(
    name: 'C', octave: '4',
    keys: [false, true, true, false, true, false, false],
    tip: 'C requires a jump in fingering. Practice slowly.',
    audioAsset: 'assets/audio/notes/note_c4.mp3',
    isPremium: true,
  ),
  FingeringNote(
    name: 'D', octave: '4',
    keys: [false, false, false, false, false, false, false],
    tip: 'D is an open note — no keys pressed.',
    audioAsset: 'assets/audio/notes/note_d4.mp3',
    isPremium: true,
  ),
];
```

---

## Scoring Algorithm

### `lib/core/utils/score_calculator.dart`

```dart
class ScoreCalculator {
  /// Target frequency in Hz for a given note
  static const Map<String, double> noteFrequencies = {
    'B4': 493.88,
    'A4': 440.00,
    'G4': 392.00,
    'C4': 261.63,
    'D4': 293.66,
  };

  /// Calculate pitch score from detected Hz and target note name
  static int pitchScore(double detectedHz, String targetNote) {
    final target = noteFrequencies[targetNote] ?? 440;
    final cents = 1200 * (log(detectedHz / target) / log(2));
    final absCents = cents.abs();
    if (absCents <= 5) return 100;
    if (absCents >= 50) return 0;
    return 100 - ((absCents - 5) / 45 * 100).round();
  }

  /// Calculate stability from a list of cents deviations over time
  static int stabilityScore(List<double> centsOverTime) {
    if (centsOverTime.isEmpty) return 0;
    final variance = _variance(centsOverTime);
    if (variance <= 2) return 100;
    if (variance >= 30) return 0;
    return 100 - ((variance - 2) / 28 * 100).round();
  }

  /// Calculate sustain score from held duration vs target
  static int sustainScore(double heldSeconds, double targetSeconds) {
    if (heldSeconds >= targetSeconds) return 100;
    return ((heldSeconds / targetSeconds) * 100).round().clamp(0, 100);
  }

  /// Calculate attack score — how quickly pitch locked in
  static int attackScore(double secondsToLock) {
    if (secondsToLock <= 0.2) return 100;
    if (secondsToLock >= 1.5) return 0;
    return 100 - ((secondsToLock - 0.2) / 1.3 * 100).round();
  }

  /// Weighted overall score
  static int overallScore({
    required int pitch,
    required int stability,
    required int sustain,
    required int attack,
  }) {
    return ((pitch * 0.4) + (stability * 0.3) + (sustain * 0.2) + (attack * 0.1)).round();
  }

  static double _variance(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
  }
}
```

---

## Streak Logic

```dart
class StreakCalculator {
  static int calculateStreak(List<DateTime> practiceDates) {
    if (practiceDates.isEmpty) return 0;
    
    final sorted = practiceDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
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
}
```
