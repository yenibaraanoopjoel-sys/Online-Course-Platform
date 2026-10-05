import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/enrollment_model.dart';
import '../core/constants/app_constants.dart';

class EnrollmentService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<EnrollmentModel> _userEnrollments = [];
  List<EnrollmentModel> get userEnrollments => _userEnrollments;

  void setUserEnrollments(List<EnrollmentModel> list) {
    _userEnrollments = list;
    notifyListeners();
  }

  CollectionReference get _col => _db.collection(AppConstants.enrollmentsCol);

  // ── Streams ─────────────────────────────────────────────────────────────────

  Stream<List<EnrollmentModel>> studentEnrollmentsStream(String studentId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EnrollmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<EnrollmentModel>> courseEnrollmentsStream(String courseId) {
    return _col
        .where('courseId', isEqualTo: courseId)
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EnrollmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<EnrollmentModel>> allEnrollmentsStream() {
    return _col
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EnrollmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ── Check enrollment ─────────────────────────────────────────────────────────

  Future<EnrollmentModel?> getEnrollment(String studentId, String courseId) async {
    try {
      final snap = await _col
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return EnrollmentModel.fromMap(
          snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
    } catch (e) {
      debugPrint('EnrollmentService.getEnrollment: $e');
      return null;
    }
  }

  Future<bool> isEnrolled(String studentId, String courseId) async {
    final enroll = await getEnrollment(studentId, courseId);
    return enroll != null;
  }

  // ── Enroll ──────────────────────────────────────────────────────────────────

  Future<String?> enroll(EnrollmentModel enrollment) async {
    try {
      // Prevent duplicates
      final existing = await getEnrollment(enrollment.studentId, enrollment.courseId);
      if (existing != null) return existing.enrollmentId;

      final ref = await _col.add(enrollment.toMap());
      return ref.id;
    } catch (e) {
      debugPrint('EnrollmentService.enroll: $e');
      return null;
    }
  }

  // ── Progress update ──────────────────────────────────────────────────────────

  Future<void> updateProgress({
    required String enrollmentId,
    required int completedLessons,
    required int totalLessons,
  }) async {
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final completed = totalLessons > 0 && completedLessons >= totalLessons;
    await _col.doc(enrollmentId).update({
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'progress': progress,
      'completed': completed,
      'lastAccessedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> touchLastAccessed(String enrollmentId) async {
    await _col.doc(enrollmentId).update({
      'lastAccessedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<int> getTotalEnrollments() async {
    try {
      final snap = await _col.count().get();
      return snap.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
