import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/delivery_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/exam_schedule_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/home_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/home_screen_view_body.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/profile_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/web_side_panel.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/saas_header.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/core/services/connectivity_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // 0: Home
      const DeliveryPage(), // 1: Services (Delivery) - No lazy load for now to ensure data is there
      const CoursesPage(), // 2: Courses
      const ExamSchedulePage(), // 3: Exams (Tests)
      const ProfilePage(), // 4: Profile
    ];
    // 🚀 Lazy Initialization: Wait for UI to settle before starting listener
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ConnectivityService().init(context);
      }
    });
  }

  @override
  void dispose() {
    ConnectivityService().dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoursesSelected = _selectedIndex == 2;
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: kIsWeb
          ? Row(
              children: [
                WebSidePanel(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SaaSHeader(
                        onNotificationTap: () => _onItemTapped(3),
                        onProfileTap: () => _onItemTapped(4),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _buildMobileLayout(_pages, isDesktop, isCoursesSelected),
    );
  }

  // 📱 EXISTING: Mobile Layout (Refined)
  Widget _buildMobileLayout(
    List<Widget> pages,
    bool isDesktop,
    bool isCoursesSelected,
  ) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  backgroundColor: AppColors.primary,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.accent),
                  unselectedIconTheme:
                      const IconThemeData(color: Colors.white54),
                  selectedLabelTextStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'Cairo', fontSize: 12),
                  unselectedLabelTextStyle: const TextStyle(
                      color: Colors.white54, fontFamily: 'Cairo', fontSize: 12),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(S.of(context).home),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.auto_stories_outlined),
                      selectedIcon: const Icon(Icons.auto_stories),
                      label: Text(S.of(context).delivery),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.school_outlined),
                      selectedIcon: const Icon(Icons.school),
                      label: Text(S.of(context).courses),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.quiz_outlined),
                      selectedIcon: const Icon(Icons.quiz),
                      label: Text(S.of(context).tests),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.account_circle_outlined),
                      selectedIcon: const Icon(Icons.account_circle),
                      label: Text(S.of(context).myAccount),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
        if (!isDesktop)
          Container(
            color: AppColors.primary,
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                    icon: Icons.home, label: S.of(context).home, index: 0),
                _buildNavItem(
                    icon: Icons.auto_stories,
                    label: S.of(context).delivery,
                    index: 1),
                _buildNavItem(
                    icon: Icons.school, label: S.of(context).courses, index: 2),
                _buildNavItem(
                    icon: Icons.quiz, label: S.of(context).tests, index: 3),
                _buildNavItem(
                    icon: Icons.person,
                    label: S.of(context).myAccount,
                    index: 4),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.red : Colors.white54),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
