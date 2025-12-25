class QuestionModel {
  final String id;
  final String examId;
  final String questionEn;
  final String questionAr;
  final List<String> options;
  final String correctAnswer;
  final int correctOptionIndex;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.examId,
    required this.questionEn,
    required this.questionAr,
    required this.options,
    required this.correctAnswer,
    required this.correctOptionIndex,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionEn: json['question_text_en'] as String? ?? '',
      questionAr: json['question_text_ar'] as String? ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'].toString(),
      correctOptionIndex: json['correct_option_index'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'question_text_en': questionEn,
      'question_text_ar': questionAr,
      'options': options,
      'correct_answer': correctAnswer,
      'correct_option_index': correctOptionIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
