class UserDetailModel {
  final String? userId;
  final String? email;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? profilePicture;

  UserDetailModel({
    this.userId,
    this.email,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.profilePicture,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
    };
  }
}