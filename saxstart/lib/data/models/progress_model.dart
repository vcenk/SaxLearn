class ProgressModel {
  final int totalPracticeMinutes;
  final int lessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;
  final List<String> completedLessonIds;
  final String currentLessonId;
  final List<int> modulesUnlocked;

  const ProgressModel({
    this.totalPracticeMinutes = 0,
    this.lessonsCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPracticeDate,
    this.completedLessonIds = const [],
    this.currentLessonId = 'm1_l1',
    this.modulesUnlocked = const [1],
  });

  bool isLessonComplete(String lessonId) =>
      completedLessonIds.contains(lessonId);

  bool isModuleUnlocked(int moduleNumber) =>
      modulesUnlocked.contains(moduleNumber);

  ProgressModel copyWith({
    int? totalPracticeMinutes,
    int? lessonsCompleted,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPracticeDate,
    List<String>? completedLessonIds,
    String? currentLessonId,
    List<int>? modulesUnlocked,
  }) {
    return ProgressModel(
      totalPracticeMinutes:
          totalPracticeMinutes ?? this.totalPracticeMinutes,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      currentLessonId: currentLessonId ?? this.currentLessonId,
      modulesUnlocked: modulesUnlocked ?? this.modulesUnlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPracticeMinutes': totalPracticeMinutes,
      'lessonsCompleted': lessonsCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      'completedLessonIds': completedLessonIds,
      'currentLessonId': currentLessonId,
      'modulesUnlocked': modulesUnlocked,
    };
  }

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      totalPracticeMinutes: map['totalPracticeMinutes'] as int? ?? 0,
      lessonsCompleted: map['lessonsCompleted'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastPracticeDate: map['lastPracticeDate'] != null
          ? DateTime.parse(map['lastPracticeDate'] as String)
          : null,
      completedLessonIds:
          List<String>.from(map['completedLessonIds'] as List? ?? []),
      currentLessonId: map['currentLessonId'] as String? ?? 'm1_l1',
      modulesUnlocked:
          List<int>.from(map['modulesUnlocked'] as List? ?? [1]),
    );
  }
}
