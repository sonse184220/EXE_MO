class CommunityModel {
  final String communityGroupId;
  final String communityName;
  final String communityDescription;
  final DateTime communityCreatedAt;
  final String communityStatus;

  CommunityModel({
    required this.communityGroupId,
    required this.communityName,
    required this.communityDescription,
    required this.communityCreatedAt,
    required this.communityStatus,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      communityGroupId: json['communityGroupId'] as String,
      communityName: json['communityName'] as String,
      communityDescription: json['communityDescription'] as String,
      communityCreatedAt: DateTime.parse(json['communityCreatedAt']),
      communityStatus: json['communityStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityGroupId': communityGroupId,
      'communityName': communityName,
      'communityDescription': communityDescription,
      'communityCreatedAt': communityCreatedAt.toIso8601String(),
      'communityStatus': communityStatus,
    };
  }
}
