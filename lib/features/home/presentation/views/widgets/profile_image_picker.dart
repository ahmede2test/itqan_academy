// 2. ProfileImagePicker.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 🚀 ADDED for XFile
import 'package:path/path.dart' show basename;
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/features/home/presentation/views/widgets/profile_controller.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImagePicker extends StatefulWidget {
  final ImageProvider
      image; // 🔑 هذا هو مصدر الصورة الذي يأتي من الكيوبت (أو مؤقتاً من FileImage)
  final String serverImage;
  final Function(String) onImageSelected; // لتمرير الـ URL الجديد للصفحة الأب

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onImageSelected,
    required this.serverImage,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ProfileController _controller = ProfileController();

  // ❌ تم حذف _currentImage والاعتماد على widget.image
  bool _loading = false;
  XFile? _pickedFile; // 💡 Use XFile for platform compatibility
  Uint8List? _webImageData; // 💡 For web preview

  @override
  void initState() {
    super.initState();
    // ❌ تم حذف تعيين _currentImage
  }

  Future<void> _pickImage() async {
    setState(() => _loading = true);

    final xFile = await _controller.pickAndUploadImage(context);

    if (!mounted) return;

    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _pickedFile = xFile;
        _webImageData = bytes;
      });

      // 🔑 استدعاء دالة الرفع واستقبال الـ URL الجديد
      String? newImageUrl = await uploadImage(xFile);

      if (newImageUrl != null) {
        customShowToast(msg: S.of(context).uploadSuccess);
        widget.onImageSelected(newImageUrl);
      } else {
        customShowToast(msg: S.of(context).uploadFailed);
      }

      setState(() {
        _pickedFile = null;
        _webImageData = null;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // 🔑 دالة الرفع تبقى كما هي
  Future<String?> uploadImage(XFile imageFile) async {
    final String? currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return null;

    final String fileName = 'profile_$currentUserId.jpg';
    const String bucketName = 'avatars';

    try {
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await supabase.storage.from(bucketName).uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );
      } else {
        // MOBILE & OTHERS - 🚀 Use readAsBytes for platform-agnostic upload
        final bytes = await imageFile.readAsBytes();
        await supabase.storage.from(bucketName).uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );
      }

      final String publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      final response = await supabase
          .from('user_profiles')
          .update({'url': publicUrl})
          .eq('id', currentUserId)
          .select();

      if (response != null && response is List && response.isNotEmpty) {
        return publicUrl;
      } else {
        print('Supabase Update failed or returned empty response.');
        return null;
      }
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      print('General Upload Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 مصدر الصورة الموحدة
    ImageProvider finalImageProvider;

    if (_pickedFile != null) {
      if (kIsWeb && _webImageData != null) {
        finalImageProvider = MemoryImage(_webImageData!);
      } else {
        // If we don't have bytes yet, we could read them, but simpler to rely on MemoryImage
        // Since _pickImage now sets _webImageData on all platforms
        finalImageProvider = MemoryImage(_webImageData!);
      }
    } else {
      finalImageProvider = widget.image;
    }

    // 💡 ملاحظة: يجب أن يضمن الـ widget.image القادم من الـ ProfilePage
    // أنه يحتوي على رابط الصورة الجديد فور تحديث الكيوبت.

    return GestureDetector(
      onTap: _loading ? null : _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            key: ValueKey(widget
                .serverImage), // 🌟 Force repaint when server image changes
            radius: 55,
            backgroundColor: Colors.black,
            backgroundImage: finalImageProvider, // استخدام مصدر الصورة الموحد
            onBackgroundImageError: (_, __) => const Icon(Icons.broken_image),
          ),
          Positioned(
            // ... (بقية أيقونة الكاميرا والـ Loading Indicator)
            bottom: 0,
            right: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
