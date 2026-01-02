import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/generated/l10n.dart';

class WebSidePanel extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WebSidePanel({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<WebSidePanel> createState() => _WebSidePanelState();
}

class _WebSidePanelState extends State<WebSidePanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 260 : 80, // SaaS Standard width: 260px
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔹 Header / Logo
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.darken, // 🧪 surgical blending to remove white bg
              ),
              child: Image.asset(
                'assets/images/itqan_logo.png',
                height: _isExpanded ? 60 : 35,
                color: Colors.white.withOpacity(0.9),
                colorBlendMode:
                    BlendMode.srcIn, // Ensure color is applied correctly
              ),
            ),
          ),

          if (_isExpanded)
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                "أكاديمية إتقان",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  letterSpacing: 0.5,
                ),
              ),
            ),

          const SizedBox(height: 50),

          // 🔹 Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 10),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: S.of(context).home,
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.auto_stories_rounded,
                  label: S.of(context).delivery,
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.school_rounded,
                  label: S.of(context).courses,
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.quiz_rounded,
                  label: S.of(context).tests,
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.account_circle_rounded,
                  label: S.of(context).myAccount,
                  index: 4,
                ),
              ],
            ),
          ),

          // 🔹 User Profile Summary (Instant Sync)
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              String name = "User";
              String url = "";
              if (state is ProfileSuccess) {
                name = state.profileModel.name ?? "User";
                url = state.profileModel.url ?? "";
              }

              return InkWell(
                onTap: () => widget.onItemTapped(4), // Go to profile
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border:
                        const Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    mainAxisAlignment: _isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.accent,
                        backgroundImage:
                            url.isNotEmpty ? NetworkImage(url) : null,
                        child: url.isEmpty
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                S.of(context).profile,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          // 🔹 Toggle Button / Footer
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded
                  ? Icons.keyboard_double_arrow_left_rounded
                  : Icons.keyboard_double_arrow_right_rounded,
              color: Colors.white54,
              size: 22,
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          mouseCursor: SystemMouseCursors.click, // 🖱️ Click Cursor
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 14), // 📏 Reduced to fix overflow
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.accent.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                // Icon with smooth active color transition
                Icon(
                  icon,
                  color: isSelected ? AppColors.accent : Colors.white70,
                  size: 24,
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
