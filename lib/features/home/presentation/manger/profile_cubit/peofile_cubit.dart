import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// 🚀 NEW IMPORT: Supabase for authentication and database calls
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:itqan_academy/features/home/data/model/profile_model.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart'; // 🚀 ADDED

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  // دالة مساعدة للحصول على بيانات ProfileModel الحالية
  ProfileModel get profileModel => (state as ProfileSuccess).profileModel;

  /// 1. جلب بيانات الملف الشخصي من Supabase
  Future<void> getProfileData() async {
    if (state is ProfileLoading) return;

    debugPrint('Fetching profile data...');
    emit(ProfileLoading());
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final User? currentUser = Supabase.instance.client.auth.currentUser;

      if (session == null || currentUser == null) {
        debugPrint('Profile error: Session or User is null.');
        emit(ProfileError('User is not logged in.'));
        return;
      }

      debugPrint('User ID: ${currentUser.id}');

      // جلب بيانات الملف الشخصي من جدول 'user_profiles'
      // 💡 Database only has 'full_name' and 'avatar_url'
      final Map<String, dynamic> response = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name, avatar_url')
          .eq('id', currentUser.id)
          .single();

      debugPrint('Raw Data: $response');

      // 🔄 إنشاء النموذج من الاستجابة
      ProfileModel profileModel = ProfileModel.fromJson(response);
      debugPrint(
          'Profile model created successfully for: ${profileModel.name}');

      emit(ProfileSuccess(profileModel));
    } on PostgrestException catch (e) {
      debugPrint('PostgrestError: ${e.message} (Detail: ${e.details})');
      emit(ProfileError('Database Error: ${e.message}'));
    } catch (e, stackTrace) {
      debugPrint('Unexpected Error in fetching profile: $e');
      debugPrint(stackTrace.toString());
      emit(ProfileError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // #################################################################
  // 2. دالة تحديث الاسم (FirstName & LastName)
  // #################################################################
  Future<void> updateNameInDB({
    required String firstName,
    required String lastName,
  }) async {
    final String newFullName = '$firstName $lastName';

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in.');
      }

      // 1. Update Auth Metadata (for instant sync on some providers/methods)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'full_name': newFullName,
          'name': newFullName,
        }),
      );

      // 2. Update DB Table 'user_profiles'
      await Supabase.instance.client.from('user_profiles').update({
        'full_name': newFullName,
      }).eq('id', user.id);

      // 3. Update local state
      if (state is ProfileSuccess) {
        final currentState = state as ProfileSuccess;
        final updatedProfile = currentState.profileModel.copyWith(
          name: newFullName,
          firstName: firstName,
          lastName: lastName,
        );
        emit(ProfileSuccess(updatedProfile));
      }
    } on PostgrestException catch (e) {
      throw Exception('Database update failed: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // #################################################################
  // 3. دالة تغيير كلمة السر
  // #################################################################
  Future<void> changePassword({required String newPassword}) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Password change failed: ${e.message}');
    } catch (e) {
      throw Exception('General error changing password');
    }
  }

  // #################################################################
  // 4. دالة تحديث رابط الصورة الشخصية
  // #################################################################
  Future<void> updateProfileImageUrl(String newUrl) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in.');
      }

      // 1. Update Auth Metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'avatar_url': newUrl,
          'picture': newUrl,
        }),
      );

      // 2. Update DB Table
      await Supabase.instance.client
          .from('user_profiles')
          .update({'avatar_url': newUrl}).eq('id', user.id);

      // 3. Update local state
      if (state is ProfileSuccess) {
        final currentState = state as ProfileSuccess;
        final updatedProfile = currentState.profileModel.copyWith(
          url: newUrl,
          avatarUrls: AvatarUrls(s96: newUrl),
        );
        // 🔄 Emit Loading then Success to force rebuild if needed,
        // OR rely on BlocBuilder's buildWhen/key in UI.
        emit(
            ProfileInitial()); // Toggle state to force full tree refresh if key isn't enough
        emit(ProfileSuccess(updatedProfile));
      }
    } on PostgrestException catch (e) {
      throw Exception('Image URL update failed: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // #################################################################
  // 5. دالة حذف الحساب بالكامل
  // #################################################################
  Future<void> deleteAccount() async {
    emit(ProfileLoading());
    try {
      // 💡 لا حاجة لـ refreshSession هنا إلا إذا كنت تشك في انتهاء صلاحية التوكن بشكل متكرر
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(ProfileError('User is not logged in.'));
        return;
      }

      // 1. حذف البيانات من جدول user_profiles
      // هذا هو الطلب الذي كان يعطي خطأ 403. يجب أن يعمل الآن بعد إصلاح RLS لـ id.
      await Supabase.instance.client
          .from('user_profiles')
          .delete()
          .eq('id', user.id); // 🎯 التأكيد: استخدام 'id'

      // 2. تسجيل الخروج لإزالة الجلسة المحلية
      await CashHelper.setData('isLoggedIn', false); // 🚀 ADDED
      await Supabase.instance.client.auth.signOut();

      // 3. إطلاق حالة النجاح
      emit(ProfileDeletedSuccess());
    } on PostgrestException catch (e) {
      emit(ProfileError(e.message));
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
