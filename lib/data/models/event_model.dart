import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String description;
  final String poster;
  final String link;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.startDate,
    this.endDate,
    required this.description,
    required this.poster,
    required this.link,
    this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'poster': poster,
      'link': link,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EventModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return EventModel(
      id: document.id,
      title: data['title'] ?? '',
      startDate: data['startDate'] != null 
          ? (data['startDate'] is Timestamp 
              ? (data['startDate'] as Timestamp).toDate() 
              : DateTime.parse(data['startDate'])) 
          : null,
      endDate: data['endDate'] != null 
          ? (data['endDate'] is Timestamp 
              ? (data['endDate'] as Timestamp).toDate() 
              : DateTime.parse(data['endDate'])) 
          : null,
      description: data['description'] ?? '',
      poster: data['poster'] ?? '',
      link: data['link'] ?? '',
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

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? poster,
    String? link,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      poster: poster ?? this.poster,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 