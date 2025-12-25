class UserTask {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  UserTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  factory UserTask.fromJson(Map<String, dynamic> json) {
    return UserTask(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}

class UserNote {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;

  UserNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
    };
  }
}

class StudySession {
  final String id;
  final String userId;
  final int durationMinutes;
  final DateTime completedAt;

  StudySession({
    required this.id,
    required this.userId,
    required this.durationMinutes,
    required this.completedAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      durationMinutes: json['duration'] as int? ?? 25,
      completedAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'duration': durationMinutes,
    };
  }
}
