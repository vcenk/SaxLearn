import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local_content/modules.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/models/module_model.dart';

final modulesProvider = Provider<List<ModuleModel>>((ref) => allModules);

final lessonByIdProvider =
    Provider.family<LessonModel?, String>((ref, lessonId) {
  for (final module in allModules) {
    for (final lesson in module.lessons) {
      if (lesson.id == lessonId) return lesson;
    }
  }
  return null;
});
