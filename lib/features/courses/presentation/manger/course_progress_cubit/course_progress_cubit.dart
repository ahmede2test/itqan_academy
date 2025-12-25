import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'course_progress_state.dart';

class CourseProgressCubit extends Cubit<CourseProgressState> {
  CourseProgressCubit() : super(CourseProgressInitial());

  static CourseProgressCubit get(context) => BlocProvider.of(context);

  final Map<int, double> _progressMap = {}; // courseId -> percentage
  final Set<int> _completedLessons = {}; // set of lessonIds
  final Map<int, int> _completedCountPerCourse = {}; // courseId -> count

  static const String _storageKey = 'watched_lessons_ids';

  /// 🎯 Fetch all progress for the current user (Local + Remote)
  Future<void> fetchAllProgress() async {
    emit(CourseProgressLoading());

    // 1. Load from Local Storage first for immediate UI update
    _loadLocalProgress();
    emit(CourseProgressSuccess(
      progressData: Map.from(_progressMap),
      completedLessons: Set.from(_completedLessons),
    ));

    // 2. Load from Supabase to sync
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('user_lessons_progress')
          .select('lesson_id, course_id, is_completed')
          .eq('user_id', user.id)
          .eq('is_completed', true);

      final List<dynamic> data = response as List<dynamic>;

      // We don't clear local progress, we merge it
      for (var item in data) {
        final lessonId = item['lesson_id'] as int;
        final courseId = item['course_id'] as int;
        _completedLessons.add(lessonId);

        _completedCountPerCourse[courseId] =
            (_completedCountPerCourse[courseId] ?? 0) + 1;
      }

      _saveLocalProgress(); // Sync backup

      emit(CourseProgressSuccess(
        progressData: Map.from(_progressMap),
        completedLessons: Set.from(_completedLessons),
      ));
    } catch (e) {
      // If remote fails, we still have local data shown
      emit(CourseProgressError(e.toString()));
    }
  }

  /// 🎯 Fetch completed lessons and calculate progress percentage for a course
  Future<void> fetchCourseProgress(int courseId) async {
    // Ensure we have local data loaded
    if (_completedLessons.isEmpty) {
      _loadLocalProgress();
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Guest mode: just emit local progress
      emit(CourseProgressSuccess(
        progressData: Map.from(_progressMap),
        completedLessons: Set.from(_completedLessons),
      ));
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_lessons_progress')
          .select('lesson_id')
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .eq('is_completed', true);

      final List<dynamic> data = response as List<dynamic>;
      final List<int> completedIds =
          data.map((e) => e['lesson_id'] as int).toList();

      _completedLessons.addAll(completedIds);
      _saveLocalProgress();

      emit(CourseProgressSuccess(
        progressData: Map.from(_progressMap),
        completedLessons: Set.from(_completedLessons),
      ));
    } catch (e) {
      emit(CourseProgressError(e.toString()));
    }
  }

  /// 🎯 Mark a lesson as completed or uncompleted
  Future<void> markLessonAsCompleted({
    required int lessonId,
    required int courseId,
    required bool completed,
  }) async {
    try {
      // 1. Optimistic Update (UI + Local Storage)
      if (completed) {
        _completedLessons.add(lessonId);
      } else {
        _completedLessons.remove(lessonId);
      }

      _saveLocalProgress();

      emit(CourseProgressSuccess(
        progressData: Map.from(_progressMap),
        completedLessons: Set.from(_completedLessons),
      ));

      // 2. Remote Sync
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('user_lessons_progress').upsert({
          'user_id': user.id,
          'lesson_id': lessonId,
          'course_id': courseId,
          'is_completed': completed,
        });
      }

      emit(LessonProgressUpdateSuccess(lessonId, completed));
    } catch (e) {
      // Rollback on error
      if (completed) {
        _completedLessons.remove(lessonId);
      } else {
        _completedLessons.add(lessonId);
      }
      _saveLocalProgress();
      emit(CourseProgressError(e.toString()));
    }
  }

  void _loadLocalProgress() {
    final List<dynamic>? storedIds = CashHelper.getData(_storageKey);
    if (storedIds != null) {
      _completedLessons.addAll(storedIds.map((e) => int.parse(e.toString())));
    }
  }

  void _saveLocalProgress() {
    final List<String> idStrings =
        _completedLessons.map((id) => id.toString()).toList();
    CashHelper.setData(_storageKey, idStrings);
  }

  bool isLessonCompleted(int lessonId) {
    return _completedLessons.contains(lessonId);
  }

  double getCourseProgressPercentage(int courseId, int totalLessons) {
    if (totalLessons == 0) return 0.0;
    final completedCount = _completedCountPerCourse[courseId] ?? 0;
    return completedCount / totalLessons;
  }
}
