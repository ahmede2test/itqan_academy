import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:itqan_academy/generated/l10n.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // الـ Stream يظل كما هو لجلب البيانات
  final _notesStream = Supabase.instance.client
      .from('academy_news')
      .stream(primaryKey: ['id']).order('created_at', ascending: false);

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          S.of(context).notifications_title,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Cairo', fontSize: 18),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
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
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: const Icon(Icons.notifications_active,
              color: Colors.blueAccent, size: 20),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Cairo'),
        ),
        subtitle: Text(
          item['content'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
        ),
        trailing: Text(
          timeAgo,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ),
    );
  }
}
