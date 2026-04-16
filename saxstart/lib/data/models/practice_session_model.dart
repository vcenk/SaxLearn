import 'drill_result_model.dart';

class PracticeSessionModel {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final List<String> lessonsViewed;
  final List<DrillResultModel> drillsCompleted;
  final List<String> toolsUsed;

  const PracticeSessionModel({
    required this.id,
    required this.date,
    required this.durationMinutes,
    this.lessonsViewed = const [],
    this.drillsCompleted = const [],
    this.toolsUsed = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'lessonsViewed': lessonsViewed,
      'drillsCompleted': drillsCompleted.map((d) => d.toMap()).toList(),
      'toolsUsed': toolsUsed,
    };
  }
}
