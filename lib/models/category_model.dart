import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String description;
  final String image;
  final DateTime createdAt;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.description = '',
    this.image = '',
    required this.createdAt,
  });

  String get id => categoryId;

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      categoryId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CategoryModel copyWith({String? name, String? description, String? image}) {
    return CategoryModel(
      categoryId: categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt,
    );
  }
}
