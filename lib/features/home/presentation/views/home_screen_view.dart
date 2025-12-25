import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/delivery_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/exam_schedule_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/home_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/home_screen_view_body.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/profile_page.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/web_top_navbar.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/core/services/connectivity_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<bool> _loadedPages = [
    true, // Home
    false, // Delivery
    false, // Courses
    false, // Tests
    false, // Profile
  ];

  @override
  void initState() {
    super.initState();
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
      _loadedPages[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoursesSelected = _selectedIndex == 2;
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    final List<Widget> _pages = [
      const HomePage(), // 0: Home
      _loadedPages[1]
          ? const DeliveryPage()
          : const SizedBox.shrink(), // 1: Services (Delivery)
      _loadedPages[2]
          ? const CoursesPage()
          : const SizedBox.shrink(), // 2: Courses
      _loadedPages[3]
          ? const ExamSchedulePage()
          : const SizedBox.shrink(), // 3: Exams (Tests)
      _loadedPages[4]
          ? const ProfilePage()
          : const SizedBox.shrink(), // 4: Profile
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: kIsWeb
            ? _buildWebLayout(_pages) // 🌐 WEB LAYOUT
            : _buildMobileLayout(
                _pages, isDesktop, isCoursesSelected), // 📱 MOBILE LAYOUT
      ),
    );
  }

  // 🌐 NEW: Web Layout with Top Navbar
  Widget _buildWebLayout(List<Widget> pages) {
    return Column(
      children: [
        WebTopNavbar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
      ],
    );
  }

  // 📱 EXISTING: Mobile Layout (UNCHANGED)
  Widget _buildMobileLayout(
    List<Widget> pages,
    bool isDesktop,
    bool isCoursesSelected,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: const Color(0xFF121212),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                _onItemTapped(index);
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.red),
              unselectedIconTheme: const IconThemeData(color: Colors.white54),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.white, fontFamily: 'Cairo', fontSize: 12),
              unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white54, fontFamily: 'Cairo', fontSize: 12),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(S.of(context).home), // index 0
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.home_repair_service_outlined),
                  selectedIcon: const Icon(Icons.home_repair_service_sharp),
                  label: Text(S.of(context).delivery), // index 1 (Services)
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.book_outlined),
                  selectedIcon: const Icon(Icons.book),
                  label: Text(S.of(context).courses), // index 2
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.schedule_outlined),
                  selectedIcon: const Icon(Icons.schedule),
                  label: Text(S.of(context).tests), // index 3 (Exams)
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(S.of(context).myAccount), // index 4 (Profile)
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
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              color: const Color(0xFF121212),
              height:
                  100, // Fixed height Container instead of SizedBox+Stack with overflow
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(
                            icon: Icons.home,
                            label: S.of(context).home,
                            index: 0),
                        _buildNavItem(
                            icon: Icons.home_repair_service_sharp,
                            label: S.of(context).delivery,
                            index: 1),
                        const SizedBox(width: 60),
                        _buildNavItem(
                            icon: Icons.schedule,
                            label: S.of(context).tests,
                            index: 3),
                        _buildNavItem(
                            icon: Icons.person,
                            label: S.of(context).myAccount,
                            index: 4),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    child: GestureDetector(
                      onTap: () => _onItemTapped(2),
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isCoursesSelected ? Colors.red : Colors.grey[800],
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            if (isCoursesSelected)
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/book.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    child: Text(
                      S.of(context).courses,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isCoursesSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
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
    );
  }
}
