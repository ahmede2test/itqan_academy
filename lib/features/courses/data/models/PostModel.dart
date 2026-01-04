class PostModel {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String? featuredImage;
  final String category;
  final String author;

  PostModel({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.featuredImage,
    required this.category,
    required this.author,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),
      // تحويل التاريخ من Supabase (ISO 8601) إلى DateTime
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      title: json['title'] ?? 'عنوان غير متوفر',
      content: json['content'] ?? '',
      featuredImage: json['image_url'] as String?,
      // جعل القسم والكاتب يعتمدان على البيانات القادمة من السكرابر
      category: json['category'] ?? "تطوير وبرمجة",
      author: json['author'] ?? "مصدر تقني",
    );
  }

  // دالة تنسيق الوقت الذكية بالعربية
  String get formattedDate {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return "منذ ${difference.inDays} يوم";
    } else if (difference.inHours > 0) {
      return "منذ ${difference.inHours} ساعة";
    } else if (difference.inMinutes > 0) {
      return "منذ ${difference.inMinutes} دقيقة";
    } else {
      return "الآن";
    }
  }
}
