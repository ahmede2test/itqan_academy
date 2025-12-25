import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // 🚀 ADDED for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:itqan_academy/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/top_notification_banner.dart';

// Top-level Background Handler
// Note: It is best practice to define this in main.dart or ensure it is a top-level function.
// We will export it here so main.dart can reference it if needed, or define it there.
// For now, we keep it here to be referenced in init if main.dart doesn't override.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  // Navigation Key (Global Access)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 🚀 Lazy-load FirebaseMessaging to prevent Web crashes
  FirebaseMessaging? _messaging;
  FirebaseMessaging get messaging {
    if (kIsWeb) {
      throw UnsupportedError('FirebaseMessaging is not supported on Web');
    }
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Subscription to Auth Changes
  StreamSubscription<AuthState>? _authSubscription;
  bool _isInitialized = false;

  // Notification Channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  /// Initialize the Notification Service
  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint(
          "Notifications: Web platform detected. Skipping mobile setup.");
      _isInitialized = true;
      return;
    }

    // 1. Request Permissions (Essential for iOS and Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    // ... (rest of the mobile-only init logic)

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Setup Local Notifications (Android/iOS)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create Channel (Android)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Setup Foreground Message Handler (onMessage)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Setup Interacted Message (When app is in background or terminated)
    setupInteractedMessage();

    // 5. Subscribe to global topic
    // 🚀 ACTIVATED: Subscribe to 'all_users' topic for topic-based notifications
    try {
      await messaging.subscribeToTopic("all_users");
      debugPrint("Successfully subscribed to topic: all_users");
    } catch (e) {
      debugPrint("Error subscribing to topic: $e");
    }

    // 6. Token Management - 🚀 NOW AWAITED to ensure token is saved on every launch
    await _setupTokenManagement();

    _isInitialized = true;
    debugPrint("🔔 NotificationService initialized successfully.");
  }

  /// Token Management Logic
  Future<void> _setupTokenManagement() async {
    if (kIsWeb) return;

    // 🚀 Get initial token and save it IMMEDIATELY on every app launch
    String? token = await messaging.getToken();
    if (token != null) {
      debugPrint("FCM Token: $token");
      await _saveTokenToDatabase(token); // 🚀 AWAIT to ensure it's saved
    }

    // Listen to token refresh
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
      _saveTokenToDatabase(newToken);
    });

    // Listen to Auth State Changes to ensure token is saved when user logs in
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        messaging.getToken().then((token) {
          if (token != null) _saveTokenToDatabase(token);
        });
      }
    });
  }

  /// Save FCM Token to Supabase
  /// Note: Uses 'user_profiles' table and 'fcm_token' column
  Future<void> _saveTokenToDatabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('user_profiles')
          .update({'fcm_token': token}).eq('id', user.id);
      debugPrint(
          "FCM Token successfully updated in Supabase for user: ${user.id}");
    } catch (e) {
      debugPrint("Error saving FCM token to Supabase: $e");
    }
  }

  void dispose() {
    _authSubscription?.cancel();
  }

  /// Handle Notification Taps (Navigation Logic)
  void _handleNotificationTap(String? payload) {
    debugPrint('🔔 Notification Tap detected. Opening app...');
    // Simply opening the app is enough as Splash handles initial routing.
    // If specific navigation is needed in the future, it can be added here.
  }

  /// Handle App Opening from Background or Terminated State
  Future<void> setupInteractedMessage() async {
    // 1. Terminated state
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data['type']);
    }

    // 2. Background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['type']);
    });
  }

  /// Handle Foreground Messages (Stylish Banner & Local Notification)
  void _handleForegroundMessage(RemoteMessage message) async {
    if (kIsWeb) return; // 🚀 Web doesn't use this mobile-specific handler

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      // 1. Show Stylish Banner (In-app)
      showForegroundNotificationOverlay(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: null,
      );

      // 2. Also trigger local notification if desired (to show in notification center)
      if (android != null) {
        // 🚀 Check for image URL in notification
        final String? imageUrl = android.imageUrl;

        StyleInformation? styleInformation;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Download image from network and use ByteArrayAndroidBitmap
          try {
            final response = await http.get(Uri.parse(imageUrl));
            if (response.statusCode == 200) {
              final Uint8List imageBytes = response.bodyBytes;
              styleInformation = BigPictureStyleInformation(
                ByteArrayAndroidBitmap(imageBytes),
                contentTitle: notification.title,
                summaryText: notification.body,
                htmlFormatContentTitle: true,
                htmlFormatSummaryText: true,
              );
            } else {
              debugPrint('⚠️ Failed to download image: ${response.statusCode}');
            }
          } catch (e) {
            debugPrint('⚠️ Error downloading notification image: $e');
          }
        }

        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              styleInformation: styleInformation, // 🚀 Apply image style
            ),
          ),
          payload: null,
        );
      }
    }
  }

  /// Show Stylish Custom Overlay Banner
  void showForegroundNotificationOverlay({
    required String title,
    required String body,
    String? payload,
  }) {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopNotificationBanner(
        title: title,
        body: body,
        onTap: () {
          overlayEntry.remove();
          _handleNotificationTap(payload);
        },
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
