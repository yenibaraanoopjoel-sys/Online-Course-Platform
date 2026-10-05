import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String lessonId;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final String content;
  final int duration; // in minutes
  final int order;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonModel({
    required this.lessonId,
    required this.courseId,
    required this.title,
    this.description = '',
    this.videoUrl = '',
    this.content = '',
    this.duration = 0,
    required this.order,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get id => lessonId;

  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasContent => content.isNotEmpty;

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      lessonId: id,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      content: map['content'] ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isPublished: map['isPublished'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'content': content,
      'duration': duration,
      'order': order,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LessonModel copyWith({
    String? title,
    String? description,
    String? videoUrl,
    String? content,
    int? duration,
    int? order,
    bool? isPublished,
  }) {
    return LessonModel(
      lessonId: lessonId,
      courseId: courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
