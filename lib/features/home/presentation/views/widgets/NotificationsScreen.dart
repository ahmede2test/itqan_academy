import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // الـ Stream يظل كما هو لجلب البيانات

  @override
  void initState() {
    super.initState();
    _setupForegroundNotifications();
  }

  void _setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification!.title}",
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            backgroundColor: Colors.blueAccent.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            width: 200,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        );
      }
    });
  }

  // ✅ الدالة الجديدة: الحذف محلياً فقط
  void _handleDeleteLocally(String notificationId) async {
    // جلب القائمة الحالية من الـ SharedPreferences عبر CashHelper
    // لاحظ: استخدمنا getStringList مباشرة من الـ sharedPreference الموجود في الـ CashHelper
    List<String> deletedIds =
        CashHelper.sharedPreference.getStringList('deleted_news_ids') ?? [];

    if (!deletedIds.contains(notificationId)) {
      deletedIds.add(notificationId);

      // حفظ القائمة المحدثة
      await CashHelper.setData('deleted_news_ids', deletedIds);

      // تحديث الواجهة لإخفاء العنصر المحذوف
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          S.of(context).notifications_title,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Cairo', fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client
            .from('academy_news')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "حدث خطأ أثناء تحميل الإشعارات",
                style: TextStyle(color: Colors.red[400], fontFamily: 'Cairo'),
              ),
            );
          }

          // 1. جلب قائمة الـ IDs الممسوحة محلياً
          List<String> deletedIds =
              CashHelper.sharedPreference.getStringList('deleted_news_ids') ??
                  [];

          // 2. فلترة البيانات القادمة من السيرفر (استبعاد المحذوف محلياً)
          final notifications = snapshot.data?.where((item) {
                return !deletedIds.contains(item['id'].toString());
              }).toList() ??
              [];

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "لا توجد إشعارات حالياً",
                style: TextStyle(color: Colors.grey[600], fontFamily: 'Cairo'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];

              return Dismissible(
                key: Key(item['id'].toString()),
                direction: DismissDirection.endToStart,
                // ✅ استدعاء الحذف المحلي عند السحب
                onDismissed: (direction) =>
                    _handleDeleteLocally(item['id'].toString()),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.delete_sweep,
                      color: Colors.white, size: 30),
                ),
                child: _buildNotificationCard(item),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final DateTime createdAt = DateTime.parse(item['created_at']);
    final String timeAgo = DateFormat('hh:mm a').format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.notifications_active,
              color: AppColors.primary, size: 20),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Cairo'),
        ),
        subtitle: Text(
          item['content'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.grey[600], fontSize: 12, fontFamily: 'Cairo'),
        ),
        trailing: Text(
          timeAgo,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ),
    );
  }
}
