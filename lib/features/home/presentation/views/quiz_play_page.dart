import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'package:itqan_academy/features/home/data/models/question_model.dart';
import 'package:itqan_academy/features/home/data/repos/exams_repository.dart';

class QuizPlayPage extends StatefulWidget {
  final String examTitle;
  final dynamic examId;
  final List<QuestionModel>? questions;
  final int durationMinutes;

  const QuizPlayPage({
    super.key,
    required this.examTitle,
    this.examId,
    this.questions,
    this.durationMinutes = 30,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  bool _hasError = false;

  late final ExamsRepository _examsRepository;

  // Timer
  Timer? _timer;
  late DateTime _endTime;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _endTime = DateTime.now().add(Duration(minutes: widget.durationMinutes));
    _remainingSeconds = widget.durationMinutes * 60;
    _examsRepository = ExamsRepositoryImpl(Supabase.instance.client);

    if (widget.questions != null && widget.questions!.isNotEmpty) {
      _questions = widget.questions!;
      _isLoading = false;
      _startTimer();
    } else if (widget.examId != null) {
      _fetchQuestions();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = _endTime.difference(now);

      if (difference.isNegative) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        _submitQuiz(autoSubmit: true);
      } else {
        setState(() {
          _remainingSeconds = difference.inSeconds;
        });
      }
    });
  }

  String get _timerString {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await _examsRepository.fetchQuestions(widget.examId);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _answerQuestion(int index) {
    if (_isAnswered || _isSubmitting) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final int correctAnswerIndex =
        currentQuestion.options.indexOf(currentQuestion.correctAnswer);

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (index == correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _isAnswered = false;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_isSubmitting) return;
    _timer?.cancel();

    setState(() {
      _isSubmitting = true;
    });

    // If auto-submit, we don't increment score for current unattended question
    // If manual submit (last question answered), score is already updated in _answerQuestion

    try {
      if (widget.examId != null) {
        debugPrint('Submitting quiz for exam: ${widget.examId}');
        await _examsRepository.submitExamResult(
          widget.examId,
          _score,
          _questions.length,
        );
      } else {
        debugPrint('Msg: Skipping DB submit (No Exam ID)');
      }

      if (mounted) {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: Text(
                      isArabic() ? 'تم إرسال الاختبار' : 'Exam Submitted',
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Cairo')),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        isArabic()
                            ? 'لقد انتهيت من الاختبار بنجاح!'
                            : 'You have successfully completed the exam!',
                        style: const TextStyle(
                            color: Colors.white70, fontFamily: 'Cairo')),
                    const SizedBox(height: 16),
                    Text(
                        '${isArabic() ? 'الدرجة' : 'Score'}: $_score / ${_questions.length}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo')),
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        child: Text(isArabic() ? 'خروج' : 'Exit',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)))
                  ],
                ));

        if (mounted) {
          Navigator.pop(context); // Close Page to return to Schedule
        }
      }
    } catch (e) {
      debugPrint("Error submitting result: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving result: $e')));
        Navigator.pop(context); // Force exit on error so user isn't stuck
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Text(
            isArabic() ? 'فشل تحميل الأسئلة' : 'Failed to load questions',
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Text(
            isArabic()
                ? 'لا توجد أسئلة لهذا الاختبار'
                : 'No questions found for this exam',
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final bool isAr = isArabic();

    // Answer Logic
    final String questionText = isAr
        ? (question.questionAr.isNotEmpty
            ? question.questionAr
            : question.questionEn)
        : (question.questionEn.isNotEmpty
            ? question.questionEn
            : question.questionAr);

    final List<String> options = question.options;
    final int correctAnswerIndex = options.indexOf(question.correctAnswer);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            widget.examTitle,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _remainingSeconds < 60
                                ? Colors.red.withOpacity(0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _remainingSeconds < 60
                                    ? Colors.red
                                    : Colors.white24)),
                        child: Row(children: [
                          Icon(Icons.timer_outlined,
                              size: 16,
                              color: _remainingSeconds < 60
                                  ? Colors.red
                                  : Colors.white),
                          const SizedBox(width: 6),
                          Text(_timerString,
                              style: TextStyle(
                                color: _remainingSeconds < 60
                                    ? Colors.red
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier', // Monospace for numbers
                              ))
                        ]))))
          ],
        ),
        body: _isSubmitting
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Indicator
                    LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      backgroundColor: Colors.grey[800],
                      color: Colors.red,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 20),

                    // Question Counter
                    Text(
                      "${isAr ? 'سؤال' : 'Question'} ${_currentQuestionIndex + 1}/${_questions.length}",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 10),

                    // Question Text
                    Text(
                      questionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 30),

                    // Options List
                    Expanded(
                      child: ListView.separated(
                        itemCount: options.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          // Determine color state
                          Color borderColor = Colors.white12;
                          Color backgroundColor = const Color(0xFF1E1E1E);

                          if (_isAnswered) {
                            if (index == correctAnswerIndex) {
                              borderColor = Colors.green;
                              backgroundColor = Colors.green.withOpacity(0.1);
                            } else if (index == _selectedOptionIndex) {
                              borderColor = Colors.red;
                              backgroundColor = Colors.red.withOpacity(0.1);
                            }
                          } else {
                            if (_selectedOptionIndex == index) {
                              borderColor = const Color(0xFFD4AF37); // Gold
                            }
                          }

                          return GestureDetector(
                            onTap: () => _answerQuestion(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: borderColor, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: _isAnswered &&
                                                  index == correctAnswerIndex
                                              ? Colors.green
                                              : (_isAnswered &&
                                                      index ==
                                                          _selectedOptionIndex
                                                  ? Colors.red
                                                  : Colors.white54),
                                          width: 2),
                                      color: _isAnswered &&
                                              index == correctAnswerIndex
                                          ? Colors.green
                                          : (_isAnswered &&
                                                  index == _selectedOptionIndex
                                              ? Colors.red
                                              : Colors.transparent),
                                    ),
                                    child: _isAnswered &&
                                            (index == correctAnswerIndex ||
                                                index == _selectedOptionIndex)
                                        ? const Icon(Icons.check,
                                            size: 16, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      options[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          isArabic() ? 'هل تريد الخروج؟' : 'Exit Exam?',
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        content: Text(
          isArabic()
              ? 'سيتم فقدان تقدمك ولن تتمكن من العودة!'
              : 'Your progress will be lost and you won\'t be able to return!',
          style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic() ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            child: Text(isArabic() ? 'خروج نهائي' : 'Exit Anyway',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
