import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String title;
  final List<String> images;
  final String blockNo;
  final String description;
  final List<String> services;
  final GeoLocation location;
  final List<Review> reviews;
  final DateTime? createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  PlaceModel({
    required this.id,
    required this.title,
    required this.images,
    required this.blockNo,
    required this.description,
    required this.services,
    required this.location,
    required this.reviews,
    this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'images': images,
      'blockNo': blockNo,
      'description': description,
      'services': services,
      'location': location.toJson(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PlaceModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    
    List<Review> reviewsList = [];
    if (data['reviews'] != null) {
      reviewsList = List<Review>.from(
        (data['reviews'] as List).map(
          (review) => Review.fromJson(review),
        ),
      );
    }

    return PlaceModel(
      id: document.id,
      title: data['title'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      blockNo: data['blockNo'] ?? '',
      description: data['description'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      location: data['location'] != null 
          ? GeoLocation.fromJson(data['location']) 
          : GeoLocation(lat: 0, lng: 0),
      reviews: reviewsList,
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

  PlaceModel copyWith({
    String? id,
    String? title,
    List<String>? images,
    String? blockNo,
    String? description,
    List<String>? services,
    GeoLocation? location,
    List<Review>? reviews,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      images: images ?? this.images,
      blockNo: blockNo ?? this.blockNo,
      description: description ?? this.description,
      services: services ?? this.services,
      location: location ?? this.location,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GeoLocation {
  final double lat;
  final double lng;

  GeoLocation({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class Review {
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      date: json['date'] != null 
          ? (json['date'] is Timestamp 
              ? (json['date'] as Timestamp).toDate() 
              : DateTime.parse(json['date'])) 
          : DateTime.now(),
    );
  }
} 