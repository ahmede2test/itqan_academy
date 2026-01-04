import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../courses/data/models/PostModel.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          post.title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🗓️ التاريخ
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  post.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[700], // Dark grey for readability
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.featuredImage ?? "",
                  httpHeaders: const {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                    'Accept': 'image/*'
                  },
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/technology_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📰 العنوان
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 50,
              color: AppColors.accent, // Gold accent
              margin: const EdgeInsets.only(bottom: 20),
            ),

            /// 📝 المحتوى المنسق
            Html(
              data: post.content,
              style: {
                "body": Style(
                  fontSize: FontSize(18),
                  color: AppColors.primary, // Dark blue text
                  fontFamily: 'Cairo',
                  textAlign: TextAlign.right,
                  direction: TextDirection.rtl,
                  lineHeight: LineHeight.number(1.6),
                ),
                "p": Style(
                  textAlign: TextAlign.right,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
