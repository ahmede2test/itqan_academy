import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/functions/logout.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'package:shimmer/shimmer.dart';

import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/generated/l10n.dart';
import '../../../../courses/data/models/introduction_course_model.dart';

import '../../../../courses/presentation/manger/course_cubit/course_state.dart';

import 'package:itqan_academy/features/home/presentation/views/widgets/course_card.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_cubit.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_state.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<UserCourseModel> courses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        CourseCubit.get(context).getCoursesIntroduction();
        context.read<CourseProgressCubit>().fetchAllProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseCubit, CourseState>(
      listener: (context, state) {
        if (state is UserCoursesSuccessState) {
          courses = state.courses;
        } else if (state is UserCoursesErrorState) {
          customShowToast(msg: state.message);
          if (state.message.compareTo('Expired token') == 0) {
            logOut(context);
          }
        }
      },
      builder: (context, courseState) {
        // Initialize local courses list if state is already successful
        List<UserCourseModel> displayCourses = courses;
        if (courseState is UserCoursesSuccessState) {
          displayCourses = courseState.courses;
        }

        return BlocBuilder<CourseProgressCubit, CourseProgressState>(
          builder: (context, progressState) {
            return Scaffold(
              backgroundColor: const Color(0xFFFBF8EF), // Elegant Cream
              appBar: kIsWeb
                  ? null
                  : AppBar(
                      // Hide on web (handled by SaaSHeader)
                      title: Text(
                        S.of(context).educationalCourses,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Cairo'),
                      ),
                      centerTitle: true,
                      backgroundColor: AppColors.primary,
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
              body: courseState is UserCoursesLoadingState
                  ? _buildShimmerGrid()
                  : courseState is UserCoursesErrorState
                      ? Center(
                          child: Text(
                            courseState.message,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        )
                      : displayCourses.isEmpty
                          ? Center(
                              child: Text(
                                S.of(context).noAvailableCourses,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: kIsWeb
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 32)
                                  : const EdgeInsets.all(16),
                              gridDelegate: kIsWeb
                                  ? SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          MediaQuery.of(context).size.width >
                                                  1200
                                              ? 3
                                              : 2,
                                      childAspectRatio: 0.82,
                                      crossAxisSpacing: 32,
                                      mainAxisSpacing: 32,
                                    )
                                  : const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio:
                                          0.61, // 📐 Balanced for 320px fixed height
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                              itemCount: displayCourses.length,
                              itemBuilder: (context, index) {
                                return CourseCard(
                                    course: displayCourses[index]);
                              },
                            ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
