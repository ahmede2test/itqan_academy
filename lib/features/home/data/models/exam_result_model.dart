class ExamResultModel {
  final String id;
  final String examId;
  final String userId;
  final int score;
  final int totalQuestions;
  final double earnedPoints;
  final String gradeLetter;
  final DateTime createdAt;

  ExamResultModel({
    required this.id,
    required this.examId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.earnedPoints,
    required this.gradeLetter,
    required this.createdAt,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      id: json['id'] as String? ?? '',
      examId: json['exam_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      earnedPoints: (json['earned_points'] as num?)?.toDouble() ?? 0.0,
      gradeLetter: json['grade_letter'] as String? ?? 'N/A',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
      'earned_points': earnedPoints,
      'grade_letter': gradeLetter,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
