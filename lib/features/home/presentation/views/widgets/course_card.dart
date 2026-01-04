import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/courses/data/models/introduction_course_model.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_cubit.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_state.dart';
import 'package:itqan_academy/features/courses/presentation/views/widgets/CourseDetailScreen.dart';
import 'package:itqan_academy/core/widgets/hover_effect.dart';
import 'package:shimmer/shimmer.dart';

class CourseCard extends StatelessWidget {
  final UserCourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseProgressCubit, CourseProgressState>(
      builder: (context, state) {
        double progress = 0.0;
        if (state is CourseProgressSuccess) {
          progress = context
              .read<CourseProgressCubit>()
              .getCourseProgressPercentage(course.id, course.totalLessons);
        }

        return HoverEffect(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(course: course),
                ),
              );
            },
            child: Container(
              height: 320, // 📏 Uniform fixed height for stability
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Professional Course Thumbnail
                  SizedBox(
                    height: 160, // 📏 Adjusted height for better balance
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: course.thumbnail,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[50]!,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary, // 🏛️ Navy Placeholder
                          child: const Center(
                            child: Icon(
                              Icons.school_rounded,
                              color: AppColors.accent, // 🌟 Gold Icon
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with safe constraints
                          Flexible(
                            child: Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                height: 1.3,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Progress Branding
                          Text(
                            progress > 0
                                ? "${(progress * 100).toInt()}% Completed"
                                : "Start Learning",
                            style: const TextStyle(
                              color: AppColors.accent, // 🌟 Always Gold Luxury
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
