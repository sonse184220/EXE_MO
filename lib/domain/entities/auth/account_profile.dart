class AccountProfile {
  final String userId;
  final String profileId;
  final String profileStatus;
  final String profileToken;

  AccountProfile({
    required this.userId,
    required this.profileId,
    required this.profileStatus,
    required this.profileToken,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    return AccountProfile(
      userId: json['userId'] as String,
      profileId: json['profileId'] as String,
      profileStatus: json['profileStatus'] as String,
      profileToken: json['profileToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileId': profileId,
      'profileStatus': profileStatus,
      'profileToken': profileToken,
    };
  }
}
