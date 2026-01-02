import 'package:flutter/material.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class AuthTemplate extends StatelessWidget {
  final Widget body;
  final String title;
  final String subtitle;

  const AuthTemplate({
    super.key,
    required this.body,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8EF), // Cream Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4, // Soft elevation
              shadowColor: Colors.black.withOpacity(0.1),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Logo ---
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                        'assets/images/itqan_logo.png',
                        height: 80,
                        // BlendMode.multiply helps melt white bg into the card
                        color: Colors.white,
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Title ---
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // --- Subtitle ---
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- Form Body ---
                    body,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
