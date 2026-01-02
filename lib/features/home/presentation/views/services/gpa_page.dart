import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../data/repos/exams_repository.dart';

class GPAPage extends StatefulWidget {
  const GPAPage({super.key});

  @override
  State<GPAPage> createState() => _GPAPageState();
}

class _GPAPageState extends State<GPAPage> {
  late final ExamsRepository _repository;
  double _cumulativeGPA = 0.0;
  bool _isLoading = true;
  List<ExamResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _repository = ExamsRepositoryImpl(Supabase.instance.client);
    _fetchAndCalculateGPA();
  }

  Future<void> _fetchAndCalculateGPA() async {
    setState(() => _isLoading = true);
    try {
      final results = await _repository.fetchUserExamResults();

      if (results.isEmpty) {
        setState(() {
          _results = [];
          _cumulativeGPA = 0.0;
          _isLoading = false;
        });
        return;
      }

      double totalPoints = 0;
      for (var result in results) {
        totalPoints += result.earnedPoints;
      }

      // Calculate Average
      final avg = totalPoints / results.length;

      setState(() {
        _results = results;
        _cumulativeGPA = avg;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Your Performance",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // GPA Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.primary.withOpacity(0.02)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Cumulative GPA",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                letterSpacing: 1.2)),
                        const SizedBox(height: 15),
                        Text(
                          _cumulativeGPA.toStringAsFixed(2),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 15)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_results.length} Exams Taken",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Breakdown Header
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Recent Results",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),

                  // List
                  Expanded(
                    child: _results.isEmpty
                        ? const Center(
                            child: Text("No exams taken yet.",
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final res = _results[index];
                              // Color code based on Grade
                              Color gradeColor = Colors.green;
                              if (res.gradeLetter.startsWith('B'))
                                gradeColor = Colors.blue;
                              if (res.gradeLetter.startsWith('C'))
                                gradeColor = Colors.orange;
                              if (res.gradeLetter.startsWith('D'))
                                gradeColor = Colors.orangeAccent;
                              if (res.gradeLetter.startsWith('F'))
                                gradeColor = Colors.red;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        gradeColor.withOpacity(0.1),
                                    child: Text(res.gradeLetter,
                                        style: TextStyle(
                                            color: gradeColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text("Exam Score: ${res.score}",
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text("Points: ${res.earnedPoints}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  trailing: Text(
                                    "${res.createdAt.day}/${res.createdAt.month}/${res.createdAt.year}",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
