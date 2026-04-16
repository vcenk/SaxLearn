import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/progress_model.dart';

class ProgressNotifier extends StateNotifier<ProgressModel> {
  ProgressNotifier() : super(const ProgressModel());

  void completeLesson(String lessonId) {
    if (state.completedLessonIds.contains(lessonId)) return;

    final updatedIds = [...state.completedLessonIds, lessonId];
    final nextLessonId = _getNextLessonId(lessonId);
    final modulesUnlocked = _calculateUnlockedModules(updatedIds);

    state = state.copyWith(
      completedLessonIds: updatedIds,
      lessonsCompleted: updatedIds.length,
      currentLessonId: nextLessonId,
      modulesUnlocked: modulesUnlocked,
      lastPracticeDate: DateTime.now(),
    );
  }

  void addPracticeMinutes(int minutes) {
    state = state.copyWith(
      totalPracticeMinutes: state.totalPracticeMinutes + minutes,
      lastPracticeDate: DateTime.now(),
    );
  }

  void updateStreak(int streak) {
    state = state.copyWith(
      currentStreak: streak,
      longestStreak:
          streak > state.longestStreak ? streak : state.longestStreak,
    );
  }

  String _getNextLessonId(String currentId) {
    const order = [
      'm1_l1', 'm1_l2', 'm1_l3', 'm1_l4',
      'm2_l1', 'm2_l2', 'm2_l3', 'm2_l4', 'm2_l5',
      'm3_l1', 'm3_l2', 'm3_l3', 'm3_l4',
      'm4_l1', 'm4_l2', 'm4_l3', 'm4_l4',
    ];
    final idx = order.indexOf(currentId);
    if (idx < 0 || idx >= order.length - 1) return currentId;
    return order[idx + 1];
  }

  List<int> _calculateUnlockedModules(List<String> completedIds) {
    final unlocked = <int>[1];
    // Module 2 unlocks when all of module 1 is done
    if (['m1_l1', 'm1_l2', 'm1_l3', 'm1_l4']
        .every(completedIds.contains)) {
      unlocked.add(2);
    }
    // Module 3 unlocks when all of module 2 is done
    if (['m2_l1', 'm2_l2', 'm2_l3', 'm2_l4', 'm2_l5']
        .every(completedIds.contains)) {
      unlocked.add(3);
    }
    // Module 4 unlocks when all of module 3 is done
    if (['m3_l1', 'm3_l2', 'm3_l3', 'm3_l4']
        .every(completedIds.contains)) {
      unlocked.add(4);
    }
    return unlocked;
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressModel>(
  (ref) => ProgressNotifier(),
);
