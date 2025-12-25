import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';
import 'package:itqan_academy/features/login/presentation/views/login_screen.dart';
import 'package:itqan_academy/generated/l10n.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  Future<void> deleteAccount(BuildContext context) async {
    final token = CashHelper.getData('token');

    try {
      final response = await Dio().delete(
        'https://apps.qb-academy.com/wp-json/custom-api/v1/delete-account', // ← حط رابط الـ API الفعلي هنا
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        customShowToast(msg: S.of(context).deleteSuccess);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        customShowToast(msg: S.of(context).deleteFailed);
      }
    } catch (e) {
      customShowToast(msg: "${S.of(context).serverError}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).accountManagement,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.redAccent),
            title: Text(
              S.of(context).deleteAccount,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              S.of(context).deleteWarning,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    S.of(context).confirmDelete,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  content: Text(
                    S.of(context).deleteQuestion,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(S.of(context).cancel, style: const TextStyle(fontFamily: 'Cairo')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(S.of(context).yesDelete, style: const TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await deleteAccount(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
