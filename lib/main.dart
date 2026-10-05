import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'services/category_service.dart';
import 'services/enrollment_service.dart';
import 'services/lesson_service.dart';
import 'services/progress_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OnlineCoursePlatformApp());
}

class OnlineCoursePlatformApp extends StatelessWidget {
  const OnlineCoursePlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CourseService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
        ChangeNotifierProvider(create: (_) => EnrollmentService()),
        ChangeNotifierProvider(create: (_) => LessonService()),
        ChangeNotifierProvider(create: (_) => ProgressService()),
        Provider(create: (_) => StorageService()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'EduPlatform',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.router(context.read<AuthService>()),
          );
        },
      ),
    );
  }
}
