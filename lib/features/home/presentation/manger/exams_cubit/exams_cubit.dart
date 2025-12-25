import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repos/exams_repository.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  final ExamsRepository _examsRepository;
  StreamSubscription? _examsSubscription;
  Timer? _statusTimer;

  final Map<String, List<QuestionModel>> _cachedQuestions = {};

  ExamsCubit(this._examsRepository) : super(ExamsInitial());

  void getExams() {
    emit(ExamsLoading());
    _examsSubscription?.cancel();
    _examsSubscription = _examsRepository.getExamsStream().listen(
      (exams) {
        emit(ExamsLoaded(
          exams,
          DateTime.now(),
          Map.from(_cachedQuestions),
        ));
        _startStatusTimer();
      },
      onError: (error) {
        emit(ExamsError(error.toString()));
      },
    );
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state is ExamsLoaded) {
        final current = state as ExamsLoaded;
        emit(ExamsLoaded(
          current.exams,
          DateTime.now(),
          current.cachedQuestions ?? Map.from(_cachedQuestions),
        ));
      }
    });
  }

  Future<void> preCacheQuestions(String examId) async {
    // Ensure we preserve existing cache
    if (_cachedQuestions.containsKey(examId)) return;

    try {
      final questions = await _examsRepository.fetchQuestions(examId);
      _cachedQuestions[examId] = questions;

      if (state is ExamsLoaded) {
        final current = state as ExamsLoaded;
        emit(ExamsLoaded(
          current.exams,
          current.lastUpdated,
          Map.from(_cachedQuestions),
        ));
      }
    } catch (e) {
      debugPrint('Pre-caching failed for $examId: $e');
    }
  }

  Future<List<ExamResultModel>> fetchUserResults() {
    return _examsRepository.fetchUserExamResults();
  }

  @override
  Future<void> close() {
    _examsSubscription?.cancel();
    _statusTimer?.cancel();
    return super.close();
  }
}
