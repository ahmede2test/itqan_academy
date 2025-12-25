import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:itqan_academy/core/services/notification_service.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_cubit.dart';

import 'core/utils/locale_cubit.dart';
import 'features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'features/home/presentation/views/home_screen_view.dart';
import 'features/home/presentation/manger/post_cubit/post_cubit.dart';
import 'features/courses/presentation/manger/course_progress_cubit/course_progress_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/utils/cash_helper.dart'; // 🚀 Added for initialization
import 'core/utils/constants.dart'; // 🚀 Added for Supabase keys
import 'features/home/data/repos/exams_repository.dart';
import 'features/home/presentation/manger/exams_cubit/exams_cubit.dart';

import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'features/splash/presentation/views/splash_screen.dart';

// Top-level Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1.1 تهيئة Supabase (مهم قبل خدمة الإشعارات)
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions:
        const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  // 1.2 تهيئة CashHelper
  await CashHelper.init();

  // 2. تهيئة خدمة الإشعارات (تشمل الأذونات والاشتراك في المواضيع والقنوات)
  // تم نقل كل المنطق إلى init() لضمان عدم التكرار
  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<CourseCubit>(
          create: (_) => CourseCubit()..getCoursesIntroduction(),
        ),
        BlocProvider<PostCubit>(create: (_) => PostCubit()),
        BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<CourseProgressCubit>(create: (_) => CourseProgressCubit()),
        BlocProvider<ExamsCubit>(
          create: (_) => ExamsCubit(
            ExamsRepositoryImpl(Supabase.instance.client),
          )..getExams(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, local) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            locale: local,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            title: 'Itqan Academy',
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFFF2F2F2),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                centerTitle: true,
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
