import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_cubit.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isFirstCheck = true;
  bool _wasOffline = false;

  void init(BuildContext context) {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleStatusChange(context, results);
    });
  }

  void _handleStatusChange(
      BuildContext context, List<ConnectivityResult> results) {
    final bool isOffline = results.every((r) => r == ConnectivityResult.none);

    if (_isFirstCheck) {
      _isFirstCheck = false;
      if (isOffline) _wasOffline = true;
      return;
    }

    if (isOffline) {
      _wasOffline = true;
      _showNoInternetSnackBar(context);
    } else if (_wasOffline) {
      _wasOffline = false;
      _hideSnackBar(context);
      _showRestoredSnackBar(context);
      context.read<CourseCubit>().getCoursesIntroduction();
    }
  }

  void _showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(days: 365), // Persistent
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: 80, left: 20, right: 20), // 🚀 Floating above BNB
      ),
    );
  }

  void _showRestoredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم استعادة الاتصال بالإنترنت.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  void _hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
