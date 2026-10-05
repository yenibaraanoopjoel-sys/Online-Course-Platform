import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String progressId;
  final String studentId;
  final String courseId;
  final String lessonId;
  final bool completed;
  final DateTime completedAt;

  ProgressModel({
    required this.progressId,
    required this.studentId,
    required this.courseId,
    required this.lessonId,
    this.completed = false,
    required this.completedAt,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgressModel(
      progressId: id,
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      completed: map['completed'] ?? false,
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'lessonId': lessonId,
      'completed': completed,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
