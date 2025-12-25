import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/introduction_course_model.dart';
import '../models/lessons_topic_model.dart';

abstract class CoursesRepository {
  Future<List<UserCourseModel>> fetchCourses();
  Stream<List<UserCourseModel>> getCoursesStream();
  Future<List<LessonData>> fetchLessons(String courseId);
}

class CoursesRepositoryImpl implements CoursesRepository {
  final SupabaseClient _supabaseClient;

  CoursesRepositoryImpl(this._supabaseClient);

  @override
  Future<List<UserCourseModel>> fetchCourses() async {
    final response = await _supabaseClient.from('courses').select();
    return (response as List).map((e) => UserCourseModel.fromJson(e)).toList();
  }

  @override
  Stream<List<UserCourseModel>> getCoursesStream() {
    return _supabaseClient.from('courses').stream(primaryKey: ['id']).map(
        (data) => data.map((json) => UserCourseModel.fromJson(json)).toList());
  }

  @override
  Future<List<LessonData>> fetchLessons(String courseId) async {
    final response = await _supabaseClient
        .from('lessons')
        .select('id, title, video_url, pdf_url')
        .eq('course_id', courseId)
        .order('order_index', ascending: true);

    return (response as List).map((e) => LessonData.fromJson(e)).toList();
  }
}
