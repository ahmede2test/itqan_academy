class UserCourseModel {
  final int id;
  final String title;
  final String thumbnail;
  final int totalLessons;

  UserCourseModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.totalLessons = 0,
  });

  // المصنع ده بياخد البيانات الخام من سوبابيز ويحولها لكود فلاتر
  factory UserCourseModel.fromJson(Map<String, dynamic> json) {
    return UserCourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      totalLessons: json['lessons_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'lessons_count': totalLessons,
    };
  }
}
