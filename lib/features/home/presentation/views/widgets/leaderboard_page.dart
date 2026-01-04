import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/home/data/repos/leaderboard_repository.dart';
import 'package:itqan_academy/features/home/presentation/manger/leaderboard_cubit/leaderboard_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/leaderboard_cubit/leaderboard_state.dart';
import 'package:itqan_academy/features/home/data/models/leaderboard_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'dart:math';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardCubit(
        LeaderboardRepository(Supabase.instance.client),
      )..fetchLeaderboard(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Deep Midnight Navy
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            isArabic() ? "لوحة المتصدرين" : "Leaderboard",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Starfield Background
            Positioned.fill(
              child: CustomPaint(
                painter: StarfieldPainter(),
              ),
            ),
            BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) {
                if (state is LeaderboardLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }
                if (state is LeaderboardError) {
                  debugPrint('🏗️ UI ERROR: ${state.message}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.amber[100], size: 40),
                        const SizedBox(height: 10),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37)),
                          onPressed: () =>
                              LeaderboardCubit.get(context).fetchLeaderboard(),
                          child: Text(isArabic() ? "إعادة المحاولة" : "Retry",
                              style: const TextStyle(color: Colors.black)),
                        )
                      ],
                    ),
                  );
                }
                if (state is LeaderboardLoaded) {
                  debugPrint(
                      '🏗️ UI STATE: ${state.topUsers.isEmpty ? "EMPTY LIST" : "DATA RECEIVED (${state.topUsers.length} users)"}');
                  if (state.topUsers.isEmpty) {
                    return Center(
                      child: Text(
                        isArabic() ? "لا توجد نتائج بعد" : "No results yet",
                        style: const TextStyle(
                            color: Colors.white54, fontFamily: 'Cairo'),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              16, 10, 16, 80), // Bottom padding for sticky bar
                          itemCount: state.topUsers.length,
                          itemBuilder: (context, index) {
                            final user = state.topUsers[index];
                            return _buildUserItem(context, user);
                          },
                        ),
                      ),
                      if (state.currentUser != null)
                        _buildStickyUserBar(context, state.currentUser!)
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, LeaderboardUser user) {
    final bool isTop3 = user.rank <= 3;
    final bool isFirst = user.rank == 1;

    // Gold Foil Gradient for Text
    final Shader goldShader = const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 50, 20));

    return Stack(
      children: [
        // Glow for Top 3
        if (isTop3)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isFirst
                        ? const Color(0xFFFFD700).withOpacity(0.3)
                        : const Color(0xFFC0C0C0).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                const Color(0xFF1E293B).withOpacity(0.6), // Glassmorphism Navy
            borderRadius: BorderRadius.circular(16),
            border: isFirst
                ? Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.5) // Thin Golden Border for #1
                : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Rank Number with "Gold Foil" look or simple style
              SizedBox(
                width: 30,
                child: Text(
                  "#${user.rank}",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    foreground: isTop3 ? (Paint()..shader = goldShader) : null,
                    color: isTop3 ? null : Colors.white54,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar (Gold Bordered)
              _buildAvatar(user.avatarUrl, user.name, user.rank),

              const SizedBox(width: 16),

              // Name
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Shiny Gold Badge for Points
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${user.totalScore}",
                      style: const TextStyle(
                        color: Color(0xFF0F172A), // Dark text on Gold
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? url, String name, int rank) {
    if (url != null && url.isNotEmpty) {
      final cleanUrl = url.trim();
      if (cleanUrl.startsWith('http')) {
        return ClipOval(
          child: SizedBox(
            width: 44,
            height: 44,
            child: Image.network(
              cleanUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildRankFallback(rank),
            ),
          ),
        );
      }
    }
    return _buildRankFallback(rank);
  }

  Widget _buildRankFallback(int rank) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2640),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        "#$rank",
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStickyUserBar(
      BuildContext context, LeaderboardUser currentUser) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9), // Darker Navy
        border: const Border(top: BorderSide(color: Color(0xFFD4AF37))),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37), // Gold
              shape: BoxShape.circle,
            ),
            child: Text(
              "#${currentUser.rank}",
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic() ? "ترتيبك الحالي" : "Your Current Rank",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                Text(
                  currentUser.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            ),
            child: Text(
              "${currentUser.totalScore} pts",
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 🎨 Custom Painter for Starfield Background
class StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withOpacity(0.3);
    final Random random = Random();

    // Draw 100 random stars
    for (int i = 0; i < 100; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 1.5 + 0.5; // Random size

      // Occasional Gold Stars
      if (random.nextDouble() > 0.9) {
        paint.color = const Color(0xFFFFD700).withOpacity(0.6);
        radius = random.nextDouble() * 2 + 1;
      } else {
        paint.color = Colors.white.withOpacity(0.3);
      }

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
