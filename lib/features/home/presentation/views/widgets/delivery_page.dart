import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/views/services/gpa_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/todo_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/notes_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/leaderboard_page.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/home/presentation/manger/services_cubit/services_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/services_cubit/services_state.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServicesCubit>().fetchAcademyServices();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = isArabic();

    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        if (state is ServiceOrderSuccess) {
          customShowToast(msg: state.message);
        } else if (state is ServicesError) {
          customShowToast(msg: state.message);
        }
      },
      // 🌍 STATIC IDENTITY: Force RTL Layout for "Arabic Vibe" always
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            title: Text(
              S.of(context).ServicesPage,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 🏆 Row 1: Leaderboard
                  _buildBentoCard(
                    context: context,
                    title: isAr ? "لوحة المتصدرين" : "Leaderboard",
                    subtitle:
                        isAr ? "تنافس مع الأفضل" : "Compete with the best",
                    icon: Icons.emoji_events_rounded,
                    showCrown: true,

                    gradientColors: [
                      const Color(0xFF1A237E),
                      const Color(0xFF283593)
                    ],
                    iconColor: const Color(0xFFFFD700),

                    height: 160,
                    width: double.infinity,

                    // 📐 STATIC SHAPE: Top-Right & Bottom-Left 40px
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),

                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),

                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LeaderboardPage())),
                  ),

                  const SizedBox(height: 20),

                  // 🧩 Row 2: Split Layout (RTL Forced: Tasks on Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tasks
                      Expanded(
                        flex: 1,
                        child: _buildBentoCard(
                          context: context,
                          title: isAr ? "المهام" : "Tasks",
                          subtitle: isAr ? "نظم وقتك" : "Organize",
                          icon: Icons.check_circle_outline_rounded,

                          gradientColors: [
                            const Color(0xFF1A237E),
                            const Color(0xFF283593)
                          ],
                          iconColor: const Color(0xFFFFD700),

                          height: 240,

                          // 📐 STATIC SHAPE: Top-Right & Bottom-Left 40px
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),

                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ToDoPage())),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // GPA & Notes
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // GPA
                            _buildBentoCard(
                              context: context,
                              title: isAr ? "المعدل" : "GPA",
                              subtitle: null,
                              icon: Icons.calculate_outlined,

                              gradientColors: [
                                const Color(0xFF1A237E),
                                const Color(0xFF283593)
                              ],
                              iconColor: const Color(0xFFFFD700),

                              height: 110,

                              // 📐 STATIC SHAPE
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),

                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const GPAPage())),
                            ),

                            const SizedBox(height: 20),

                            // Notes
                            _buildBentoCard(
                              context: context,
                              title: isAr ? "ملاحظات" : "Notes",
                              subtitle: null,
                              icon: Icons.edit_note_rounded,

                              gradientColors: [
                                const Color(0xFF1A237E),
                                const Color(0xFF283593)
                              ],
                              iconColor: const Color(0xFFFFD700),

                              height: 110,

                              // 📐 STATIC SHAPE
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),

                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const NotesPage())),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
    required double height,
    double? width,
    required BorderRadius borderRadius, // Fixed Type: BorderRadius
    required VoidCallback onTap,
    Border? border,
    bool showCrown = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius, // No cast needed
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            // 🔒 STATIC ALIGNMENT: Left to Right
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
          border: border ??
              Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                width: 0.5,
              ),
        ),
        child: Stack(
          children: [
            // 🔒 STATIC POSITION: Right
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                // RTL Directionality handles CrossAxisAlignment.start -> Right
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFFF9F9F9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                if (showCrown) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.workspace_premium,
                                      color: Color(0xFFFFD700), size: 20),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              subtitle,
                              // RTL Directionality handles TextAlign.start -> Right
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
