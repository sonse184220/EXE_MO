class AdminViewUserModel {
  final String? userId;
  final String? email;
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? profilePicture;
  final String? createdAt;
  final String? lastLoginDate;
  final String? status;
  final bool? verified;
  final String? roleName;

  AdminViewUserModel({
    this.userId,
    this.email,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.profilePicture,
    this.createdAt,
    this.lastLoginDate,
    this.status,
    this.verified,
    this.roleName,
  });

  factory AdminViewUserModel.fromJson(Map<String, dynamic> json) {
    return AdminViewUserModel(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] as String?,
      lastLoginDate: json['lastLoginDate'] as String?,
      status: json['status'] as String?,
      verified: json['verified'] as bool?,
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'lastLoginDate': lastLoginDate,
      'status': status,
      'verified': verified,
      'roleName': roleName,
    };
  }

  AdminViewUserModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? phoneNumber,
    String? profilePicture,
    String? createdAt,
    String? lastLoginDate,
    String? status,
    bool? verified,
    String? roleName,
  }) {
    return AdminViewUserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      status: status ?? this.status,
      verified: verified ?? this.verified,
      roleName: roleName ?? this.roleName,
    );
  }
}
