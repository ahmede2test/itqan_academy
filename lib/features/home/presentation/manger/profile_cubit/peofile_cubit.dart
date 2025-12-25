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

    emit(ProfileLoading());
    try {
      final User? currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        emit(ProfileError('User is not logged in.'));
        return;
      }

      // جلب بيانات الملف الشخصي من جدول 'user_profiles'
      final Map<String, dynamic> response = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name, avatar_url')
          .eq('id', currentUser.id) // 🎯 التأكيد: استخدام 'id'
          .single();

      // 🔄 إنشاء النموذج من الاستجابة
      ProfileModel profileModel = ProfileModel.fromJson(response);

      emit(ProfileSuccess(profileModel));
    } on PostgrestException catch (e) {
      emit(ProfileError('Database Error: ${e.message}'));
    } catch (e) {
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

      // 🛠️ تحديث الاسم في جدول user_profiles
      await Supabase.instance.client
          .from('user_profiles')
          .update({'full_name': newFullName}).eq(
              'id', user.id); // 🎯 التأكيد: استخدام 'id'

      // 🔄 تحديث الحالة محلياً باستخدام copyWith
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
      throw Exception('Name update failed: ${e.toString()}');
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

      // 🛠️ تحديث رابط الصورة في جدول user_profiles
      await Supabase.instance.client.from('user_profiles').update(
          {'avatar_url': newUrl}).eq('id', user.id); // 🎯 التأكيد: استخدام 'id'

      // 🔄 تحديث الحالة محلياً باستخدام copyWith
      if (state is ProfileSuccess) {
        final currentState = state as ProfileSuccess;
        final updatedProfile = currentState.profileModel.copyWith(
          url: newUrl,
          // يجب أن يكون AvatarUrls متاحاً
          avatarUrls: AvatarUrls(
              s96: newUrl), // تأكد من أن AvatarUrls هو كلاس فرعي معرف
        );
        emit(ProfileSuccess(updatedProfile));
      }
    } on PostgrestException catch (e) {
      throw Exception('Image URL update failed: ${e.message}');
    } catch (e) {
      throw Exception('Error updating image URL: ${e.toString()}');
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
      emit(ProfileError('Failed to delete account (DB): ${e.message}'));
    } on AuthException catch (e) {
      emit(ProfileError('Failed to delete account (Auth): ${e.message}'));
    } catch (e) {
      emit(ProfileError(
          'An unexpected error occurred during deletion: ${e.toString()}'));
    }
  }
}
