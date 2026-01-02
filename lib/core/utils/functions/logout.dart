import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

Future<void> logOut(BuildContext context) async {
  await AuthService.logout(context);
}
