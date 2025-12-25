import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 import 'package:itqan_academy/features/login/presentation/views/login_screen.dart'; // 🚪 استبدل بشاشة تسجيل الدخول الفعلية
import 'package:itqan_academy/features/splash/presentation/views/splash_screen.dart';

import '../../../home/presentation/views/home_screen_view.dart';
import '../../../home/presentation/views/widgets/home_screen_view_body.dart'; // ⏳ شاشة التحميل (السبلاش)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && snapshot.data!.session != null) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}