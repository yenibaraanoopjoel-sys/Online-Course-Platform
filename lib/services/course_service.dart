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

  CollectionReference get _col => _db.collection(AppConstants.coursesCol);

  // ── Streams ─────────────────────────────────────────────────────────────────

  /// All published courses (for students)
  Stream<List<CourseModel>> publishedCoursesStream() {
    return _col
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// All courses (admin)
  Stream<List<CourseModel>> allCoursesStream() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<CourseModel>> getAllCoursesStream() => allCoursesStream();

  Future<CourseModel?> getCourseById(String courseId) => getCourse(courseId);

  Future<bool> togglePublishCourse(String courseId, bool publish) => togglePublish(courseId, publish);

  /// Single course by ID
  Stream<CourseModel?> courseStream(String courseId) {
    return _col.doc(courseId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
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
      if (!doc.exists) return null;
      return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  // ── Admin stats ──────────────────────────────────────────────────────────────
  Future<Map<String, int>> getAdminStats() async {
    try {
      final snap = await _col.get();
      final all = snap.docs.map((d) => CourseModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
      return {
        'total': all.length,
        'published': all.where((c) => c.isPublished).length,
        'draft': all.where((c) => !c.isPublished).length,
        'students': all.fold(0, (total, c) => total + c.studentCount),
      };
    } catch (e) {
      return {};
    }
  }
}
