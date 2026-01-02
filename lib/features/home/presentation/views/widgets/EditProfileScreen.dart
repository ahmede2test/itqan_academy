import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/profile_state.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // 💡 التحميل من الكيوبت بدلاً من Dio
    _loadUserDataFromCubit();
  }

  // 🔄 دالة تحميل بيانات المستخدم من الـ Cubit (التي تحمل البيانات من Supabase)
  void _loadUserDataFromCubit() {
    final cubit = ProfileCubit.get(context);
    // نتحقق من الحالة الحالية لعرض البيانات المحملة
    if (cubit.state is ProfileSuccess) {
      final model = (cubit.state as ProfileSuccess).profileModel;
      // نستخدم firstName و lastName في النموذج
      _firstNameController.text = model.firstName ?? '';
      _lastNameController.text = model.lastName ?? '';
    } else {
      // لو لم يتم تحميل البيانات بعد، نطلبها في حال لم يتم تحميلها بعد
      // (يفترض أنها محملة بالفعل في الـ HomeView)
      cubit.getProfileData();
    }
  }

  Future<void> _saveProfile() async {
    // 1. فحص صحة حقول النموذج
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String newPassword = _passwordController.text;

    // 2. فحص تطابق كلمة السر الجديدة
    if (newPassword.isNotEmpty &&
        newPassword != _confirmPasswordController.text) {
      customShowToast(msg: S.of(context).password_mismatch);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final cubit = ProfileCubit.get(context);
      bool nameUpdated = false;
      bool passwordUpdated = false;

      // 3. تحديث الاسم في Supabase DB باستخدام دالة الكيوبت
      await cubit.updateNameInDB(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      nameUpdated = true;

      // 4. تحديث كلمة السر في Supabase Auth باستخدام دالة الكيوبت
      if (newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          // فحص طول كلمة السر
          customShowToast(msg: S.of(context).passwordShowHint);
          setState(() => _isLoading = false);
          return;
        }
        await cubit.changePassword(newPassword: newPassword);
        passwordUpdated = true;
      }

      // 5. إظهار رسالة النجاح
      if (nameUpdated || passwordUpdated) {
        customShowToast(msg: S.of(context).updateSuccess);
        // مسح حقول كلمة السر بعد النجاح
        _passwordController.clear();
        _confirmPasswordController.clear();
      }

      // 6. العودة إلى الشاشة السابقة (Profile Screen)
      if (mounted) Navigator.pop(context);
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '');
      customShowToast(msg: msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ❌ تم إزالة: دالة changePasswordCustom القديمة المبنية على Dio/Wordpress

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام BlocListener/BlocBuilder لمتابعة حالة التحميل إذا لزم الأمر
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          customShowToast(msg: state.errMessage);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            S.of(context).editProfile,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_firstNameController,
                      label: S.of(context).firstName, required: true),
                  const SizedBox(height: 16),
                  _buildTextField(_lastNameController,
                      label: S.of(context).lastName, required: true),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey), // إضافة خط فاصل
                  const SizedBox(height: 16),
                  // حقل كلمة السر الجديدة
                  _buildTextField(
                    _passwordController,
                    label: S.of(context).newPassword,
                    obscureText: _obscurePassword,
                    required: false, // كلمة السر اختيارية للتحديث
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    _confirmPasswordController,
                    label: S.of(context).confirm_password,
                    obscureText: _obscureConfirmPassword,
                    required: false, // تأكيد كلمة السر اختياري
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              S.of(context).saveChanges,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    bool obscureText = false,
    bool required = true, // تحديد هل الحقل مطلوب أم لا
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.primary, fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.accent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return S.of(context).requiredField;
        }
        // إضافة فحص إضافي لكلمة السر للتأكد من عدم تمرير قيمة قصيرة إذا تم إدخال شيء
        if (controller == _passwordController &&
            value!.isNotEmpty &&
            value.length < 6) {
          return S
              .of(context)
              .passwordShowHint; // (يفترض أن هذه الرسالة تحتوي على متطلبات الطول)
        }
        return null;
      },
    );
  }
}
