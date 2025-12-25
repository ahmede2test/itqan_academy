import 'package:equatable/equatable.dart';

abstract class CourseProgressState extends Equatable {
  const CourseProgressState();

  @override
  List<Object?> get props => [];
}

class CourseProgressInitial extends CourseProgressState {}

class CourseProgressLoading extends CourseProgressState {}

class CourseProgressSuccess extends CourseProgressState {
  final Map<int, double> progressData; // courseId -> percentage
  final Set<int> completedLessons; // Set of lessonIds

  const CourseProgressSuccess({
    required this.progressData,
    required this.completedLessons,
  });

  @override
  List<Object?> get props => [progressData, completedLessons];
}

class CourseProgressError extends CourseProgressState {
  final String message;

  const CourseProgressError(this.message);

  @override
  List<Object?> get props => [message];
}

class LessonProgressUpdateSuccess extends CourseProgressState {
  final int lessonId;
  final bool isCompleted;

  const LessonProgressUpdateSuccess(this.lessonId, this.isCompleted);

  @override
  List<Object?> get props => [lessonId, isCompleted];
}
