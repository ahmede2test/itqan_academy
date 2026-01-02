import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImagePicker extends StatefulWidget {
  final ImageProvider image;
  final String serverImage;
  final Function(String) onImageSelected;

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
  bool _loading = false;
  XFile? _pickedFile;
  Uint8List? _webImageData;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
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

    if (source == null) return;

    setState(() => _loading = true);

    try {
      final xFile = await picker.pickImage(source: source, imageQuality: 70);

      if (xFile != null) {
        // Set local preview immediately
        final bytes = await xFile.readAsBytes();
        setState(() {
          _pickedFile = xFile;
          _webImageData = bytes;
        });

        // Upload image & update DB/Auth
        String? newImageUrl = await uploadImage(xFile);

        if (newImageUrl != null && mounted) {
          customShowToast(msg: S.of(context).uploadSuccess);
          widget.onImageSelected(newImageUrl);
        } else if (mounted) {
          customShowToast(msg: S.of(context).uploadFailed);
          setState(() {
            _pickedFile = null;
            _webImageData = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Image Pick/Upload Error: $e");
      if (mounted) customShowToast(msg: S.of(context).uploadFailed);
      setState(() {
        _pickedFile = null;
        _webImageData = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> uploadImage(XFile imageFile) async {
    final String? currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return null;

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path =
        '$currentUserId/$fileName'; // 📂 Path MUST start with UserId for RLS
    const String bucketName = 'avatars';

    try {
      final bytes = await imageFile.readAsBytes();

      await supabase.storage.from(bucketName).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final String publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('General Upload Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider finalImageProvider;

    if (_pickedFile != null && _webImageData != null) {
      finalImageProvider = MemoryImage(_webImageData!);
    } else {
      finalImageProvider = widget.image;
    }

    return GestureDetector(
      onTap: _loading ? null : _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            key: ValueKey(widget.serverImage),
            radius: 55,
            backgroundColor: Colors.black,
            backgroundImage: finalImageProvider,
            onBackgroundImageError: (_, __) => const Icon(Icons.broken_image),
          ),
          Positioned(
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
