class CourseProgressModel {
  final int lessonId;
  final String userId;
  final int courseId;
  final bool isCompleted;
  final int? totalLessons;

  CourseProgressModel({
    required this.lessonId,
    required this.userId,
    required this.courseId,
    required this.isCompleted,
    this.totalLessons,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      lessonId: json['lesson_id'] ?? 0,
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'user_id': userId,
      'course_id': courseId,
      'is_completed': isCompleted,
    };
  }
}
