import 'dart:ui'; // for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class WebTopNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WebTopNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 🌟 Glass effect
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color:
                const Color(0xFF121212).withOpacity(0.8), // 🌟 Semi-transparent
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            // 🌟 Center content on wide screens
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200, // 🌟 Max width constraint
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 🌟 AGGRESSIVE BREAKPOINTS for zero overflow
                  final double screenWidth = constraints.maxWidth;
                  final bool hideNavText =
                      screenWidth < 1050; // More aggressive
                  final bool hideLogoText = screenWidth < 750;
                  final double horizontalPadding = screenWidth < 750 ? 8 : 16;

                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 80, // 🌟 Lock navbar height
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 🎓 Academy Logo
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/itqan_logo.png',
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                                if (!hideLogoText) ...[
                                  const SizedBox(width: 12),
                                  const Flexible(
                                    child: Text(
                                      'Itqan Academy',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 🔗 Navigation Links with ZERO OVERFLOW POLICY
                          Flexible(
                            flex: 5,
                            fit: FlexFit.tight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _AnimatedNavLink(
                                    label: S.of(context).home,
                                    icon: Icons.home_rounded,
                                    index: 0,
                                    isSelected: selectedIndex == 0,
                                    onTap: () => onItemTapped(0),
                                    hideText: hideNavText,
                                  ),
                                  const SizedBox(width: 12),
                                  _AnimatedNavLink(
                                    label: S.of(context).courses,
                                    icon: Icons.book_rounded,
                                    index: 2,
                                    isSelected: selectedIndex == 2,
                                    onTap: () => onItemTapped(2),
                                    hideText: hideNavText,
                                  ),
                                  const SizedBox(width: 12),
                                  _AnimatedNavLink(
                                    label: S.of(context).tests,
                                    icon: Icons.schedule_rounded,
                                    index: 3,
                                    isSelected: selectedIndex == 3,
                                    onTap: () => onItemTapped(3),
                                    hideText: hideNavText,
                                  ),
                                  const SizedBox(width: 12),
                                  _AnimatedNavLink(
                                    label: S.of(context).myAccount,
                                    icon: Icons.person_rounded,
                                    index: 4,
                                    isSelected: selectedIndex == 4,
                                    onTap: () => onItemTapped(4),
                                    hideText: hideNavText,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 🌐 User Avatar with glow (Dynamic with ProfileCubit)
                          BlocBuilder<ProfileCubit, ProfileState>(
                            builder: (context, state) {
                              String avatarUrl = '';
                              if (state is ProfileSuccess) {
                                avatarUrl = state.profileModel.url ?? '';
                              }

                              return GestureDetector(
                                onTap: () =>
                                    onItemTapped(4), // Navigate to profile
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[800]!,
                                        Colors.grey[900]!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: avatarUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            key: ValueKey(
                                                avatarUrl), // 🌟 Force refresh
                                            imageUrl: avatarUrl,
                                            fit: BoxFit.cover,
                                            width: 45,
                                            height: 45,
                                            placeholder: (_, __) => const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const Icon(
                                              Icons
                                                  .school_rounded, // 🌟 Branded Icon fallback
                                              color: AppColors.accent,
                                              size: 24,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🌟 NEW: Animated Navigation Link with Hover Effect
class _AnimatedNavLink extends StatefulWidget {
  final String label;
  final IconData icon;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hideText;

  const _AnimatedNavLink({
    required this.label,
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.hideText = false,
  });

  @override
  State<_AnimatedNavLink> createState() => _AnimatedNavLinkState();
}

class _AnimatedNavLinkState extends State<_AnimatedNavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.red.withOpacity(0.15)
                : _isHovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: Colors.red, width: 2)
                : _isHovered
                    ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? Colors.red
                    : _isHovered
                        ? Colors.white
                        : Colors.white70,
                size: 20,
              ),
              if (!widget.hideText) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white
                        : _isHovered
                            ? Colors.white
                            : Colors.white70,
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.bold : FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
