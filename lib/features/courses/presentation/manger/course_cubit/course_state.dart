import '../../../data/models/introduction_course_model.dart';
import '../../../data/models/lessons_topic_model.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class UserCoursesLoadingState extends CourseState {}

class UserCoursesSuccessState extends CourseState {
  final List<UserCourseModel> courses;
  UserCoursesSuccessState(this.courses);
}

class UserCoursesErrorState extends CourseState {
  final String message;
  UserCoursesErrorState(this.message);
}

class CourseLessonsLoadingState extends CourseState {}

class CourseLessonsSuccessState extends CourseState {
  final LessonsTopicModel lessonsTopicModel;
  CourseLessonsSuccessState(this.lessonsTopicModel);
}

class CourseLessonsErrorState extends CourseState {
  final String message;
  CourseLessonsErrorState(this.message);
}
