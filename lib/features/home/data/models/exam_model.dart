class ExamModel {
  final String id;
  final String subjectEn;
  final String subjectAr;
  final String date;
  final String time;
  final String venueEn;
  final String venueAr;
  final int duration;
  final DateTime createdAt;

  ExamModel({
    required this.id,
    required this.subjectEn,
    required this.subjectAr,
    required this.date,
    required this.time,
    required this.venueEn,
    required this.venueAr,
    required this.duration,
    required this.createdAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? '',
      subjectEn: json['title_en'] as String? ?? 'No Title',
      subjectAr: json['title_ar'] as String? ?? 'بدون عنوان',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      venueEn: json['venue_en'] as String? ?? '',
      venueAr: json['venue_ar'] as String? ?? '',
      duration: (json['duration'] is int)
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 30, // Robust parsing
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_en': subjectEn,
      'title_ar': subjectAr,
      'date': date,
      'time': time,
      'venue_en': venueEn,
      'venue_ar': venueAr,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
