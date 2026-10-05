import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/progress_model.dart';
import '../core/constants/app_constants.dart';

class ProgressService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection(AppConstants.progressCol);

  Stream<List<ProgressModel>> studentCourseProgressStream(String studentId, String courseId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProgressModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<List<ProgressModel>> getStudentCourseProgress(String studentId, String courseId) async {
    try {
      final snap = await _col
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .get();
      return snap.docs
          .map((d) => ProgressModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isLessonCompleted(String studentId, String lessonId) async {
    try {
      final snap = await _col
          .where('studentId', isEqualTo: studentId)
          .where('lessonId', isEqualTo: lessonId)
          .where('completed', isEqualTo: true)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Mark a lesson as completed (upsert)
  Future<void> markLessonComplete({
    required String studentId,
    required String courseId,
    required String lessonId,
  }) async {
    try {
      final snap = await _col
          .where('studentId', isEqualTo: studentId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      final now = DateTime.now();
      if (snap.docs.isEmpty) {
        final progress = ProgressModel(
          progressId: '',
          studentId: studentId,
          courseId: courseId,
          lessonId: lessonId,
          completed: true,
          completedAt: now,
        );
        await _col.add(progress.toMap());
      } else {
        await _col.doc(snap.docs.first.id).update({
          'completed': true,
          'completedAt': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      debugPrint('ProgressService.markLessonComplete: $e');
    }
  }

  Future<int> getCompletedLessonCount(String studentId, String courseId) async {
    try {
      final snap = await _col
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .where('completed', isEqualTo: true)
          .get();
      return snap.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
