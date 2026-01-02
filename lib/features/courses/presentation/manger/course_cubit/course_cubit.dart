import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repos/courses_repository.dart';
import '../../../data/models/lessons_topic_model.dart';
import 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  final CoursesRepository _coursesRepository;

  CourseCubit(this._coursesRepository) : super(CourseInitial());

  static CourseCubit get(context) => BlocProvider.of(context);

  // 1. جلب قائمة الكورسات من Supabase
  Future<void> getCoursesIntroduction() async {
    emit(UserCoursesLoadingState());
    try {
      final courses = await _coursesRepository.fetchCourses();
      emit(UserCoursesSuccessState(courses));
      debugPrint("CourseCubit: Fetched ${courses.length} courses.");
    } catch (e) {
      emit(UserCoursesErrorState(e.toString()));
      debugPrint("CourseCubit: Fetch error: $e");
    }
  }

  // 2. جلب دروس كورس معين من Supabase
  Future<void> getCoursesLessons({
    required String courseContentsId,
  }) async {
    emit(CourseLessonsLoadingState());
    try {
      // 🚀 Optimization: Select only required columns
      final response = await Supabase.instance.client
          .from('lessons')
          .select('id, title, video_url, pdf_url')
          .eq('course_id', courseContentsId)
          .order('order_index', ascending: true)
          .timeout(const Duration(seconds: 15));

      final lessonsTopicModel =
          LessonsTopicModel.fromJsonList(response as List);

      emit(CourseLessonsSuccessState(lessonsTopicModel));
    } catch (e) {
      if (e.toString().contains('handshake') ||
          e.toString().contains('Timeout') ||
          e.toString().contains('SocketException')) {
        emit(CourseLessonsErrorState(
            "تعذر تحميل البيانات، تأكد من اتصالك بالإنترنت."));
      } else {
        emit(CourseLessonsErrorState(e.toString()));
      }
    }
  }
}
