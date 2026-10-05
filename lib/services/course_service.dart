import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../core/constants/app_constants.dart';

class CourseService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<CourseModel> _courses = [];
  bool _loading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  CourseService() {
    _initStream();
  }

  void _initStream() {
    publishedCoursesStream().listen((list) {
      _courses = list;
      notifyListeners();
    });
  }

  static final List<CourseModel> _defaultSampleCourses = [
    CourseModel(
      courseId: 'sample-course-1',
      title: 'Complete Flutter & Dart Masterclass 2026',
      description: 'Master mobile, web, and desktop development with Flutter 3 and Dart. Build full-stack production apps with Firebase backend, State Management (Provider, Riverpod, Bloc), Clean Architecture, animations, and deployment.',
      shortDescription: 'Build modern iOS, Android, and Web apps with Flutter and Firebase.',
      thumbnail: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
      instructorId: 'admin-demo-id',
      instructorName: 'Sarah Jenkins',
      categoryId: 'mobile-dev',
      categoryName: 'Mobile Development',
      level: 'Beginner',
      duration: 720,
      price: 0.0,
      isPublished: true,
      lessonCount: 4,
      studentCount: 1420,
      rating: 4.9,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    CourseModel(
      courseId: 'sample-course-2',
      title: 'Modern UI/UX Design with Figma & Design Systems',
      description: 'Learn wireframing, interactive prototyping, user research, design tokens, micro-interactions, responsive design grids, and comprehensive design systems for web and mobile.',
      shortDescription: 'From user research to production design systems in Figma.',
      thumbnail: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800',
      instructorId: 'admin-demo-id',
      instructorName: 'Marcus Vance',
      categoryId: 'ui-ux',
      categoryName: 'Design',
      level: 'Intermediate',
      duration: 480,
      price: 29.99,
      isPublished: true,
      lessonCount: 3,
      studentCount: 890,
      rating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    CourseModel(
      courseId: 'sample-course-3',
      title: 'Cloud Architecture & Serverless APIs with Firebase',
      description: 'Deep dive into Cloud Functions, Firestore data modeling, security rules, Firebase Authentication, Cloud Storage, and continuous integration pipelines.',
      shortDescription: 'Scalable cloud infrastructure and realtime databases.',
      thumbnail: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
      instructorId: 'admin-demo-id',
      instructorName: 'Elena Rostova',
      categoryId: 'cloud-backend',
      categoryName: 'Cloud & Backend',
      level: 'Advanced',
      duration: 600,
      price: 49.99,
      isPublished: true,
      lessonCount: 5,
      studentCount: 650,
      rating: 4.95,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  CollectionReference get _col => _db.collection(AppConstants.coursesCol);

  // ── Streams ─────────────────────────────────────────────────────────────────

  /// All published courses (for students)
  Stream<List<CourseModel>> publishedCoursesStream() {
    return _col
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return _defaultSampleCourses;
          return snap.docs
              .map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();
        });
  }

  /// All courses (admin)
  Stream<List<CourseModel>> allCoursesStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return _defaultSampleCourses;
          return snap.docs
              .map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();
        });
  }

  Stream<List<CourseModel>> getAllCoursesStream() => allCoursesStream();

  Future<CourseModel?> getCourseById(String courseId) => getCourse(courseId);

  Future<bool> togglePublishCourse(String courseId, bool publish) => togglePublish(courseId, publish);

  Stream<CourseModel?> courseStream(String courseId) {
    return _col.doc(courseId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return _defaultSampleCourses.where((c) => c.courseId == courseId).firstOrNull;
      }
      return CourseModel.fromMap(snap.data() as Map<String, dynamic>, snap.id);
    });
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<String?> createCourse(CourseModel course) async {
    try {
      final ref = await _col.add(course.toMap());
      return ref.id; // return new ID
    } catch (e) {
      debugPrint('CourseService.createCourse: $e');
      return null;
    }
  }

  Future<bool> updateCourse(CourseModel course) async {
    try {
      await _col.doc(course.courseId).update({
        ...course.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('CourseService.updateCourse: $e');
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      await _col.doc(courseId).delete();
      return true;
    } catch (e) {
      debugPrint('CourseService.deleteCourse: $e');
      return false;
    }
  }

  Future<bool> togglePublish(String courseId, bool publish) async {
    try {
      await _col.doc(courseId).update({
        'isPublished': publish,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> incrementStudentCount(String courseId) async {
    await _col.doc(courseId).update({
      'studentCount': FieldValue.increment(1),
    });
  }

  Future<void> updateLessonCount(String courseId, int count) async {
    await _col.doc(courseId).update({'lessonCount': count});
  }

  Future<CourseModel?> getCourse(String courseId) async {
    try {
      final doc = await _col.doc(courseId).get();
      if (!doc.exists) {
        return _defaultSampleCourses.where((c) => c.courseId == courseId).firstOrNull;
      }
      return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return _defaultSampleCourses.where((c) => c.courseId == courseId).firstOrNull;
    }
  }

  // ── Admin stats ──────────────────────────────────────────────────────────────
  Future<Map<String, int>> getAdminStats() async {
    try {
      final snap = await _col.get();
      var all = snap.docs.map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
      if (all.isEmpty) {
        all = _defaultSampleCourses;
      }
      return {
        'total': all.length,
        'published': all.where((c) => c.isPublished).length,
        'draft': all.where((c) => !c.isPublished).length,
        'students': all.fold(0, (total, c) => total + c.studentCount),
      };
    } catch (e) {
      return {
        'total': _defaultSampleCourses.length,
        'published': _defaultSampleCourses.length,
        'draft': 0,
        'students': 2960,
      };
    }
  }
}
