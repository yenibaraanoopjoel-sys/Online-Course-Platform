import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/student/student_shell.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/course_browser_screen.dart';
import '../screens/student/course_details_screen.dart';
import '../screens/student/my_courses_screen.dart';
import '../screens/student/learning_screen.dart';
import '../screens/student/profile_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/courses/course_management_screen.dart';
import '../screens/admin/courses/add_course_screen.dart';
import '../screens/admin/courses/edit_course_screen.dart';
import '../screens/admin/courses/course_details_admin_screen.dart';
import '../screens/admin/lessons/lesson_management_screen.dart';
import '../screens/admin/lessons/add_lesson_screen.dart';
import '../screens/admin/lessons/edit_lesson_screen.dart';
import '../screens/admin/categories/category_management_screen.dart';
import '../screens/admin/categories/add_category_screen.dart';
import '../screens/admin/categories/edit_category_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Student
  static const String studentDashboard = '/student';
  static const String browse = '/student/browse';
  static const String courseDetails = '/student/course/:courseId';
  static const String myCourses = '/student/my-courses';
  static const String learning = '/student/learn/:courseId';
  static const String studentProfile = '/student/profile';

  // Admin
  static const String adminDashboard = '/admin';
  static const String courseManagement = '/admin/courses';
  static const String addCourse = '/admin/courses/add';
  static const String editCourse = '/admin/courses/edit/:courseId';
  static const String courseDetailsAdmin = '/admin/courses/:courseId';
  static const String lessonManagement = '/admin/courses/:courseId/lessons';
  static const String addLesson = '/admin/courses/:courseId/lessons/add';
  static const String editLesson = '/admin/courses/:courseId/lessons/edit/:lessonId';
  static const String categoryManagement = '/admin/categories';
  static const String addCategory = '/admin/categories/add';
  static const String editCategory = '/admin/categories/edit/:categoryId';

  static GoRouter router(AuthService authService) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: authService,
      redirect: (context, state) {
        final isLoggedIn = authService.isLoggedIn;
        final isAdmin = authService.isAdmin;
        final loc = state.matchedLocation;

        // Let splash handle initial routing
        if (loc == '/') return null;

        // Not logged in → redirect to login
        if (!isLoggedIn &&
            loc != login &&
            loc != register) {
          return login;
        }

        // Already logged in → redirect away from auth screens
        if (isLoggedIn && (loc == login || loc == register)) {
          return isAdmin ? adminDashboard : studentDashboard;
        }

        // Student trying to access admin routes
        if (isLoggedIn && !isAdmin && loc.startsWith('/admin')) {
          return studentDashboard;
        }

        // Admin trying to access student routes
        if (isLoggedIn && isAdmin && loc.startsWith('/student')) {
          return adminDashboard;
        }

        return null;
      },
      routes: [
        GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: login, builder: (_, __) => const LoginScreen()),
        GoRoute(path: register, builder: (_, __) => const RegisterScreen()),

        // ── Student Shell ────────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => StudentShell(child: child),
          routes: [
            GoRoute(path: studentDashboard, builder: (_, __) => const StudentDashboard()),
            GoRoute(path: browse, builder: (_, __) => const CourseBrowserScreen()),
            GoRoute(path: myCourses, builder: (_, __) => const MyCoursesScreen()),
            GoRoute(path: studentProfile, builder: (_, __) => const ProfileScreen()),
            GoRoute(
              path: courseDetails,
              builder: (_, state) =>
                  CourseDetailsScreen(courseId: state.pathParameters['courseId']!),
            ),
            GoRoute(
              path: learning,
              builder: (_, state) =>
                  LearningScreen(courseId: state.pathParameters['courseId']!),
            ),
          ],
        ),

        // ── Admin Shell ──────────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: adminDashboard, builder: (_, __) => const AdminDashboard()),
            GoRoute(path: courseManagement, builder: (_, __) => const CourseManagementScreen()),
            GoRoute(path: addCourse, builder: (_, __) => const AddCourseScreen()),
            GoRoute(
              path: editCourse,
              builder: (_, state) =>
                  EditCourseScreen(courseId: state.pathParameters['courseId']!),
            ),
            GoRoute(
              path: courseDetailsAdmin,
              builder: (_, state) =>
                  CourseDetailsAdminScreen(courseId: state.pathParameters['courseId']!),
            ),
            GoRoute(
              path: lessonManagement,
              builder: (_, state) =>
                  LessonManagementScreen(courseId: state.pathParameters['courseId']!),
            ),
            GoRoute(
              path: addLesson,
              builder: (_, state) =>
                  AddLessonScreen(courseId: state.pathParameters['courseId']!),
            ),
            GoRoute(
              path: editLesson,
              builder: (_, state) => EditLessonScreen(
                courseId: state.pathParameters['courseId']!,
                lessonId: state.pathParameters['lessonId']!,
              ),
            ),
            GoRoute(path: categoryManagement, builder: (_, __) => const CategoryManagementScreen()),
            GoRoute(path: addCategory, builder: (_, __) => const AddCategoryScreen()),
            GoRoute(
              path: editCategory,
              builder: (_, state) =>
                  EditCategoryScreen(categoryId: state.pathParameters['categoryId']!),
            ),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.error}'),
            ],
          ),
        ),
      ),
    );
  }
}
