class AppConstants {
  AppConstants._();

  // Firestore collections
  static const String usersCol = 'users';
  static const String coursesCol = 'courses';
  static const String lessonsCol = 'lessons';
  static const String categoriesCol = 'categories';
  static const String enrollmentsCol = 'enrollments';
  static const String progressCol = 'progress';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // Course levels
  static const List<String> courseLevels = ['Beginner', 'Intermediate', 'Advanced'];

  // Storage paths
  static const String thumbnailsPath = 'thumbnails';
  static const String profileImagesPath = 'profile_images';
  static const String coursesStoragePath = 'courses';

  // Pagination
  static const int pageSize = 20;
  static const int dashboardRecentCount = 6;

  // Demo categories
  static const List<String> defaultCategories = [
    'Programming',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Artificial Intelligence',
    'UI/UX Design',
    'Cloud Computing',
    'Cyber Security',
    'Business',
    'Marketing',
  ];

  // Demo admin email (for first-run seeding)
  static const String adminEmail = 'admin@eduplatform.com';

  // Image constraints
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
