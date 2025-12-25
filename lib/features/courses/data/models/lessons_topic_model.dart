class LessonsTopicModel {
  final List<LessonData>? data;

  LessonsTopicModel({this.data});

  // دالة مريحة لتحويل القائمة اللي جاية من سوبابيز لموديل كامل
  factory LessonsTopicModel.fromJsonList(List<dynamic> jsonList) {
    return LessonsTopicModel(
      data: jsonList.map((e) => LessonData.fromJson(e)).toList(),
    );
  }
}

class LessonData {
  final int id;
  final String postTitle;
  final String videoUrl;
  final String? pdfUrl;

  LessonData({
    required this.id,
    required this.postTitle,
    required this.videoUrl,
    this.pdfUrl,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    return LessonData(
      id: json['id'] ?? 0,
      postTitle: json['title'] ?? '', // بنقرأ عمود title من الجدول
      videoUrl: json['video_url'] ?? '', // بنقرأ عمود video_url
      pdfUrl: json['pdf_url'],
    );
  }
}
