import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? uid;
  final String firstname;
  final String? lastname;
  final String email;
  final String profilePic;
  final bool isAnonymous;
  final bool isAdmin;
  final String? phoneNumber;
  final String? deviceModel;
  final String? device_info;
  final String? osVersion;
  final String? installedBuildNumber;
  final DateTime? created_time;
  final DateTime? last_active_time;

  UserModel({
    this.uid,
    required this.firstname,
    this.lastname,
    required this.email,
    required this.profilePic,
    required this.isAnonymous,
    this.isAdmin = false,
    this.phoneNumber,
    this.deviceModel,
    this.device_info,
    this.osVersion,
    this.installedBuildNumber,
    this.created_time,
    this.last_active_time,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstname': firstname,
      'lastname': lastname ?? '',
      'email': email,
      'profilePic': profilePic,
      'isAnonymous': isAnonymous,
      'isAdmin': isAdmin,
      'phoneNumber': phoneNumber ?? '',
      'deviceModel': deviceModel ?? '',
      'device_info': device_info ?? '',
      'osVersion': osVersion ?? '',
      'installedBuildNumber': installedBuildNumber ?? '',
      'created_time': created_time?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'last_active_time': last_active_time?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static UserModel empty() => UserModel(
        uid: '',
        firstname: '',
        lastname: '',
        email: '',
        isAnonymous: false,
        isAdmin: false,
        profilePic: '',
        phoneNumber: '',
        deviceModel: '',
        device_info: '',
        osVersion: '',
        installedBuildNumber: '',
        created_time: DateTime.now(),
        last_active_time: DateTime.now(),
      );

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return UserModel(
        uid: data['uid'] ?? document.id,
        firstname: data['firstname'] ?? '',
        lastname: data['lastname'] ?? '',
        email: data['email'] ?? '',
        profilePic: data["profilePic"] ?? '',
        isAnonymous: data['isAnonymous'] ?? false,
        isAdmin: data['isAdmin'] ?? false,
        phoneNumber: data['phoneNumber'] ?? '',
        deviceModel: data['deviceModel'] ?? '',
        device_info: data['device_info'] ?? '',
        osVersion: data['osVersion'] ?? '',
        installedBuildNumber: data['installedBuildNumber'] ?? '',
        created_time: data['created_time'] != null 
            ? (data['created_time'] is Timestamp 
                ? (data['created_time'] as Timestamp).toDate() 
                : DateTime.parse(data['created_time'])) 
            : DateTime.now(),
        last_active_time: data['last_active_time'] != null 
            ? (data['last_active_time'] is Timestamp 
                ? (data['last_active_time'] as Timestamp).toDate() 
                : DateTime.parse(data['last_active_time'])) 
            : DateTime.now(),
      );
    } else {
      return UserModel.empty();
    }
  }

  UserModel copyWith({
    String? uid,
    String? firstname,
    String? lastname,
    String? email,
    String? profilePic,
    bool? isAnonymous,
    bool? isAdmin,
    String? phoneNumber,
    String? deviceModel,
    String? device_info,
    String? osVersion,
    String? installedBuildNumber,
    DateTime? created_time,
    DateTime? last_active_time,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isAdmin: isAdmin ?? this.isAdmin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceModel: deviceModel ?? this.deviceModel,
      device_info: device_info ?? this.device_info,
      osVersion: osVersion ?? this.osVersion,
      installedBuildNumber: installedBuildNumber ?? this.installedBuildNumber,
      created_time: created_time ?? this.created_time,
      last_active_time: last_active_time ?? this.last_active_time,
    );
  }
}