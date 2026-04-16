class DrillResultModel {
  final String drillType;
  final String targetNote;
  final int overallScore;
  final int pitchScore;
  final int stabilityScore;
  final int sustainScore;
  final int attackScore;
  final String feedback;
  final DateTime attemptedAt;

  const DrillResultModel({
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

  Map<String, dynamic> toMap() {
    return {
      'drillType': drillType,
      'targetNote': targetNote,
      'overallScore': overallScore,
      'pitchScore': pitchScore,
      'stabilityScore': stabilityScore,
      'sustainScore': sustainScore,
      'attackScore': attackScore,
      'feedback': feedback,
      'attemptedAt': attemptedAt.toIso8601String(),
    };
  }

  factory DrillResultModel.fromMap(Map<String, dynamic> map) {
    return DrillResultModel(
      drillType: map['drillType'] as String,
      targetNote: map['targetNote'] as String,
      overallScore: map['overallScore'] as int,
      pitchScore: map['pitchScore'] as int,
      stabilityScore: map['stabilityScore'] as int,
      sustainScore: map['sustainScore'] as int,
      attackScore: map['attackScore'] as int,
      feedback: map['feedback'] as String,
      attemptedAt: DateTime.parse(map['attemptedAt'] as String),
    );
  }
}
