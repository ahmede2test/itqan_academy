import 'package:flutter/material.dart';

import '../../../features/login/presentation/views/login_screen.dart';
import '../cash_helper.dart';

void logOut(BuildContext context) {
  CashHelper.removeData('token');
  CashHelper.removeData('name');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
        (route) => false,
  );
}