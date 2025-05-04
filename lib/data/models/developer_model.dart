import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperModel {
  final String id;
  final String name;
  final String role;
  final String profilePic;
  final int year;
  final String department;
  final Map<String, String> socialMedia;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  DeveloperModel({
    required this.id,
    required this.name,
    required this.role,
    required this.profilePic,
    required this.year,
    required this.department,
    this.socialMedia = const {},
    this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'profilePic': profilePic,
      'year': year,
      'department': department,
      'socialMedia': socialMedia,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeveloperModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    
    Map<String, String> socialMediaMap = {};
    if (data['socialMedia'] != null) {
      (data['socialMedia'] as Map<String, dynamic>).forEach((key, value) {
        socialMediaMap[key] = value.toString();
      });
    }

    return DeveloperModel(
      id: document.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      profilePic: data['profilePic'] ?? '',
      year: data['year'] ?? 0,
      department: data['department'] ?? '',
      socialMedia: socialMediaMap,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(data['createdAt'])) 
          : null,
      createdBy: data['createdBy'] ?? '',
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(data['updatedAt'])) 
          : null,
    );
  }

  DeveloperModel copyWith({
    String? id,
    String? name,
    String? role,
    String? profilePic,
    int? year,
    String? department,
    Map<String, String>? socialMedia,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return DeveloperModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      year: year ?? this.year,
      department: department ?? this.department,
      socialMedia: socialMedia ?? this.socialMedia,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 