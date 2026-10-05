import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String shortDescription;
  final String thumbnail;
  final String instructorId;
  final String instructorName;
  final String categoryId;
  final String categoryName;
  final String level;
  final int duration; // in minutes
  final double price;
  final bool isPublished;
  final int lessonCount;
  final int studentCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    this.shortDescription = '',
    this.thumbnail = '',
    required this.instructorId,
    required this.instructorName,
    required this.categoryId,
    required this.categoryName,
    required this.level,
    required this.duration,
    this.price = 0,
    this.isPublished = false,
    this.lessonCount = 0,
    this.studentCount = 0,
    this.rating = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get id => courseId;
  String get thumbnailUrl => thumbnail;
  String get category => categoryName;

  bool get isFree => price == 0;

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      courseId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      level: map['level'] ?? 'Beginner',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      isPublished: map['isPublished'] ?? false,
      lessonCount: (map['lessonCount'] as num?)?.toInt() ?? 0,
      studentCount: (map['studentCount'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
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
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'thumbnail': thumbnail,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'level': level,
      'duration': duration,
      'price': price,
      'isPublished': isPublished,
      'lessonCount': lessonCount,
      'studentCount': studentCount,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CourseModel copyWith({
    String? title,
    String? description,
    String? shortDescription,
    String? thumbnail,
    String? instructorId,
    String? instructorName,
    String? categoryId,
    String? categoryName,
    String? level,
    int? duration,
    double? price,
    bool? isPublished,
    int? lessonCount,
    int? studentCount,
    double? rating,
  }) {
    return CourseModel(
      courseId: courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isPublished: isPublished ?? this.isPublished,
      lessonCount: lessonCount ?? this.lessonCount,
      studentCount: studentCount ?? this.studentCount,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
