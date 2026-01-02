import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:itqan_academy/core/services/notification_service.dart';
import 'package:itqan_academy/features/home/presentation/manger/profile_cubit/peofile_cubit.dart';
import 'package:itqan_academy/features/login/presentation/manger/login_cubit.dart';

import 'package:google_fonts/google_fonts.dart';

import 'core/utils/locale_cubit.dart';
import 'features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'features/courses/data/repos/courses_repository.dart';
import 'features/home/presentation/views/home_screen_view.dart';
import 'features/home/presentation/manger/post_cubit/post_cubit.dart';
import 'features/courses/presentation/manger/course_progress_cubit/course_progress_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/utils/app_colors.dart'; // 🚀 Added for Brand Colors
import 'features/home/data/repos/exams_repository.dart';
import 'features/home/presentation/manger/exams_cubit/exams_cubit.dart';
import 'features/login/presentation/views/login_screen.dart';
import 'features/home/data/repos/services_repository.dart';
import 'features/home/presentation/manger/services_cubit/services_cubit.dart';

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
  GoogleFonts.config.allowRuntimeFetching = false;
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
          create: (_) => CourseCubit(
            CoursesRepositoryImpl(Supabase.instance.client),
          )..getCoursesIntroduction(),
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
        BlocProvider<ServicesCubit>(
          create: (_) => ServicesCubit(
            ServicesRepositoryImpl(Supabase.instance.client),
          ),
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
              scaffoldBackgroundColor: AppColors.background,
              primaryColor: AppColors.primary,
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppColors.primary,
                secondary: AppColors.accent,
                surface: AppColors.background,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                centerTitle: true,
                elevation: 0,
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo'),
              ),
              // 🔠 SaaS Typography Hierarchy
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
                headlineMedium: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
                titleMedium: TextStyle(
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                bodyLarge: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              // 🔘 SaaS Standardized Buttons
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.1);
                      }
                      return null;
                    },
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 🎨 Global Icon Theme
              iconTheme: const IconThemeData(
                color: AppColors.primary,
                size: 24,
              ),
              // 📝 Global Input Decoration
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
                labelStyle: const TextStyle(
                    fontFamily: 'Cairo', color: AppColors.primary),
                hintStyle: TextStyle(
                    fontFamily: 'Cairo', color: Colors.grey.withOpacity(0.6)),
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const MainScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
