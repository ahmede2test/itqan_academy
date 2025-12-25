import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/functions/logout.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/generated/l10n.dart';
import '../../../../courses/data/models/introduction_course_model.dart';

import '../../../../courses/presentation/manger/course_cubit/course_state.dart';
import '../../../../courses/presentation/views/widgets/CourseDetailScreen.dart';
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
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: Text(
                  S.of(context).educationalCourses,
                  style:
                      const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
                centerTitle: true,
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.black),
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
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: kIsWeb
                                  ? const EdgeInsets.all(
                                      40) // 🌟 Web: More breathing room
                                  : const EdgeInsets.all(
                                      16), // 📱 Mobile: Standard padding
                              gridDelegate: kIsWeb
                                  ? const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          350, // 🌟 Web: Adaptive sizing
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing:
                                          24, // 🌟 Web: Increased spacing
                                      mainAxisSpacing: 24,
                                    )
                                  : const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2, // 📱 Mobile: Fixed 2 columns
                                      childAspectRatio: 0.7,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                              itemCount: displayCourses.length,
                              itemBuilder: (context, index) {
                                final course = displayCourses[index];

                                double progress = 0.0;
                                if (progressState is CourseProgressSuccess) {
                                  progress = context
                                      .read<CourseProgressCubit>()
                                      .getCourseProgressPercentage(
                                          course.id, course.totalLessons);
                                }

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CourseDetailScreen(course: course),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                            0.1), // 🌟 Subtle border
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.3), // 🌟 Softer shadow
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(16)),
                                            child: CachedNetworkImage(
                                              imageUrl: course.thumbnail ?? '',
                                              width: double.infinity,
                                              fit: BoxFit
                                                  .cover, // 🌟 Proper image fit
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[900]!,
                                                highlightColor:
                                                    Colors.grey[800]!,
                                                child: Container(
                                                    color: Colors.black,
                                                    width: double.infinity,
                                                    height: double.infinity),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.white24),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    course.title ?? '',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Cairo',
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                          Color>(Colors.red),
                                                  minHeight: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  progress > 0
                                                      ? "${(progress * 100).toInt()}% Complete"
                                                      : "Start Learning",
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 10,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
