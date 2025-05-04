import 'package:cloud_firestore/cloud_firestore.dart';

class AboutAastuModel {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  AboutAastuModel({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'images': images,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AboutAastuModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return AboutAastuModel(
      id: document.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
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

  AboutAastuModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? images,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return AboutAastuModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 