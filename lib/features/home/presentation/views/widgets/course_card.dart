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
                  // 🖼️ Professional Course Thumbnail (Strict Layout)
                  SizedBox(
                    height: 180, // 📏 Strict Height enforced by User
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[100], // 🎨 Light base for logo contrast
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: course.thumbnail,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover, // 📏 Fills the area properly
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
                            color: Colors.grey[50],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),

                          // Progress Bar
                          ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  progress > 0
                                      ? "${(progress * 100).toInt()}% Completed"
                                      : "Start Learning",
                                  style: TextStyle(
                                    color: progress > 0
                                        ? AppColors.accent
                                        : Colors.grey[500],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[100],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.accent),
                                minHeight: 4,
                              ),
                            ),
                          ],
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
