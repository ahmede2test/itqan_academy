import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:itqan_academy/features/login/presentation/views/login_screen.dart';
import 'package:itqan_academy/features/home/presentation/views/home_screen_view.dart';
import 'package:itqan_academy/core/services/notification_service.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:itqan_academy/firebase_options.dart';
import 'package:itqan_academy/core/utils/constants.dart';

// Top-level Background Handler (Keep it here for engine entry point)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _safeInit();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _safeInit() async {
    // Start initializations in background
    _initializeApp();

    // Navigate immediately after a minimum display time
    if (mounted) _navigateToNextScreen();
  }

  Future<void> _initializeApp() async {
    // Non-blocking concurrent initialization
    Future.wait([
      if (Firebase.apps.isEmpty)
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      CashHelper.init(),
      Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions:
            const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
      ),
      NotificationService.instance.init(),
    ]).then((_) {
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
      _setupDeepLinks(Supabase.instance.client);
    });
  }

  void _setupDeepLinks(SupabaseClient supabase) {
    if (kIsWeb) return;

    // 1. Handle Deep Links (for OAuth redirects)
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) async {
      if (uri.scheme == 'itqan' && uri.host == 'login-callback') {
        try {
          await supabase.auth.getSessionFromUrl(uri);
        } catch (e) {
          // Silent fail for performance
        }
      }
    });

    // 2. Listen to Auth State Changes
    // This handles immediate navigation if the user signs in via OAuth/DeepLink
    supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  void _navigateToNextScreen() {
    // Minimum splash duration for branding
    Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;
      final bool isLoggedIn = CashHelper.getData('isLoggedIn') ?? false;

      final Widget nextScreen = (session != null || isLoggedIn)
          ? const MainScreen()
          : const LoginScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/itqan_logo.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "إتقان أكاديمي",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color(0xFF001F3F), // Matching dark blue for contrast
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Itqan Academy",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.black54,
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
