import 'package:equatable/equatable.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/question_model.dart';

abstract class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

class ExamsInitial extends ExamsState {}

class ExamsLoading extends ExamsState {}

class ExamsLoaded extends ExamsState {
  final List<ExamModel> exams;
  final DateTime lastUpdated;
  final Map<String, List<QuestionModel>>? cachedQuestions;

  const ExamsLoaded(
    this.exams,
    this.lastUpdated, [
    this.cachedQuestions,
  ]);

  @override
  List<Object?> get props => [exams, lastUpdated, cachedQuestions];
}

class ExamsError extends ExamsState {
  final String message;

  const ExamsError(this.message);

  @override
  List<Object?> get props => [message];
}
