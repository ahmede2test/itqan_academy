import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/exam_result_model.dart';

abstract class ExamsRepository {
  Future<List<ExamModel>> fetchExams();
  Stream<List<ExamModel>> getExamsStream();
  Future<List<QuestionModel>> fetchQuestions(String examId);
  Future<void> submitExamResult(String examId, int score, int totalQuestions);
  Future<List<String>> getTakenExamIds();
  Future<List<ExamResultModel>> fetchUserExamResults();
}

class ExamsRepositoryImpl implements ExamsRepository {
  final SupabaseClient _supabaseClient;

  ExamsRepositoryImpl(this._supabaseClient);

  @override
  Future<List<ExamModel>> fetchExams() async {
    try {
      final response = await _supabaseClient
          .from('exams')
          .select()
          .order('date', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => ExamModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Msg: Failed to fetch exams: $e');
      return [];
    }
  }

  @override
  Stream<List<ExamModel>> getExamsStream() {
    return _supabaseClient
        .from('exams')
        .stream(primaryKey: ['id'])
        .order('date', ascending: true)
        .map((data) => data.map((json) => ExamModel.fromJson(json)).toList());
  }

  @override
  Future<List<QuestionModel>> fetchQuestions(String examId) async {
    try {
      final response = await _supabaseClient
          .from('questions')
          .select()
          .eq('exam_id', examId);

      final data = response as List<dynamic>;
      return data.map((json) => QuestionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Msg: Failed to fetch questions: $e');
      return [];
    }
  }

  @override
  Future<void> submitExamResult(
      String examId, int score, int totalQuestions) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        debugPrint('Msg: User not logged in, cannot submit result.');
        return;
      }

      debugPrint(
          'Msg: Attempting to insert Result: Exam=$examId, Score=$score');

      await _supabaseClient.from('exam_results').insert({
        'exam_id': examId,
        'user_id': user.id,
        'score': score,
        'total_questions': totalQuestions,
      });

      debugPrint('Msg: Result Inserted Successfully');
    } catch (e) {
      debugPrint('Msg: Result Submission Error: $e');
      rethrow; // Allow UI to handle specific error messaging if needed
    }
  }

  @override
  Future<List<String>> getTakenExamIds() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await _supabaseClient
          .from('exam_results')
          .select('exam_id')
          .eq('user_id', user.id);

      final data = response as List<dynamic>;
      return data.map((json) => json['exam_id'] as String).toList();
    } catch (e) {
      debugPrint('Msg: Error fetching taken exams: $e');
      return [];
    }
  }

  @override
  Future<List<ExamResultModel>> fetchUserExamResults() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return [];

      debugPrint('Msg: Fetching results for user: ${user.id}');

      final response = await _supabaseClient
          .from('exam_results')
          .select()
          .eq('user_id', user.id);

      final data = response as List<dynamic>;
      return data.map((json) => ExamResultModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Msg: Error fetching user results: $e');
      return [];
    }
  }
}
