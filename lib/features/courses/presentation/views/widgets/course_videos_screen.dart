import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itqan_academy/core/utils/app_colors.dart'; // Import AppColors

import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/courses/data/models/introduction_course_model.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_state.dart';
import 'native_video_player.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_cubit.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_progress_cubit/course_progress_state.dart';

class CourseVideosScreen extends StatefulWidget {
  final UserCourseModel course;

  const CourseVideosScreen({super.key, required this.course});

  @override
  State<CourseVideosScreen> createState() => _CourseVideosScreenState();
}

class _CourseVideosScreenState extends State<CourseVideosScreen> {
  String? _currentVideoUrl;
  String? _currentTitle;
  int _currentLessonIndex = 0;
  bool _isFullScreen = false;
  double _progressValue = 0.0;
  int _completedCount = 0;
  int _totalLessons = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<CourseProgressCubit>()
            .fetchCourseProgress(widget.course.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CourseCubit, CourseState>(
          listener: (context, state) {
            if (state is CourseLessonsSuccessState) {
              final lessons = state.lessonsTopicModel.data;
              if (lessons != null &&
                  lessons.isNotEmpty &&
                  _currentVideoUrl == null) {
                if (mounted) {
                  setState(() {
                    _currentVideoUrl = lessons.first.videoUrl;
                    _currentTitle = lessons.first.postTitle;
                    _currentLessonIndex = 0;
                  });
                }
              }
              _updateProgress();
            }
          },
        ),
        BlocListener<CourseProgressCubit, CourseProgressState>(
          listener: (context, state) {
            _updateProgress();
          },
        ),
      ],
      child: BlocBuilder<CourseProgressCubit, CourseProgressState>(
        builder: (context, progressState) {
          return BlocBuilder<CourseCubit, CourseState>(
            builder: (context, courseState) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: _isFullScreen
                    ? null
                    : AppBar(
                        title: Text(
                          _currentTitle ?? widget.course.title,
                          style: const TextStyle(
                              color: AppColors.primary, fontFamily: 'Cairo'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        centerTitle: false,
                        titleSpacing: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        backgroundColor: Colors.transparent, // Transparent
                        elevation: 0,
                      ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 1. Fixed Video Player Area
                        _buildVideoPlayer(),

                        // 2. Lesson Details Section
                        _buildProgressHeader(),

                        // 🚀 New: PDF Materials Button
                        _buildPdfButton(courseState),

                        // Lesson List or Error/Retry
                        if (courseState is CourseLessonsErrorState)
                          _buildRetryButton(
                              context, widget.course.id.toString())
                        else
                          _buildLessonList(courseState, progressState),

                        // Bottom padding
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      color: Colors.black, // Keep video player background black
      child: Center(
        child: _currentVideoUrl != null
            ? NativeVideoPlayer(
                key: ValueKey(_currentVideoUrl),
                videoUrl: _currentVideoUrl!,
                thumbnailUrl: widget.course.thumbnail,
                autoPlay: true,
                onProgress: (position) {
                  // TODO: Save progress logic here
                },
                onFullScreenChanged: (isFullScreen) {
                  if (mounted) {
                    setState(() {
                      _isFullScreen = isFullScreen;
                    });
                  }
                },
              )
            : const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline,
                          color: Colors.white24, size: 60),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _updateProgress() {
    final courseState = context.read<CourseCubit>().state;
    final progressState = context.read<CourseProgressCubit>().state;

    if (courseState is CourseLessonsSuccessState &&
        progressState is CourseProgressSuccess) {
      final lessons = courseState.lessonsTopicModel.data ?? [];
      final completedIds = progressState.completedLessons;

      if (mounted) {
        setState(() {
          _totalLessons = lessons.length;
          _completedCount =
              lessons.where((l) => completedIds.contains(l.id)).length;
          if (_totalLessons > 0) {
            _progressValue = _completedCount / _totalLessons;
          }
        });
      }
    }
  }

  Widget _buildProgressHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, // White background
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).educationalCourses,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo'),
              ),
              Text(
                "$_completedCount / $_totalLessons Lessons",
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 14, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary), // Use primary
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(_progressValue * 100).toInt()}% Complete",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPdfButton(CourseState state) {
    if (state is CourseLessonsSuccessState) {
      final lessons = state.lessonsTopicModel.data ?? [];
      if (_currentLessonIndex < lessons.length) {
        final currentLesson = lessons[_currentLessonIndex];
        final pdfUrl = currentLesson.pdfUrl;

        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(pdfUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                "Download Lesson Materials (PDF)",
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Cairo', fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Primary color
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildLessonList(
      CourseState courseState, CourseProgressState progressState) {
    if (courseState is CourseLessonsLoadingState) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (courseState is CourseLessonsErrorState) {
      return Center(
          child: Text(courseState.message,
              style: const TextStyle(color: AppColors.primary)));
    }

    if (courseState is CourseLessonsSuccessState) {
      final lessons = courseState.lessonsTopicModel.data;
      if (lessons == null || lessons.isEmpty) {
        return Center(
            child: Text(S.of(context).noAvailableCourses,
                style: const TextStyle(color: AppColors.primary)));
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey[200], height: 1),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final isSelected = index == _currentLessonIndex;

          bool isCompleted = false;
          if (progressState is CourseProgressSuccess) {
            isCompleted = progressState.completedLessons.contains(lesson.id);
          }

          return Container(
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? Icons.pause : Icons.play_arrow_rounded,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
              title: Text(
                lesson.postTitle ?? "Lesson ${index + 1}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : (isCompleted ? Colors.grey : AppColors.primary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      "10:00", // Placeholder
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const Spacer(),
                    // Progress Icon / Button
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: isCompleted ? Colors.green : Colors.grey[400],
                    ),
                  ],
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.graphic_eq,
                      color: AppColors.primary, size: 20)
                  : (isCompleted
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 24)
                      : Icon(Icons.play_circle_outline,
                          color: Colors.grey[300], size: 24)),
              onTap: () {
                if (mounted) {
                  setState(() {
                    _currentVideoUrl = lesson.videoUrl;
                    _currentTitle = lesson.postTitle;
                    _currentLessonIndex = index;
                  });

                  // 🚀 Automatic tracking: Mark as watched when opened
                  if (!isCompleted) {
                    context.read<CourseProgressCubit>().markLessonAsCompleted(
                          lessonId: lesson.id,
                          courseId: widget.course.id,
                          completed: true,
                        );
                  }
                }
              },
            ),
          );
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildRetryButton(BuildContext context, String courseId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.signal_wifi_off_rounded,
              color: Colors.grey, size: 80),
          const SizedBox(height: 16),
          const Text(
            "Connection Error / SSL Handshake Failed",
            style: TextStyle(
                color: Colors.grey, fontFamily: 'Cairo', fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<CourseCubit>()
                  .getCoursesLessons(courseContentsId: courseId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry Connection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
