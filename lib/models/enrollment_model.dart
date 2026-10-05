import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String enrollmentId;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseTitle;
  final DateTime enrolledAt;
  final double progress; // 0.0 – 1.0
  final int completedLessons;
  final int totalLessons;
  final DateTime lastAccessedAt;
  final bool completed;

  EnrollmentModel({
    required this.enrollmentId,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseTitle,
    required this.enrolledAt,
    this.progress = 0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    required this.lastAccessedAt,
    this.completed = false,
  });

  int get progressPercent => (progress * 100).round();
  double get progressPercentage => progress * 100;

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      enrollmentId: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      enrolledAt: map['enrolledAt'] is Timestamp
          ? (map['enrolledAt'] as Timestamp).toDate()
          : DateTime.now(),
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      completedLessons: (map['completedLessons'] as num?)?.toInt() ?? 0,
      totalLessons: (map['totalLessons'] as num?)?.toInt() ?? 0,
      lastAccessedAt: map['lastAccessedAt'] is Timestamp
          ? (map['lastAccessedAt'] as Timestamp).toDate()
          : DateTime.now(),
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'progress': progress,
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'completed': completed,
    };
  }

  EnrollmentModel copyWith({
    double? progress,
    int? completedLessons,
    int? totalLessons,
    DateTime? lastAccessedAt,
    bool? completed,
  }) {
    return EnrollmentModel(
      enrollmentId: enrollmentId,
      studentId: studentId,
      studentName: studentName,
      courseId: courseId,
      courseTitle: courseTitle,
      enrolledAt: enrolledAt,
      progress: progress ?? this.progress,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completed: completed ?? this.completed,
    );
  }
}
