import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/lesson_model.dart';
import '../core/constants/app_constants.dart';

class LessonService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection(AppConstants.lessonsCol);

  // ── Streams ─────────────────────────────────────────────────────────────────

  Stream<List<LessonModel>> lessonsForCourse(String courseId, {bool publishedOnly = false}) {
    Query q = _col.where('courseId', isEqualTo: courseId).orderBy('order');
    if (publishedOnly) q = q.where('isPublished', isEqualTo: true);
    return q.snapshots().map((snap) =>
        snap.docs.map((d) => LessonModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Stream<List<LessonModel>> getLessonsStream(String courseId) => lessonsForCourse(courseId);

  Future<LessonModel?> getLessonById(String lessonId) async {
    try {
      final doc = await _col.doc(lessonId).get();
      if (!doc.exists) return null;
      return LessonModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<String?> createLesson(LessonModel lesson) async {
    try {
      final ref = await _col.add(lesson.toMap());
      return ref.id;
    } catch (e) {
      debugPrint('LessonService.createLesson: $e');
      return null;
    }
  }

  Future<bool> updateLesson(LessonModel lesson) async {
    try {
      await _col.doc(lesson.lessonId).update({
        ...lesson.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('LessonService.updateLesson: $e');
      return false;
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    try {
      await _col.doc(lessonId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> togglePublish(String lessonId, bool publish) async {
    try {
      await _col.doc(lessonId).update({
        'isPublished': publish,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getLessonCount(String courseId) async {
    try {
      final snap = await _col.where('courseId', isEqualTo: courseId).get();
      return snap.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<LessonModel>> getLessonsForCourse(String courseId) async {
    try {
      final snap = await _col
          .where('courseId', isEqualTo: courseId)
          .orderBy('order')
          .get();
      return snap.docs
          .map((d) => LessonModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
