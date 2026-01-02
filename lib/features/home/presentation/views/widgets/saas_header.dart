import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'package:itqan_academy/core/services/auth_service.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'NotificationsScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SaaSHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const SaaSHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🎓 Academy Logo (Web)
          Image.asset(
            'assets/images/itqan_logo.png',
            height: 35,
          ),
          const SizedBox(width: 12),
          const Text(
            'Itqan Academy',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const Spacer(),

          const SizedBox(width: 8),

          // 🔔 Notification System (Simplified)
          IconButton(
            tooltip: s.notifications_title,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
          ),

          const SizedBox(width: 12),

          // Profile Dropdown
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              String avatarUrl = '';
              if (state is ProfileSuccess) {
                avatarUrl = state.profileModel.url ?? '';
              }

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await AuthService.logout(context);
                    } else if (value == 'profile') {
                      onProfileTap?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              size: 20, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(s.logout,
                              style: const TextStyle(
                                  fontFamily: 'Cairo', color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.5),
                              width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? CachedNetworkImageProvider(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
