import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/introduction_course_model.dart';
import '../../../data/models/lessons_topic_model.dart';
import 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit() : super(CourseInitial());

  // تم حذف ApiService لأننا سنستخدم Supabase مباشرة
  static CourseCubit get(context) => BlocProvider.of(context);

  // 1. جلب قائمة الكورسات من Supabase
  Future<void> getCoursesIntroduction() async {
    // 1. Load from cache first
    final cachedData = CashHelper.getData('cached_courses');
    if (cachedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<UserCourseModel> cachedCourses =
            decoded.map((e) => UserCourseModel.fromJson(e)).toList();
        emit(UserCoursesSuccessState(cachedCourses));
      } catch (e) {
        debugPrint("CourseCubit: Cache decode error: $e");
      }
    } else {
      emit(UserCoursesLoadingState());
    }

    // 2. Fetch fresh data
    try {
      // 🚀 SQL Fix: Select 'title' and 'thumbnail' to match DB schema
      final response =
          await Supabase.instance.client.from('courses').select('*');

      final List<UserCourseModel> userCourses =
          (response as List).map((e) => UserCourseModel.fromJson(e)).toList();

      // Update cache
      CashHelper.setData('cached_courses', jsonEncode(response));

      emit(UserCoursesSuccessState(userCourses));
      debugPrint("CourseCubit: Fetched ${userCourses.length} fresh courses.");
    } catch (e) {
      if (state is! UserCoursesSuccessState) {
        if (e.toString().contains('handshake') ||
            e.toString().contains('SocketException')) {
          emit(UserCoursesErrorState(
              "تعذر تحميل البيانات، تأكد من اتصالك بالإنترنت."));
        } else {
          emit(UserCoursesErrorState(e.toString()));
        }
      }
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
