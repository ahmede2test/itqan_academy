import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  String? _userEmail;
  bool _isAdmin = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    setState(() => _isChecking = true);
    final user = Supabase.instance.client.auth.currentUser;
    _userEmail = user?.email;
    _isAdmin = _userEmail == 'ahmed.osmanis.fcai@gmail.com';

    // Force a refresh of the ProfileCubit to ensure the navbar sees the update
    if (_isAdmin) {
      await context.read<ProfileCubit>().getProfileData();
    }

    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isAdmin
                  ? Colors.green.withOpacity(0.5)
                  : Colors.red.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isAdmin ? Colors.green : Colors.red).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAdmin ? Icons.verified_user : Icons.gpp_bad,
                size: 80,
                color: _isAdmin ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _isChecking
                    ? 'Verifying Admin Status...'
                    : (_isAdmin ? 'Welcome Ahmed' : 'Access Denied'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              if (!_isChecking)
                Text(
                  _isAdmin
                      ? 'Admin access granted. You can now access the full dashboard.'
                      : 'Your email [$_userEmail] is not authorized for admin tasks.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              const SizedBox(height: 32),
              if (!_isChecking)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAdmin ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_isAdmin) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      _isAdmin ? 'Go to Admin Dashboard' : 'Back to Safety',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_isChecking)
                const CircularProgressIndicator(color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
