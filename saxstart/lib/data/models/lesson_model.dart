class LessonModel {
  final String id;
  final String moduleId;
  final int moduleNumber;
  final int lessonNumber;
  final String title;
  final int durationMinutes;
  final String difficulty;
  final String objective;
  final List<String> steps;
  final String? noteReference;
  final String tip;
  final bool isPremium;

  const LessonModel({
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
