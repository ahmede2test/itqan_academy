import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'package:itqan_academy/features/home/data/models/exam_result_model.dart';

import 'package:itqan_academy/features/home/presentation/views/quiz_play_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/home/presentation/manger/exams_cubit/exams_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/exams_cubit/exams_state.dart';
import 'package:itqan_academy/features/home/data/models/question_model.dart';

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  Map<String, ExamResultModel> _userResults = {};

  // DEBUG MODE: Set to false to disable quiz entry as requested
  static const bool _forceStartDebug = false;

  @override
  void initState() {
    super.initState();
    _fetchUserResults();
  }

  Future<void> _fetchUserResults() async {
    final results = await context.read<ExamsCubit>().fetchUserResults();
    if (mounted) {
      setState(() {
        _userResults = {for (var r in results) r.examId: r};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = isArabic();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          S.of(context).examSchedule,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ExamsCubit, ExamsState>(
        builder: (context, state) {
          if (state is ExamsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }

          if (state is ExamsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is ExamsLoaded) {
            final exams = state.exams;

            if (exams.isEmpty) {
              return Center(
                child: Text(
                  isAr ? 'لا توجد اختبارات مجدولة' : 'No exams scheduled',
                  style:
                      const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _fetchUserResults();
                context.read<ExamsCubit>().getExams();
              },
              color: Colors.red,
              child: LayoutBuilder(
                // 🚀 Use LayoutBuilder for responsive sizing
                builder: (context, constraints) {
                  // 🌐 Web: Use Wrap for dynamic height
                  if (kIsWeb) {
                    return _buildWebExamGrid(exams, constraints.maxWidth, isAr);
                  }

                  // 📱 Mobile: Existing GridView (UNCHANGED)
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width >= 1024
                          ? 3
                          : MediaQuery.of(context).size.width >= 600
                              ? 2
                              : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio:
                          MediaQuery.of(context).size.width >= 1024
                              ? 1.4
                              : 1.15,
                    ),
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      final subject = isAr ? exam.subjectAr : exam.subjectEn;
                      final venue = isAr ? exam.venueAr : exam.venueEn;
                      final result = _userResults[exam.id];

                      return ExamCard(
                        examId: exam.id,
                        subject: subject,
                        date: exam.date,
                        time: exam.time,
                        venue: venue,
                        duration: exam.duration,
                        isAr: isAr,
                        result: result,
                        forceStartDebug: _forceStartDebug,
                        onRefresh: _fetchUserResults,
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // 🌟 UPDATED: Premium Web-specific grid with adaptive sizing
  Widget _buildWebExamGrid(List<dynamic> exams, double maxWidth, bool isAr) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(40), // 🌟 Increased breathing room
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350, // 🌟 Adaptive card width
          mainAxisSpacing: 24, // 🌟 Increased vertical spacing
          crossAxisSpacing: 24, // 🌟 Increased horizontal spacing
          mainAxisExtent:
              520, // 🌟 Definitive height to eliminate 100px overflow
        ),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          final subject = isAr ? exam.subjectAr : exam.subjectEn;
          final venue = isAr ? exam.venueAr : exam.venueEn;
          final result = _userResults[exam.id];

          return ExamCard(
            examId: exam.id,
            subject: subject,
            date: exam.date,
            time: exam.time,
            venue: venue,
            duration: exam.duration,
            isAr: isAr,
            result: result,
            forceStartDebug: _forceStartDebug,
            onRefresh: _fetchUserResults,
          );
        },
      ),
    );
  }
}

class ExamCard extends StatefulWidget {
  final String examId;
  final String subject;
  final String date;
  final String time;
  final String venue;
  final int duration;
  final bool isAr;
  final ExamResultModel? result;
  final bool forceStartDebug;
  final VoidCallback onRefresh;

  const ExamCard({
    super.key,
    required this.examId,
    required this.subject,
    required this.date,
    required this.time,
    required this.venue,
    required this.duration,
    required this.isAr,
    this.result,
    required this.forceStartDebug,
    required this.onRefresh,
  });

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  Timer? _timer;
  String _countdownText = '';
  Color _countdownColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isPrecached = false;
  bool _notificationShown = false;

  void _startTimer() {
    _updateTime(); // Initial update
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    try {
      final examDateTime = _parseExamDateTime();
      if (examDateTime == null) return;

      final now = DateTime.now();
      final difference = examDateTime.difference(now);

      // Pre-caching logic (30 seconds before)
      if (difference.inSeconds <= 30 &&
          difference.inSeconds > 0 &&
          !_isPrecached) {
        _isPrecached = true;
        context.read<ExamsCubit>().preCacheQuestions(widget.examId);
      }

      if (difference.isNegative) {
        // Exam started or ended
        if (!_notificationShown &&
            !difference.isNegative &&
            widget.result == null) {
          // This case might not be reached if it starts negative,
          // but we check if it just turned negative.
        }

        // Show notification if it just became active
        if (!_notificationShown && widget.result == null) {
          _notificationShown = true;
          _showExamOpenNotification();
        }

        setState(() {
          _countdownText = widget.isAr ? 'بدأ الاختبار' : 'Exam Started';
          _countdownColor = Colors.green;
        });
      } else {
        // Countdown
        final days = difference.inDays;
        final hours = difference.inHours % 24;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        String text = '';
        if (days > 0) text += '${days}d ';
        text +=
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        setState(() {
          _countdownText = '${widget.isAr ? 'يبدأ بعد' : 'Starts in'}: $text';
          _countdownColor = Colors.orange;
        });
      }
    } catch (_) {}
  }

  void _showExamOpenNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAr ? 'الاختبار متاح الآن!' : 'The exam is now open!',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: widget.isAr ? 'انضم الآن' : 'Join Now',
            textColor: Colors.white,
            onPressed: () {
              _navigateToQuiz(context);
            },
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    });
  }

  DateTime? _parseExamDateTime() {
    try {
      DateTime? examDate = DateTime.tryParse(widget.date);
      if (examDate != null) {
        final timeParts = widget.time.trim().split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1].substring(0, 2)); // simple trim

          // Basic AM/PM handling
          String ampm = widget.time.toUpperCase();
          if (ampm.contains('PM') && hour < 12) hour += 12;
          if (ampm.contains('AM') && hour == 12) hour = 0;

          return DateTime(
              examDate.year, examDate.month, examDate.day, hour, minute);
        }
      }
    } catch (_) {}
    return null;
  }

  void _navigateToQuiz(BuildContext context) async {
    final examDateTime = _parseExamDateTime();
    final now = DateTime.now();

    if (!widget.forceStartDebug &&
        examDateTime != null &&
        now.isBefore(examDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isAr
              ? 'الاختبار لم يبدأ بعد'
              : 'The exam hasn\'t started yet'),
        ),
      );
      return;
    }

    final state = context.read<ExamsCubit>().state;
    List<QuestionModel>? cachedQuestions;
    if (state is ExamsLoaded) {
      cachedQuestions = state.cachedQuestions?[widget.examId];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(
          examTitle: widget.subject,
          examId: widget.examId,
          questions: cachedQuestions,
          durationMinutes: widget.duration,
        ),
      ),
    );
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    // Localized Labels
    final labelDate = widget.isAr ? 'التاريخ' : 'Date';
    final labelTime = widget.isAr ? 'الوقت' : 'Time';
    final labelVenue = widget.isAr ? 'القاعة' : 'Room';

    // 1. Time Calculation & Formatting
    DateTime? examDateTime = _parseExamDateTime();

    String formattedDate = widget.date;
    String formattedTime = widget.time;

    if (examDateTime != null) {
      try {
        // Format Date: "Saturday, 20 May"
        formattedDate = DateFormat('EEEE, d MMMM', widget.isAr ? 'ar' : 'en')
            .format(examDateTime);
        // Format Time: "03:15 PM"
        formattedTime = DateFormat('hh:mm a', widget.isAr ? 'ar' : 'en')
            .format(examDateTime);
      } catch (e) {
        debugPrint("DateFormat Error: $e");
      }
    }

    // Dynamic Logic for Button state
    final bool isActive = widget.forceStartDebug ||
        (examDateTime != null && DateTime.now().isAfter(examDateTime));
    final bool isFinished = widget.result != null;

    final String buttonText;
    final Color buttonColor;
    final IconData buttonIcon;
    final VoidCallback? onTapAction;

    if (isFinished) {
      buttonText = widget.isAr ? 'تم الانتهاء' : 'Finished';
      buttonColor = Colors.green;
      buttonIcon = Icons.check_circle_rounded;
      onTapAction = null;
    } else if (isActive) {
      buttonText = widget.isAr ? 'ابدأ الاختبار' : 'Start Exam';
      buttonColor = Colors.red;
      buttonIcon = Icons.play_arrow_rounded;
      onTapAction = () => _navigateToQuiz(context);
    } else {
      buttonText = widget.isAr ? 'الجدول فقط' : 'Schedule Only';
      buttonColor = Colors.blueGrey;
      buttonIcon = Icons.event_note_rounded;
      onTapAction = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapAction,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: isActive && !isFinished
                    ? Colors.red.withOpacity(0.8)
                    : Colors.white10,
                width: isActive && !isFinished ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Subject Name & Countdown
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isFinished ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isFinished
                            ? Icons.assignment_turned_in_rounded
                            : Icons.menu_book_rounded,
                        color: isFinished ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.subject,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            if (isActive && !isFinished)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: _LivePulseIcon(),
                              ),
                          ],
                        ),
                        if (widget.result != null)
                          Text(
                            '${widget.isAr ? 'الدرجة' : 'Score'}: ${widget.result!.score}/${widget.result!.totalQuestions}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          )
                        else if (examDateTime != null)
                          Text(_countdownText,
                              style: TextStyle(
                                color: _countdownColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ))
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today_rounded,
                        label: labelDate,
                        value: formattedDate, // Use formatted date
                        color: Colors.blueAccent,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.access_time_rounded,
                        label: labelTime,
                        value: formattedTime, // Use formatted time
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  icon: Icons.location_on_rounded,
                  label: labelVenue,
                  value: widget.venue,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(buttonIcon, color: buttonColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method _navigateToQuiz was removed as it is no longer used in the schedule-only view.

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LivePulseIcon extends StatefulWidget {
  const _LivePulseIcon();

  @override
  State<_LivePulseIcon> createState() => _LivePulseIconState();
}

class _LivePulseIconState extends State<_LivePulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
