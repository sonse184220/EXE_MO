import 'dart:io';

import 'package:intl/intl.dart';

class ProfileEditModel {
  String fullName;
  String phoneNumber;
  DateTime? dateOfBirth;
  String gender;
  String address;
  File? profileImage;

  ProfileEditModel({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.address,
    this.dateOfBirth,
    this.profileImage,
  });

  factory ProfileEditModel.fromJson(Map<String, dynamic> json) {
    return ProfileEditModel(
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      profileImage: json['profile_image'] != null
          ? File(json['profile_image']) // If image path is available
          : null,
    );
  }

  // Convert the ProfileEditModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(dateOfBirth!)
          : null,
      'gender': gender,
      'address': address,
      'profile_image': profileImage?.path,
    };
  }
}