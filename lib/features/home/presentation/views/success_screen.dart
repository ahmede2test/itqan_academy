import 'package:flutter/material.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';

class SuccessScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const SuccessScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = isArabic();
    final double percentage = totalQuestions > 0 ? score / totalQuestions : 0;
    final bool isPassed = percentage >= 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isPassed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed
                      ? Icons.emoji_events_rounded
                      : Icons.mood_bad_rounded,
                  color: isPassed ? Colors.green : Colors.red,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                isPassed
                    ? (isAr ? 'تهانينا!' : 'Congratulations!')
                    : (isAr ? 'حظاً أوفر' : 'Better Luck Next Time'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Score
              Text(
                '${isAr ? 'نتيجتك هي' : 'You Scored'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 48),

              // Back Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop until we hit the first route (Schedule)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isAr ? 'العودة للرئيسية' : 'Back to Home',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
