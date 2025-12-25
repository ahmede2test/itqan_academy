import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Your Performance",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
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
                          Colors.blueAccent.withOpacity(0.2),
                          Colors.blueAccent.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border:
                          Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Cumulative GPA",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                letterSpacing: 1.2)),
                        const SizedBox(height: 15),
                        Text(
                          _cumulativeGPA.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.blueAccent, blurRadius: 15)
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
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
                            color: Colors.white,
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
                                style: TextStyle(color: Colors.white54)))
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
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        gradeColor.withOpacity(0.2),
                                    child: Text(res.gradeLetter,
                                        style: TextStyle(
                                            color: gradeColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text("Exam Score: ${res.score}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Cairo')),
                                  subtitle: Text("Points: ${res.earnedPoints}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  trailing: Text(
                                    "${res.createdAt.day}/${res.createdAt.month}/${res.createdAt.year}",
                                    style: const TextStyle(
                                        color: Colors.white30, fontSize: 12),
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
