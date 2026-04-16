import 'lesson_model.dart';

class ModuleModel {
  final String id;
  final int number;
  final String title;
  final String description;
  final List<LessonModel> lessons;
  final bool isPremium;

  const ModuleModel({
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
