import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'dart:async';
import '../../../data/repos/services_repository.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  static const int _defaultTime = 25 * 60;
  int _secondsRemaining = _defaultTime;
  Timer? _timer;
  bool _isRunning = false;
  late final ServicesRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = ServicesRepositoryImpl(Supabase.instance.client);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _completeSession();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _defaultTime;
      _isRunning = false;
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    // Play sound or vibrate here if needed

    // Save session
    try {
      await _repository.logStudySession(25);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session Completed! 25 mins recorded.')),
        );
      }
    } catch (e) {
      // Error logging
    }
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_secondsRemaining / _defaultTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pomodoro",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              ),
              Text(
                _timerString,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'play_pause',
                onPressed: _toggleTimer,
                backgroundColor: _isRunning ? Colors.amber : Colors.redAccent,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: 'reset',
                onPressed: _resetTimer,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.refresh, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Stay Focused for 25 Minutes!",
            style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
          )
        ],
      ),
    );
  }
}
