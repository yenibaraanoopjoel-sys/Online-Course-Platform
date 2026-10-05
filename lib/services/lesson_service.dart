import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/lesson_model.dart';
import '../core/constants/app_constants.dart';

class LessonService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection(AppConstants.lessonsCol);

  static List<LessonModel> _sampleLessons(String courseId) => [
    LessonModel(
      lessonId: '$courseId-l1',
      courseId: courseId,
      title: '1. Welcome & Architecture Overview',
      description: 'Orientation, learning objectives, and development environment setup.',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      content: '# Welcome to the Course!\n\nIn this lesson, we will explore the foundational principles, tooling, and architectural patterns you need to build scalable, full-stack applications.\n\n### Key Takeaways:\n- Understanding core frameworks\n- Setting up local development tooling\n- Project organization and best practices',
      duration: 15,
      order: 1,
      isPublished: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    LessonModel(
      lessonId: '$courseId-l2',
      courseId: courseId,
      title: '2. Core Principles & State Management',
      description: 'Understanding state lifecycles, unidirectional data flow, and reactive state.',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      content: '# State Management in Depth\n\nLearn how state changes propagate through the UI tree and how to use reactive providers to separate business logic from UI widgets.',
      duration: 25,
      order: 2,
      isPublished: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    LessonModel(
      lessonId: '$courseId-l3',
      courseId: courseId,
      title: '3. Connecting Cloud Services & Database',
      description: 'Configuring realtime Firestore subscriptions, authentication listeners, and storage.',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      content: '# Cloud Integration\n\nIntegrate Firebase services seamlessly into your frontend with automated error handling and caching.',
      duration: 35,
      order: 3,
      isPublished: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    LessonModel(
      lessonId: '$courseId-l4',
      courseId: courseId,
      title: '4. Production Deployment & Security Rules',
      description: 'Best practices for securing databases, bundling for production, and hosting.',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      content: '# Deployment Best Practices\n\nEnsure role-based security rules and test your single-page application across web and mobile platforms.',
      duration: 20,
      order: 4,
      isPublished: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  // ── Streams ─────────────────────────────────────────────────────────────────

  Stream<List<LessonModel>> lessonsForCourse(String courseId, {bool publishedOnly = false}) {
    Query q = _col.where('courseId', isEqualTo: courseId).orderBy('order');
    if (publishedOnly) q = q.where('isPublished', isEqualTo: true);
    return q.snapshots().map((snap) {
      if (snap.docs.isEmpty) return _sampleLessons(courseId);
      return snap.docs
          .map((d) => LessonModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    });
  }

  Stream<List<LessonModel>> getLessonsStream(String courseId) => lessonsForCourse(courseId);

  Future<LessonModel?> getLessonById(String lessonId) async {
    try {
      final doc = await _col.doc(lessonId).get();
      if (!doc.exists) {
        return _sampleLessons('sample-course-1').where((l) => l.lessonId == lessonId).firstOrNull;
      }
      return LessonModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return _sampleLessons('sample-course-1').where((l) => l.lessonId == lessonId).firstOrNull;
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
