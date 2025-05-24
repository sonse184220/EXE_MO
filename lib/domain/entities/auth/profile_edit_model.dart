import 'dart:io';

import 'package:intl/intl.dart';

class ProfileEditModel {
  String? userId;
  String? email;
  String? fullName;
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? gender;
  String? profilePicture; // Can be a URL or file name
  File? profileImage;

  ProfileEditModel({
    this.userId,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.profileImage,
  });

  factory ProfileEditModel.fromJson(Map<String, dynamic> json) {
    return ProfileEditModel(
      userId: json['userId'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      profilePicture: json['profilePicture'],
    );
  }

  // Convert the ProfileEditModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(dateOfBirth!)
          : null,
      'profilePicture': profilePicture,
    };
  }
}