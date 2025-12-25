import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/profile_image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/core/utils/functions/logout.dart' as app_logout;
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'Contactus.dart';
import 'EditProfileScreen.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'change_language_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 🔑 تم حذف المتغير المؤقت _tempImageUrl والاعتماد على الكيوبت فقط

  void _changeLanguage() {
    showChangeLanguageDialog(context);
  }

  @override
  void initState() {
    super.initState();
    // استدعاء جلب البيانات عند بدء التشغيل
    ProfileCubit.get(context).getProfileData();
  }

  // 🖼️ دالة مساعدة لبناء عنصر القائمة (Profile Tile)
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900], // Dark card background
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFD700)), // Gold Accent
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          customShowToast(msg: state.errMessage);
        }
      },
      builder: (context, state) {
        // 🚀 حالة النجاح: عرض البيانات
        if (state is ProfileSuccess) {
          String avatarUrl = state.profileModel.url ?? '';
          if (avatarUrl.isEmpty) {
            // Fallback if model URL is empty but metadata has it (double check)
            final user = Supabase.instance.client.auth.currentUser;
            avatarUrl = user?.userMetadata?['avatar_url'] ??
                user?.userMetadata?['picture'] ??
                '';
          }

          final String fullName = state.profileModel.name ??
              state.profileModel.firstName ??
              S.of(context).profile;

          return Scaffold(
            backgroundColor: const Color(0xFF121212), // Deep Dark Background
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB71C1C), // Deep Red
                      Color(0xFFEF5350), // Light Red
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                S.of(context).profile,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🌟 Nested BlocBuilder to force rebuild when image URL changes
                      BlocBuilder<ProfileCubit, ProfileState>(
                        buildWhen: (previous, current) {
                          // Only rebuild when URL actually changes
                          if (previous is ProfileSuccess &&
                              current is ProfileSuccess) {
                            return previous.profileModel.url !=
                                current.profileModel.url;
                          }
                          return true;
                        },
                        builder: (context, profileState) {
                          // Extract URL from current state
                          String currentAvatarUrl = '';
                          if (profileState is ProfileSuccess) {
                            currentAvatarUrl =
                                profileState.profileModel.url ?? '';
                            if (currentAvatarUrl.isEmpty) {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              currentAvatarUrl =
                                  user?.userMetadata?['avatar_url'] ??
                                      user?.userMetadata?['picture'] ??
                                      '';
                            }
                          }

                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ProfileImagePicker(
                              key: ValueKey(
                                  currentAvatarUrl), // 🌟 Force rebuild when URL changes
                              image: (currentAvatarUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(currentAvatarUrl)
                                  : const AssetImage(
                                          'assets/images/default_avatar.png')
                                      as ImageProvider<Object>),
                              onImageSelected: (String newUrl) {
                                // Update cubit - this will trigger the BlocBuilder to rebuild
                                ProfileCubit.get(context)
                                    .updateProfileImageUrl(newUrl);
                              },
                              serverImage: currentAvatarUrl,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: Colors.white, // White text
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.profileModel.email ??
                            'البريد الإلكتروني غير متوفر',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),

                      const SizedBox(height: 30),

                      // قائمة الخيارات المحسنة
                      _buildProfileTile(
                        icon: Icons.person_outline_rounded,
                        title: S.of(context).editProfile,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileScreen())),
                      ),
                      const SizedBox(height: 12),
                      _buildProfileTile(
                        icon: Icons.language,
                        title: S.of(context).changeLanguage,
                        onTap: _changeLanguage,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileTile(
                        icon: Icons.mail_outline_rounded,
                        title: S.of(context).contactus,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Contactus())),
                      ),
                      // Removed Delete Account Option

                      const SizedBox(height: 40),

                      /// زر تسجيل الخروج
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () => app_logout.logOut(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[900], // Dark button
                            foregroundColor:
                                const Color(0xFFEF5350), // Red Text
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                                color: Colors.red.withOpacity(0.5), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.logout_rounded,
                              color: Color(0xFFB71C1C)),
                          label: Text(S.of(context).logout),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xFFEF5350)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(S.of(context).profile,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[900]!,
                        highlightColor: Colors.grey[800]!,
                        child: CircleAvatar(
                            radius: 60, backgroundColor: Colors.grey[900]),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[900]!,
                            highlightColor: Colors.grey[800]!,
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        itemCount: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
