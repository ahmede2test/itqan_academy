import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/cash_helper.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔒 Global Logout Function
  static Future<void> logout(BuildContext context) async {
    try {
      // 1. Clear Supabase Session
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Supabase SignOut Error: $e");
    }

    // 2. Clear Local Data
    await CashHelper.removeData('token');
    await CashHelper.removeData('isLoggedIn');
    await CashHelper.removeData('name');
    // Add any other user data keys if they exist

    // 3. Navigate to Login immediately
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
