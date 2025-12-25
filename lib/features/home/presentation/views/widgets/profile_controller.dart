import 'package:flutter/foundation.dart'; // 🚀 ADDED for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// 🛑 تم إزالة shared_preferences لأنه لم يعد مطلوباً
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:itqan_academy/generated/l10n.dart';

class ProfileController {
  // 🛑 تم إزالة ثابت _imageKey

  /// ✅ اختيار ورفع الصورة
  Future<XFile?> pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return null;

    if (kIsWeb) {
      // On Web, we return the XFile directly as file paths don't exist in the same way.
      return pickedFile;
    }

    // Mobile specific: Save to app directory (Optional, depends on use case)
    // Here we maintain the existing Android logic.
    return pickedFile;
  }

  /// ✅ حوار اختيار مصدر الصورة (بالعربي والإنجليزي)
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).chooseImageSource,
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: Text(S.of(context).camera,
                style: const TextStyle(fontFamily: 'Cairo')),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: Text(S.of(context).gallery,
                style: const TextStyle(fontFamily: 'Cairo')),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
