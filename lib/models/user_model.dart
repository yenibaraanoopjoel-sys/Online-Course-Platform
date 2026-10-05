import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String profileImage;
  final String role;
  final String bio;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImage = '',
    required this.role,
    this.bio = '',
    this.phone = '',
    required this.createdAt,
    required this.updatedAt,
  });

  String get uid => userId;
  String get displayName => fullName;
  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      role: map['role'] ?? 'student',
      bio: map['bio'] ?? '',
      phone: map['phone'] ?? '',
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
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'bio': bio,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? profileImage,
    String? role,
    String? bio,
    String? phone,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
