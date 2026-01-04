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
      resizeToAvoidBottomInset: true, // ⌨️ Prevent keyboard overlap
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // Padding vertical
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Vertically center
                    children: [
                      const SizedBox(height: 50), // 📏 Top Breathing Room

                      // --- Luxury Typography Logo ---
                      Center(
                        child: _buildLuxuryTextLogo(),
                      ),
                      const SizedBox(height: 30), // 📏 Exact Spacing to Title

                      // --- Title ---
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 48),

                      // --- Form Body ---
                      body,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLuxuryTextLogo() {
    return FittedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.accent], // Navy to Gold
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              "ITQAN",
              style: TextStyle(
                color: Colors.white, // Color is overridden by ShaderMask
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "A C A D E M Y",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.grey[500],
              letterSpacing: 10,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
