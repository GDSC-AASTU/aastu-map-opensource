import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String backgroundImage;
  final String logoImage;
  final String title;
  final int membersCount;
  final String description;
  final List<String> images;
  final List<SocialMedia> socialMedia;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  ClubModel({
    required this.id,
    required this.backgroundImage,
    required this.logoImage,
    required this.title,
    required this.membersCount,
    required this.description,
    required this.images,
    required this.socialMedia,
    this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'backgroundImage': backgroundImage,
      'logoImage': logoImage,
      'title': title,
      'membersCount': membersCount,
      'description': description,
      'images': images,
      'socialMedia': socialMedia.map((social) => social.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ClubModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    
    List<SocialMedia> socialMediaList = [];
    if (data['socialMedia'] != null) {
      socialMediaList = List<SocialMedia>.from(
        (data['socialMedia'] as List).map(
          (social) => SocialMedia.fromJson(social),
        ),
      );
    }

    return ClubModel(
      id: document.id,
      backgroundImage: data['backgroundImage'] ?? '',
      logoImage: data['logoImage'] ?? '',
      title: data['title'] ?? '',
      membersCount: data['membersCount'] ?? 0,
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      socialMedia: socialMediaList,
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

  ClubModel copyWith({
    String? id,
    String? backgroundImage,
    String? logoImage,
    String? title,
    int? membersCount,
    String? description,
    List<String>? images,
    List<SocialMedia>? socialMedia,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      logoImage: logoImage ?? this.logoImage,
      title: title ?? this.title,
      membersCount: membersCount ?? this.membersCount,
      description: description ?? this.description,
      images: images ?? this.images,
      socialMedia: socialMedia ?? this.socialMedia,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SocialMedia {
  final String platform;
  final String url;

  SocialMedia({
    required this.platform,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }
} 