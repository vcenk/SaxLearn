import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/drill_result_model.dart';

class DrillState {
  final Map<String, int> bestScores; // drillType -> best overall score
  final List<DrillResultModel> recentResults;

  const DrillState({
    this.bestScores = const {},
    this.recentResults = const [],
  });

  DrillState copyWith({
    Map<String, int>? bestScores,
    List<DrillResultModel>? recentResults,
  }) {
    return DrillState(
      bestScores: bestScores ?? this.bestScores,
      recentResults: recentResults ?? this.recentResults,
    );
  }
}

class DrillNotifier extends StateNotifier<DrillState> {
  DrillNotifier() : super(const DrillState());

  void addResult(DrillResultModel result) {
    final updatedRecent = [result, ...state.recentResults].take(20).toList();
    final updatedBest = Map<String, int>.from(state.bestScores);

    final current = updatedBest[result.drillType] ?? 0;
    if (result.overallScore > current) {
      updatedBest[result.drillType] = result.overallScore;
    }

    state = state.copyWith(
      bestScores: updatedBest,
      recentResults: updatedRecent,
    );
  }

  int? getBestScore(String drillType) => state.bestScores[drillType];
}

final drillProvider = StateNotifierProvider<DrillNotifier, DrillState>(
  (ref) => DrillNotifier(),
);
